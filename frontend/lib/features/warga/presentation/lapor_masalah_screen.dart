import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/atoms/custom_button.dart';

class LaporMasalahScreen extends StatefulWidget {
  const LaporMasalahScreen({super.key});

  @override
  State<LaporMasalahScreen> createState() => _LaporMasalahScreenState();
}

class _LaporMasalahScreenState extends State<LaporMasalahScreen> {
  String? _selectedKategori;
  final _deskripsiController = TextEditingController();

  @override
  void dispose() {
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Lapor Masalah',
          style: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kategori Masalah',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedKategori,
                  isExpanded: true,
                  hint: const Text('Pilih kategori...'),
                  items: [
                    'Kebersihan / Sampah',
                    'Fasilitas Umum / Lampu Jalan',
                    'Keamanan / Ketertiban',
                    'Infrastruktur / Jalan Rusak',
                    'Lainnya'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedKategori = newValue;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Deskripsi Masalah',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _deskripsiController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Jelaskan masalah secara detail...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primaryGreen),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Unggah Foto (Opsional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text('Tap untuk unggah foto', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'Kirim Laporan',
              onPressed: () {
                // TODO: Integrasi dengan API
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Laporan berhasil dikirim!')),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
