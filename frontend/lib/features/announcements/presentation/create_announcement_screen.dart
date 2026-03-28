import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../auth/logic/auth_provider.dart';
import '../logic/announcement_provider.dart';
import '../../../../widgets/atoms/custom_button.dart';
import 'package:intl/intl.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _fotoUrlController = TextEditingController();
  
  String? _selectedTarget;
  bool _isKegiatan = false;
  DateTime? _tanggalKegiatan;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _fotoUrlController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTarget == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih target pengumuman terlebih dahulu')),
      );
      return;
    }
    if (_isKegiatan && _tanggalKegiatan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal kegiatan terlebih dahulu')),
      );
      return;
    }

    final provider = context.read<AnnouncementProvider>();
    final targetValue = _selectedTarget == 'Seluruh Warga (Semua RT)' 
        ? 'SEMUA_RW' 
        : _selectedTarget == 'Hanya Ketua RT' 
            ? 'SEMUA_RT' 
            : 'WARGA_RT';

    final tglString = _tanggalKegiatan != null 
        ? DateFormat('yyyy-MM-dd').format(_tanggalKegiatan!) 
        : null;

    await provider.addAnnouncement(
      title: _titleController.text,
      content: _contentController.text,
      target: targetValue,
      fotoUrl: _fotoUrlController.text.trim(),
      isKegiatan: _isKegiatan,
      tanggalKegiatan: tglString,
    );

    if (mounted) {
      if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error!), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengumuman berhasil dibuat!'), backgroundColor: AppColors.primaryGreen),
        );
        Navigator.pop(context); // Go back to dashboard
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tanggalKegiatan = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = context.watch<AnnouncementProvider>().isLoading;
    
    // Determine Target Options based on Role
    List<String> targetOptions = [];
    if (auth.isRW) {
      targetOptions = ['Seluruh Warga (Semua RT)', 'Hanya Ketua RT'];
      // Jika belum dipilih, otomatis pilih opsi pertama
      _selectedTarget ??= targetOptions.first;
    } else {
      final nomorRt = auth.user != null && auth.user!['rt'] != null 
          ? auth.user!['rt']['nomor_rt'] 
          : "";
      targetOptions = ['Warga RT ($nomorRt)'];
      _selectedTarget ??= targetOptions.first;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Buat Pengumuman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sampaikan Informasi Penting',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 8),
              Text(
                'Informasi yang Anda buat akan langsung disebarkan ke target yang dipilih.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),

              // TARGET DROPDOWN
              const Text('Target Audience', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedTarget,
                    icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primaryGreen),
                    items: targetOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedTarget = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // TITLE INPUT
              const Text('Judul Pengumuman', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Misal: Kerja Bakti Rutin',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                  ),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              // EVENT SWITCH
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.event_available_rounded, color: AppColors.primaryGreen, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Jadikan sebagai Kegiatan',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Switch(
                          value: _isKegiatan,
                          activeColor: AppColors.primaryGreen,
                          onChanged: (val) {
                            setState(() {
                              _isKegiatan = val;
                              if (!val) _tanggalKegiatan = null;
                            });
                          },
                        ),
                      ],
                    ),
                    if (_isKegiatan) ...[
                      const Divider(height: 24),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _tanggalKegiatan == null 
                                  ? 'Pilih Tanggal Kegiatan' 
                                  : DateFormat('dd MMMM yyyy').format(_tanggalKegiatan!),
                                style: TextStyle(
                                  color: _tanggalKegiatan == null ? Colors.grey : AppColors.textPrimaryLight,
                                  fontWeight: _tanggalKegiatan == null ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                              const Icon(Icons.calendar_month_rounded, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // CONTENT INPUT
              const Text('Isi Pengumuman / Detail', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Tuliskan rincian informasi di sini...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Isi pengumuman wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              // FOTO URL INPUT (OPTIONAL)
              const Text('Lampirkan Foto Pengumuman (Opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fotoUrlController,
                decoration: InputDecoration(
                  hintText: 'https://contoh.com/gambar.jpg',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.link_rounded, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 38),

              CustomButton(
                text: 'Sebarkan Pengumuman',
                onPressed: _submit,
                isLoading: isLoading,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
