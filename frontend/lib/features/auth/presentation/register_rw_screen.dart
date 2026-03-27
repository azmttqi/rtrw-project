import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/atoms/custom_button.dart';
import '../../../../widgets/atoms/custom_text_field.dart';
import '../logic/auth_provider.dart';
import 'verification_screen.dart';

class RegisterRwScreen extends StatefulWidget {
  const RegisterRwScreen({super.key});

  @override
  State<RegisterRwScreen> createState() => _RegisterRwScreenState();
}

class _RegisterRwScreenState extends State<RegisterRwScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _rwNumberController = TextEditingController();
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      
      final success = await authProvider.registerRW(
        nama: _nameController.text,
        noWa: _phoneController.text,
        email: _emailController.text,
        password: _passwordController.text,
        nomorRw: _rwNumberController.text,
        namaWilayah: _locationController.text,
        alamat: _locationController.text, // Using location for both for now
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendaftaran RW Berhasil! Silakan verifikasi email Anda.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationScreen(identifier: _emailController.text),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Gagal melakukan pendaftaran'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimaryLight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Daftar RW Baru',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bentuk ekosistem digital untuk wilayah Anda.',
                  style: TextStyle(color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 40),

                CustomTextField(
                  label: 'Nama Lengkap Ketua RW',
                  hint: 'Masukkan nama sesuai KTP',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Nomor WhatsApp Aktif',
                  hint: '0812xxxxxxxx',
                  controller: _phoneController,
                  prefixIcon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Alamat Email',
                  hint: 'nama@email.com',
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Wajib diisi';
                    if (!v.contains('@')) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        label: 'No. RW',
                        hint: '08',
                        controller: _rwNumberController,
                        prefixIcon: Icons.home_work_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: CustomTextField(
                        label: 'Nama Wilayah',
                        hint: 'Green Garden',
                        controller: _locationController,
                        prefixIcon: Icons.map_outlined,
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Kata Sandi',
                  hint: 'Minimal 6 karakter',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: true,
                  validator: (v) => v!.length < 6 ? 'Minimal 6 karakter' : null,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Konfirmasi Kata Sandi',
                  hint: 'Masukkan kembali kata sandi',
                  controller: _confirmPasswordController,
                  prefixIcon: Icons.lock_reset_rounded,
                  obscureText: true,
                  validator: (v) => v != _passwordController.text ? 'Kata sandi tidak sama' : null,
                ),
                const SizedBox(height: 40),

                CustomButton(
                  text: 'Daftar Sekarang',
                  onPressed: _handleRegister,
                  useGradient: true,
                  icon: Icons.check_circle_outline_rounded,
                ),
                
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sudah memiliki akun? '),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Masuk di sini',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
