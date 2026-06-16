import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../logic/letter_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/atoms/custom_button.dart';

class PersuratanScreen extends StatefulWidget {
  const PersuratanScreen({super.key});

  @override
  State<PersuratanScreen> createState() => _PersuratanScreenState();
}

class _PersuratanScreenState extends State<PersuratanScreen> {
  String? _selectedJenisSurat;
  final _keperluanController = TextEditingController();

  @override
  void dispose() {
    _keperluanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Persuratan',
            style: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
          bottom: const TabBar(
            labelColor: AppColors.primaryGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primaryGreen,
            tabs: [
              Tab(text: 'Ajukan Surat'),
              Tab(text: 'Riwayat Surat'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFormPengajuan(),
            _buildRiwayatSurat(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormPengajuan() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Jenis Surat',
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
                value: _selectedJenisSurat,
                isExpanded: true,
                hint: const Text('Pilih jenis surat...'),
                items: [
                  'Surat Keterangan Domisili',
                  'Surat Keterangan Tidak Mampu',
                  'Surat Keterangan Belum Menikah',
                  'Surat Keterangan Usaha',
                  'Lainnya'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedJenisSurat = newValue;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Keperluan Pengajuan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _keperluanController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Jelaskan keperluan Anda secara detail...',
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
          const SizedBox(height: 40),
          CustomButton(
            text: 'Ajukan Surat',
            onPressed: () async {
              if (_selectedJenisSurat == null || _keperluanController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi form terlebih dahulu')));
                return;
              }
              final success = await context.read<LetterProvider>().createLetter(_selectedJenisSurat!, _keperluanController.text);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengajuan surat berhasil dikirim!')));
                setState(() {
                  _selectedJenisSurat = null;
                  _keperluanController.clear();
                });
              } else if (context.mounted) {
                final error = context.read<LetterProvider>().error;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Gagal mengajukan surat')));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatSurat() {
    return Consumer<LetterProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.letters.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (provider.letters.isEmpty) {
          return const Center(child: Text('Belum ada riwayat pengajuan surat.', style: TextStyle(color: Colors.grey)));
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchLetters(),
          child: ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: provider.letters.length,
            itemBuilder: (context, index) {
              final letter = provider.letters[index];
              final isReady = letter.status == 'APPROVED';
              final isRejected = letter.status == 'REJECTED';
              
              Color statusColor = Colors.orange;
              String statusText = letter.status;

              if (isReady) {
                statusColor = Colors.green;
              } else if (isRejected) {
                statusColor = Colors.red;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mark_email_read_outlined, color: AppColors.primaryGreen),
                  ),
                  title: Text(letter.jenisSurat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tanggal Pengajuan: ${DateFormat('dd MMM yyyy').format(letter.createdAt)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              statusText,
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: isReady
                      ? ElevatedButton(
                          onPressed: () async {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mengunduh file...')));
                            final path = await context.read<LetterProvider>().downloadLetterFile(letter.id, letter.jenisSurat);
                            if (path != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File berhasil diunduh ke:\n$path')));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF076633),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('Unduh', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      : null,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
