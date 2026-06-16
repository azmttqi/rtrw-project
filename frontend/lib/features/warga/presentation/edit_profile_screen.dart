import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/logic/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/atoms/custom_button.dart';
import '../../../../widgets/atoms/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _noWaController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _namaController = TextEditingController(text: user?['nama'] ?? '');
    _noWaController = TextEditingController(text: user?['no_wa'] ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noWaController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      _namaController.text,
      _noWaController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Gagal memperbarui profil')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Ubah Profil',
          style: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informasi Data Diri',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap',
                controller: _namaController,
                validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Nomor WhatsApp',
                hint: 'Contoh: 08123456789',
                controller: _noWaController,
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Nomor WA tidak boleh kosong' : null,
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Simpan Perubahan',
                isLoading: isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
