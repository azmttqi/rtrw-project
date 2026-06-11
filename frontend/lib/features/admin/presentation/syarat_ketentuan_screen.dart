import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SyaratKetentuanScreen extends StatelessWidget {
  const SyaratKetentuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Syarat & Ketentuan'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.gavel, size: 60, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Syarat dan Ketentuan Penggunaan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Pendahuluan',
              'Selamat datang di aplikasi LingkarWarga. Dengan mengakses dan menggunakan aplikasi ini, Anda setuju untuk terikat oleh Syarat dan Ketentuan yang berlaku. Jika Anda tidak setuju dengan ketentuan ini, Anda tidak diperkenankan menggunakan aplikasi ini.',
            ),
            _buildSection(
              '2. Data Pribadi & Privasi',
              'Kami berkomitmen untuk melindungi data pribadi Anda. Data yang dikumpulkan seperti Nomor Induk Kependudukan (NIK), Kartu Keluarga, dan nomor kontak hanya digunakan untuk keperluan administrasi Rukun Tetangga (RT) dan Rukun Warga (RW). Kami tidak akan menyebarkan data Anda ke pihak ketiga tanpa persetujuan tertulis.',
            ),
            _buildSection(
              '3. Kewajiban Pengguna',
              'Setiap pengguna wajib memberikan informasi yang akurat, jujur, dan tidak menyesatkan saat melakukan pendaftaran maupun pembaharuan data. Segala bentuk pemalsuan data kependudukan dapat dikenakan sanksi sesuai dengan peraturan perundang-undangan yang berlaku di Negara Kesatuan Republik Indonesia.',
            ),
            _buildSection(
              '4. Keamanan Akun',
              'Anda bertanggung jawab penuh untuk menjaga kerahasiaan kata sandi akun Anda. Segala aktivitas yang terjadi di bawah akun Anda dianggap sebagai tanggung jawab Anda sepenuhnya. Laporkan segera jika terdapat aktivitas mencurigakan.',
            ),
            _buildSection(
              '5. Perubahan Ketentuan',
              'Pengelola berhak mengubah, menambah, atau menghapus bagian mana pun dari Syarat dan Ketentuan ini kapan saja tanpa pemberitahuan sebelumnya. Penggunaan berkelanjutan Anda atas aplikasi ini setelah adanya perubahan merupakan persetujuan Anda terhadap perubahan tersebut.',
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'Terakhir diperbarui: 10 Juni 2026\nTim Pengembang LingkarWarga',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
