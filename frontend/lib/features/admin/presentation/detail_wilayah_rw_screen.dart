import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../auth/logic/auth_provider.dart';

class DetailWilayahRwScreen extends StatelessWidget {
  const DetailWilayahRwScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final rw = user?['nomor_rw'] ?? '01';
    final kelurahan = user?['nama_wilayah'] ?? 'Menteng';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Detail Wilayah RW'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.map_outlined, size: 60, color: AppColors.primaryGreen),
                    const SizedBox(height: 12),
                    Text(
                      'Rukun Warga $rw',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Kelurahan $kelurahan',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Statistik Demografi (Simulasi)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Total RT', '12', Icons.holiday_village)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Kepala Keluarga', '345', Icons.family_restroom)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Jiwa', '1,240', Icons.people)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Fasilitas Umum', '4', Icons.park)),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Batas Wilayah Administratif',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _BoundaryRow(title: 'Utara', desc: 'Jalan Raya Menteng'),
                    Divider(),
                    _BoundaryRow(title: 'Selatan', desc: 'Sungai Ciliwung'),
                    Divider(),
                    _BoundaryRow(title: 'Timur', desc: 'Kompleks Perumahan Indah'),
                    Divider(),
                    _BoundaryRow(title: 'Barat', desc: 'Jalan Sudirman'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 28),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _BoundaryRow extends StatelessWidget {
  final String title;
  final String desc;
  const _BoundaryRow({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
          ),
          Expanded(
            child: Text(desc, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
