import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/logic/auth_provider.dart';
import 'family_registration_screen.dart'; // To be created
import '../../../widgets/atoms/custom_text_field.dart';
import '../../../widgets/atoms/custom_button.dart';

class RegisterWargaScreen extends StatefulWidget {
  final String token;
  const RegisterWargaScreen({super.key, required this.token});

  @override
  State<RegisterWargaScreen> createState() => _RegisterWargaScreenState();
}

class _RegisterWargaScreenState extends State<RegisterWargaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _waController = TextEditingController();
  final _passController = TextEditingController();

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.registerWarga(
        nama: _namaController.text,
        noWa: _waController.text,
        password: _passController.text,
        tokenInvitation: widget.token,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const FamilyRegistrationScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi Warga')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Selamat Datang!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lengkapi data di bawah ini untuk mengaktifkan akun Warga Anda.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              CustomTextField(
                controller: _namaController,
                label: 'Nama Lengkap',
                hint: 'Sesuai KTP',
                prefixIcon: Icons.person_outline,
                validator: (value) => value == null || value.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _waController,
                label: 'Nomor WhatsApp',
                hint: 'Contoh: 081234567890',
                prefixIcon: Icons.phone_android,
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.length < 10 ? 'Nomor WA tidak valid' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passController,
                label: 'Buat Password',
                hint: 'Minimal 6 karakter',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (value) => value == null || value.length < 6 ? 'Password minimal 6 karakter' : null,
              ),
              
              const SizedBox(height: 32),
              if (authProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                CustomButton(
                  text: 'VERIFIKASI & LANJUT',
                  onPressed: _handleRegister,
                  variant: ButtonVariant.primary,
                ),
                
              if (authProvider.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    authProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
