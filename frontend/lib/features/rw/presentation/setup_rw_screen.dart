import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/logic/auth_provider.dart';
import '../../../widgets/atoms/custom_text_field.dart';
import '../../../widgets/atoms/custom_button.dart';
import '../../../core/api_client.dart';
import '../../admin/presentation/dashboard_screen.dart';

class SetupRwScreen extends StatefulWidget {
  const SetupRwScreen({super.key});

  @override
  State<SetupRwScreen> createState() => _SetupRwScreenState();
}

class _SetupRwScreenState extends State<SetupRwScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rwNumberController = TextEditingController();
  final List<TextEditingController> _rtControllers = [TextEditingController()];

  void _addRT() {
    setState(() {
      _rtControllers.add(TextEditingController());
    });
  }

  void _removeRT(int index) {
    if (_rtControllers.length > 1) {
      setState(() {
        _rtControllers.removeAt(index);
      });
    }
  }

  Future<void> _submitSetup() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      setState(() {
        // Maybe add a local isLoading if needed
      });

      try {
        await apiClient.post('/rw/setup', data: {
          'nomor_rw': _rwNumberController.text,
          'rts': _rtControllers.map((c) => c.text).toList(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lingkungan RW berhasil disetup!')),
          );
          // Refresh user data to get rw_id
          await authProvider.checkAuthStatus();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Lingkungan RW'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Langkah Terakhir!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tentukan nomor RW dan daftar RT yang ada di wilayah Anda.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              CustomTextField(
                controller: _rwNumberController,
                label: 'Nomor RW',
                hint: 'Contoh: 01',
                prefixIcon: Icons.maps_home_work,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nomor RW wajib diisi';
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar RT',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _addRT,
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah RT'),
                  ),
                ],
              ),
              const Divider(),
              
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _rtControllers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _rtControllers[index],
                          label: 'Nomor RT ${index + 1}',
                          hint: 'Contoh: 001',
                          prefixIcon: Icons.door_front_door,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Wajib diisi';
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeRT(index),
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 48),
              CustomButton(
                text: 'SIMPAN & MULAI',
                onPressed: _submitSetup,
                variant: ButtonVariant.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
