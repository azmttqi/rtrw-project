import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/atoms/custom_text_field.dart';
import '../../../../widgets/atoms/custom_button.dart';
import '../../auth/logic/auth_provider.dart';

class AturTagihanScreen extends StatefulWidget {
  const AturTagihanScreen({super.key});

  @override
  State<AturTagihanScreen> createState() => _AturTagihanScreenState();
}

class _AturTagihanScreenState extends State<AturTagihanScreen> {
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimaryLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          auth.isRW ? 'Kelola Iuran RT' : 'Kelola Iuran Warga',
          style: const TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
             Text(
              auth.isRW ? 'ADMINISTRASI RW' : 'ADMINISTRASI RT',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              auth.isRW ? 'Atur Tagihan RT' : 'Atur Iuran Warga',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              auth.isRW 
                ? 'Tetapkan standar iuran bulanan untuk menjaga kesinambungan layanan warga di tingkat RW.'
                : 'Tetapkan nominal iuran bulanan untuk setiap Kepala Keluarga (KK) di wilayah RT 04.',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondaryLight, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Configuration Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F1).withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.green.shade50),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.payments_outlined, color: AppColors.primaryGreen, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Konfigurasi Iuran',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: auth.isRW ? 'Nominal Iuran per RT' : 'Nominal Iuran per KK',
                    hint: auth.isRW ? 'Rp 500.000' : 'Rp 150.000',
                    controller: _nominalController,
                    prefixIcon: Icons.money_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Tanggal Jatuh Tempo',
                    hint: 'mm/dd/yyyy',
                    controller: _dateController,
                    prefixIcon: Icons.calendar_today_rounded,
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() {
                          _dateController.text = "${date.month}/${date.day}/${date.year}";
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Deskripsi/Tujuan Iuran',
                    hint: 'Contoh: Pemeliharaan taman pusat, pengelolaan sampah terpadu...',
                    controller: _descController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Simpan & Terapkan Tagihan',
                    onPressed: () {
                      _showSuccessDialog(context);
                    },
                    icon: Icons.save_as_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info Alert
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      auth.isRW 
                        ? 'Perubahan nominal akan otomatis membuat tagihan baru untuk seluruh unit RT pada periode berikutnya.'
                        : 'Perubahan nominal akan otomatis diterapkan pada tagihan seluruh warga RT 04 di bulan depan.',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF855D10), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Status Tagihan RT
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  auth.isRW ? 'Status Tagihan RT' : 'Status Iuran Warga',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                ),
                Row(
                  children: [
                    Icon(Icons.filter_list_rounded, color: Colors.grey.shade400, size: 20),
                    const SizedBox(width: 16),
                    Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Periode: Oktober 2025',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 20),
            _buildBillingItem(auth.isRW ? 'RT 001' : 'Bp. Ahmad (B-12)', 'Terakhir bayar: 5 Okt', 'LUNAS', Colors.green),
            _buildBillingItem(auth.isRW ? 'RT 002' : 'Bp. Bambang (C-04)', 'Terlambat 3 hari', 'BELUM', Colors.red, isUrgent: true),
            _buildBillingItem(auth.isRW ? 'RT 003' : 'Ibu Siti (A-05)', 'Terakhir bayar: 12 Okt', 'LUNAS', Colors.green),
            _buildBillingItem(auth.isRW ? 'RT 004' : 'Bp. Dimas (D-10)', 'Menunggu verifikasi', 'PROSES', Colors.lightGreen),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingItem(String rt, String subtitle, String status, Color color, {bool isUrgent = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: isUrgent ? Colors.red : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Center(child: Text(rt.substring(3), style: TextStyle(color: color, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rt, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: isUrgent ? Colors.red : Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 60),
            const SizedBox(height: 16),
            const Text('Berhasil!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              Provider.of<AuthProvider>(context, listen: false).isRW 
                ? 'Pengaturan iuran telah diperbarui dan diterapkan ke seluruh RT.'
                : 'Pengaturan iuran telah diperbarui dan akan diterapkan ke seluruh warga RT 04.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(text: 'Selesai', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
