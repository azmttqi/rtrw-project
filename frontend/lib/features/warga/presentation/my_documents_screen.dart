import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MyDocumentsScreen extends StatelessWidget {
  const MyDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Dokumen Saya',
          style: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_shared_outlined, size: 80, color: AppColors.primaryGreen),
              SizedBox(height: 24),
              Text(
                'Segera Hadir',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
              ),
              SizedBox(height: 12),
              Text(
                'Fitur pengelolaan dokumen KTP dan KK saat ini sedang dalam tahap pengembangan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
