import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AnnouncementDetailModal {
  static void show(
    BuildContext context, {
    required String title,
    required String content,
    String? category,
    String? fotoUrl,
    bool isKegiatan = false,
    String? tanggalKegiatan,
    String? authorName,
    String? createdAtStr,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        titlePadding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        actionsPadding: const EdgeInsets.all(16),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Badge & Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isKegiatan 
                        ? AppColors.primaryYellow.withOpacity(0.1) 
                        : AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isKegiatan ? 'KEGIATAN' : (category ?? 'PENGUMUMAN'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isKegiatan ? const Color(0xFF856404) : AppColors.primaryGreen,
                    ),
                  ),
                ),
                if (createdAtStr != null)
                  Text(
                    createdAtStr,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, height: 1.3),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (fotoUrl != null && fotoUrl.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      fotoUrl,
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 160,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (isKegiatan && tanggalKegiatan != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.event, color: AppColors.primaryGreen, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Tanggal: ${tanggalKegiatan.split('T')[0]}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (authorName != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.person_pin, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        authorName,
                        style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
