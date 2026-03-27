import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/atoms/custom_button.dart';
import '../logic/auth_provider.dart';

class VerificationScreen extends StatefulWidget {
  final String identifier;
  const VerificationScreen({super.key, required this.identifier});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    // Auto submit if all filled
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _handleVerify();
    }
  }

  void _handleVerify() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyEmail(widget.identifier, otp);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verifikasi Berhasil! Akun Anda telah aktif.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Go to home/dashboard
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Kode verifikasi salah'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.mark_email_read_outlined, size: 80, color: AppColors.primaryGreen),
              const SizedBox(height: 32),
              const Text(
                'Verifikasi Email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 15, height: 1.5),
                  children: [
                    const TextSpan(text: 'Masukkan 6 digit kode yang telah kami kirimkan ke '),
                    TextSpan(
                      text: widget.identifier,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                          ),
                        ),
                        onChanged: (v) => _onOtpChanged(v, index),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 48),

              CustomButton(
                text: 'Verifikasi Sekarang',
                onPressed: _handleVerify,
                isLoading: isLoading,
                useGradient: true,
              ),
              const SizedBox(height: 32),
              
              TextButton(
                onPressed: () {
                   // Mock resend
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Kode baru telah dikirim! (Mock)')),
                   );
                },
                child: const Text(
                  'Kirim Ulang Kode',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
