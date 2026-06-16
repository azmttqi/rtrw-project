import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class BookingFasilitasScreen extends StatelessWidget {
  const BookingFasilitasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Booking Fasilitas',
          style: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildFasilitasItem(
            context,
            title: 'Clubhouse Serbaguna',
            status: 'Tersedia',
            icon: Icons.business_outlined,
            color: Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildFasilitasItem(
            context,
            title: 'Lapangan Tenis',
            status: 'Banyak Dipesan',
            icon: Icons.sports_tennis,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildFasilitasItem(
            context,
            title: 'Kolam Renang',
            status: 'Tersedia',
            icon: Icons.pool,
            color: Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildFasilitasItem(BuildContext context, {required String title, required String status, required IconData icon, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text('Status: $status', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur booking akan segera hadir!')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Booking', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
