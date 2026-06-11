import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/auth_provider.dart';
import '../../../../widgets/atoms/custom_text_field.dart';
import '../../../../widgets/atoms/custom_button.dart';

class RegisterRTScreen extends StatefulWidget {
  final String token;
  const RegisterRTScreen({super.key, required this.token});

  @override
  State<RegisterRTScreen> createState() => _RegisterRTScreenState();
}

class _RegisterRTScreenState extends State<RegisterRTScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _waController = TextEditingController();
  final _emailController = TextEditingController();
  final _rtController = TextEditingController();
  final _passController = TextEditingController();

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.registerRT(
        nama: _namaController.text,
        noWa: _waController.text,
        email: _emailController.text,
        nomorRt: _rtController.text,
        password: _passController.text,
        tokenInvitation: widget.token,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi RT berhasil. Menunggu verifikasi RW.')),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi Ketua RT')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Selamat Datang Ketua RT!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lengkapi data di bawah ini untuk mengaktifkan akun RT Anda.',
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
                controller: _rtController,
                label: 'Nomor RT',
                hint: 'Contoh: 01, 02, 10',
                prefixIcon: Icons.maps_home_work_outlined,
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Nomor RT wajib diisi' : null,
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
                controller: _emailController,
                label: 'Alamat Email',
                hint: 'nama@email.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email wajib diisi';
                  if (!value.contains('@')) return 'Format email tidak valid';
                  return null;
                },
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
                  text: 'DAFTAR SEKARANG',
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
