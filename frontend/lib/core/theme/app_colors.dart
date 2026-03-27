import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors based on Logo
  static const Color primaryGreen = Color(0xFF28A745); // More vibrant green from image
  static const Color primaryGreenDark = Color(0xFF1E7E34);
  static const Color primaryYellow = Color(0xFFEBB54A);

  // Neutral Colors
  static const Color backgroundLight = Color(0xFFF9FFF9); // Very light greenish white
  static const Color backgroundDark = Color(0xFF121212);
  
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  static const Color inputBackground = Color(0xFFE8EDE8); // Light grey-green for inputs

  static const Color textPrimaryLight = Color(0xFF2D3436);
  static const Color textSecondaryLight = Color(0xFF636E72);
  
  static const Color textPrimaryDark = Color(0xFFF8F9FA);
  static const Color textSecondaryDark = Color(0xFFADB5BD);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF1B7034),
      Color(0xFF5CCB7B),
    ],
  );

  // Status Colors
  static const Color error = Color(0xFFDC3545);
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF17A2B8);
}
