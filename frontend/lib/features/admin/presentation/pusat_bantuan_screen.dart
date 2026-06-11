import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PusatBantuanScreen extends StatelessWidget {
  const PusatBantuanScreen({super.key});

  final List<Map<String, String>> _faqs = const [
    {
      'question': 'Bagaimana cara mendaftarkan warga baru?',
      'answer': 'Anda dapat mendaftarkan warga baru dengan memberikan "Link Undangan" melalui menu "Kelola Akun Warga". Calon warga cukup mengisi form dari link tersebut dan Anda bisa memverifikasinya setelah itu.',
    },
    {
      'question': 'Apa yang harus dilakukan jika saya lupa kata sandi?',
      'answer': 'Saat ini fitur lupa sandi otomatis sedang dalam pengembangan. Silakan hubungi Administrator (RW) untuk mereset kata sandi Anda secara manual.',
    },
    {
      'question': 'Bagaimana cara mencetak rekap iuran bulanan?',
      'answer': 'Masuk ke menu Finance (Keuangan), pilih bulan yang diinginkan, lalu tekan tombol "Export to PDF" atau "Download Laporan" yang tersedia di pojok kanan atas layar.',
    },
    {
      'question': 'Siapa saja yang bisa melihat Surat Pengantar?',
      'answer': 'Surat pengantar yang dibuat oleh Warga hanya dapat dilihat oleh Warga yang bersangkutan dan Ketua RT setempat untuk keperluan tanda tangan/verifikasi.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Pusat Bantuan'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Icon(Icons.support_agent, size: 80, color: AppColors.primaryGreen),
          const SizedBox(height: 16),
          const Text(
            'Halo, Ada yang bisa kami bantu?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 8),
          const Text(
            'Temukan jawaban dari pertanyaan yang sering diajukan di bawah ini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          const Text(
            'FAQ (Tanya Jawab)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._faqs.map((faq) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  iconColor: AppColors.primaryGreen,
                  collapsedIconColor: Colors.grey,
                  title: Text(
                    faq['question']!,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        faq['answer']!,
                        style: const TextStyle(color: Colors.black87, height: 1.5),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Masih butuh bantuan? Hubungi Support IT\nsupport@lingkarwarga.com',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}
