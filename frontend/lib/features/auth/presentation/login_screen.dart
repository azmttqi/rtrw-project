import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../widgets/atoms/custom_button.dart';
import '../../../../widgets/atoms/custom_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../logic/auth_provider.dart';
import 'register_rw_screen.dart';
import 'verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailPhoneController = TextEditingController();
  final _passController = TextEditingController();

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        _emailPhoneController.text,
        _passController.text,
      );

      if (success && mounted) {
        if (!authProvider.isVerified) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerificationScreen(identifier: _emailPhoneController.text),
            ),
          );
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Berhasil!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Gagal login'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Header Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 48,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.home_work_rounded,
                        size: 32,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'LingkarWarga',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),

                // Welcome Text
                const Text(
                  'Selamat Datang\nKembali',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Silakan masuk ke akun Anda untuk melanjutkan.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 48),

                // Inputs
                CustomTextField(
                  controller: _emailPhoneController,
                  label: 'Alamat Email/ No. Handphone',
                  hint: 'nama@email.com',
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email atau No Handphone wajib diisi';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kata Sandi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Lupa Kata Sandi?',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _passController,
                      label: null,
                      hint: '........',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Kata sandi wajib diisi';
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Login Button
                CustomButton(
                  text: 'Masuk',
                  onPressed: _handleLogin,
                  isLoading: isLoading,
                  useGradient: true,
                  icon: Icons.arrow_forward_rounded,
                  iconRight: true,
                ),

                const SizedBox(height: 48),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Atau lanjutkan dengan',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 32),

                // Social Login
                CustomButton(
                  text: 'Login dengan Google',
                  variant: ButtonVariant.google,
                  customIcon: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                    height: 20,
                  ),
                  onPressed: () async {
                    final authProvider = context.read<AuthProvider>();
                    await authProvider.loginGoogle('mock_citizen');
                  },
                ),

                const SizedBox(height: 40),
                // Footer Links
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('KETENTUAN LAYANAN', style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1)),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('KEBIJAKAN PRIVASI', style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1)),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('BANTUAN', style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1)),
                  ],
                ),
                
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum menjadi bagian dari kami? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterRwScreen()),
                        );
                      },
                      child: const Text(
                        'Daftar RW',
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
