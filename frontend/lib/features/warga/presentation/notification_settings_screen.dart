import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/atoms/custom_button.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _darurat = true;
  bool _pengumuman = true;
  bool _tagihan = true;
  bool _surat = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Pengaturan Notifikasi',
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
              'Notifikasi Keamanan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SwitchListTile(
                title: const Text('Peringatan Darurat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Keamanan, kebakaran, bencana', style: TextStyle(fontSize: 12, color: Colors.grey)),
                value: _darurat,
                activeColor: AppColors.primaryGreen,
                onChanged: (value) {
                  setState(() => _darurat = value);
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aktivitas Lingkungan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Pengumuman RT/RW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Kegiatan warga, rapat, kerja bakti', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    value: _pengumuman,
                    activeColor: AppColors.primaryGreen,
                    onChanged: (value) {
                      setState(() => _pengumuman = value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Tagihan & Keuangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Pengingat iuran bulanan', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    value: _tagihan,
                    activeColor: AppColors.primaryGreen,
                    onChanged: (value) {
                      setState(() => _tagihan = value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Status Persuratan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Pembaruan status surat pengantar', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    value: _surat,
                    activeColor: AppColors.primaryGreen,
                    onChanged: (value) {
                      setState(() => _surat = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'Simpan Pengaturan',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pengaturan notifikasi berhasil disimpan!')),
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
