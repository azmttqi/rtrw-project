import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/atoms/custom_button.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Sidebar
            Expanded(
              flex: 3,
              child: _buildSidebar(context),
            ),
            // Right Content Area
            Expanded(
              flex: 7,
              child: _buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      color: AppColors.primaryGreen,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.home_filled, color: Colors.white, size: 32),
          const SizedBox(height: 16),
          const Text(
            'Manajemen\nRT/RW',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 40),
          _buildMenuItem(Icons.dashboard_rounded, 'Dashboard', isActive: true),
          const SizedBox(height: 16),
          _buildMenuItem(Icons.person_rounded, 'Warga'),
          const SizedBox(height: 16),
          _buildMenuItem(Icons.campaign_rounded, 'Pengumuman'),
          const SizedBox(height: 16),
          _buildMenuItem(Icons.error_outline_rounded, 'Pengaduan'),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Top Right
          Align(
            alignment: Alignment.centerRight,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryYellow.withOpacity(0.5),
              child: const Icon(Icons.person, color: Colors.black87, size: 28),
            ),
          ),
          const SizedBox(height: 16),
          
          // Dashboard Title
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Welcome Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang,\nAndi',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Lihat ringkasan kegiatan\nwarga di lingkungan',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Kegiatan Title
          const Text(
            'Kegiatan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Kegiatan Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 12,
              children: [
                _buildChip('Pengumuman'),
                _buildChip('Kegiatan'),
                _buildChip('Pengaduan'),
                _buildChip('Warga baru'),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Statistik Title
          const Text(
            'Statistik',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Statistik Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mock Chart Image
                SizedBox(
                  height: 80,
                  // Placeholder representing chart waves
                  child: CustomPaint(painter: WavePainter()),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Tambah kegiatan',
                  onPressed: () {},
                  variant: ButtonVariant.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryYellow.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}

// Simple custom painter to draw mock chart waves
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = AppColors.primaryYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final paint2 = Paint()
      ..color = AppColors.primaryYellow.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.5);
    path1.quadraticBezierTo(size.width * 0.25, size.height * 0.2, size.width * 0.5, size.height * 0.5);
    path1.quadraticBezierTo(size.width * 0.75, size.height * 0.8, size.width, size.height * 0.4);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.8);
    path2.quadraticBezierTo(size.width * 0.25, size.height * 0.6, size.width * 0.5, size.height * 0.8);
    path2.quadraticBezierTo(size.width * 0.75, size.height * 1.0, size.width, size.height * 0.7);

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
