import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() {
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      
      // Navigasi ditentukan oleh AuthWrapper di main.dart jika kita menggunakan home: AuthWrapper()
      // Tapi untuk mengikuti alur Splash -> Auth Check, kita bisa melakukan pengecekan di sini
      // atau membiarkan SplashScreen selesai dan menggantinya dengan widget utama yang mereaksi AuthProvider.
      
      // Dalam setup saat ini di main.dart, kita akan memperbarui main.dart agar SplashScreen
      // menjadi titik masuk, lalu berpindah ke AuthWrapper.
      Navigator.of(context).pushReplacementNamed('/auth-wrapper');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'logo',
              child: Image.asset(
                'assets/images/logo.png',
                height: 180,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.home_work_rounded,
                  size: 100,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
          ],
        ),
      ),
    );
  }
}
