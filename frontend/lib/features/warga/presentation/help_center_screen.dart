import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Pusat Bantuan',
          style: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text(
            'Pertanyaan yang Sering Diajukan (FAQ)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 16),
          _buildFAQItem(
            'Bagaimana cara membayar iuran bulanan?',
            'Anda dapat membayar iuran melalui menu "Bayar Tagihan" di beranda. Pembayaran dapat dilakukan via transfer bank dan bukti transfer diunggah melalui aplikasi.',
          ),
          _buildFAQItem(
            'Bagaimana cara mengajukan surat pengantar?',
            'Buka menu "Persuratan", pilih jenis surat yang diinginkan, isi keperluan, dan klik "Ajukan". Surat akan diproses oleh pihak RT dan RW untuk mendapatkan persetujuan.',
          ),
          _buildFAQItem(
            'Bagaimana cara menambahkan anggota keluarga?',
            'Fitur penambahan anggota keluarga secara mandiri dapat dilakukan melalui Pengaturan Akun, atau Anda dapat menghubungi Pengurus RT untuk bantuan pembaruan data.',
          ),
          _buildFAQItem(
            'Apa yang harus dilakukan saat keadaan darurat?',
            'Gunakan tombol Darurat berwarna merah di halaman Beranda. Notifikasi darurat akan langsung berbunyi dan terkirim ke seluruh warga terdekat serta pengurus lingkungan.',
          ),
          const SizedBox(height: 32),
          const Text(
            'Masih Butuh Bantuan?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.support_agent, color: AppColors.primaryGreen),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Layanan Admin Teknis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Whatsapp: 0812-3456-7890\nSenin - Jumat (09.00 - 17.00)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimaryLight),
        ),
        iconColor: AppColors.primaryGreen,
        collapsedIconColor: Colors.grey,
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          Text(
            answer,
            style: const TextStyle(color: Colors.grey, height: 1.5, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
