import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../logic/announcement_provider.dart';
import './widgets/announcement_detail_modal.dart';

class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({super.key});

  @override
  State<AnnouncementListScreen> createState() => _AnnouncementListScreenState();
}

class _AnnouncementListScreenState extends State<AnnouncementListScreen> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<AnnouncementProvider>().fetchAnnouncements(),
    );
  }

  // Filter list berdasarkan tanggal yang dipilih (bulan & tahun)
  List<dynamic> _getFiltered(AnnouncementProvider provider) {
    if (_selectedDate == null) return provider.announcements;
    return provider.announcements.where((item) {
      return item.createdAt.year == _selectedDate!.year &&
             item.createdAt.month == _selectedDate!.month;
    }).toList();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Pilih Bulan & Tahun',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryGreen,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnnouncementProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.fetchAnnouncements(),
          child: _buildBody(provider),
        ),
      ),
    );
  }

  Widget _buildBody(AnnouncementProvider provider) {
    if (provider.isLoading && provider.announcements.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.announcements.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 100,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Error: ${provider.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => provider.fetchAnnouncements(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // Custom Premium Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimaryLight),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_active_outlined, size: 20, color: AppColors.primaryGreen),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'INFORMASI TERBARU',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pengumuman\nWarga Digital',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimaryLight,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Temukan informasi penting dan agenda kegiatan di lingkungan Anda secara real-time.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Filter Tanggal Row
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedDate != null
                                ? AppColors.primaryGreen.withOpacity(0.08)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedDate != null
                                  ? AppColors.primaryGreen
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 16,
                                color: _selectedDate != null
                                    ? AppColors.primaryGreen
                                    : Colors.grey.shade500,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedDate != null
                                    ? DateFormat('MMMM yyyy').format(_selectedDate!)
                                    : 'Filter Berdasarkan Bulan',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedDate != null
                                      ? AppColors.primaryGreen
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_selectedDate != null) ...
                      [
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => setState(() => _selectedDate = null),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Icon(Icons.close_rounded, size: 16, color: Colors.red.shade400),
                          ),
                        ),
                      ],
                  ],
                ),
              ],
            ),
          ),
        ),

        if (provider.announcements.isEmpty || _getFiltered(provider).isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _selectedDate != null ? Icons.search_off_rounded : Icons.info_outline,
                      color: Colors.grey.shade400, 
                      size: 48
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedDate != null
                          ? 'Tidak ada pengumuman pada\n${DateFormat('MMMM yyyy').format(_selectedDate!)}'
                          : 'Belum ada pengumuman.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    ),
                    if (_selectedDate != null) ...[const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () => setState(() => _selectedDate = null),
                        icon: const Icon(Icons.refresh_rounded, size: 14),
                        label: const Text('Hapus Filter'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.primaryGreen),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),

        // List of Announcements
        if (_getFiltered(provider).isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final filtered = _getFiltered(provider);
                  final item = filtered[index];
                  final isLatest = index == 0;
                  
                  return InkWell(
                    onTap: () {
                      AnnouncementDetailModal.show(
                        context,
                        title: item.title,
                        content: item.content,
                        category: item.category,
                        fotoUrl: item.fotoUrl,
                        isKegiatan: item.isKegiatan,
                        tanggalKegiatan: item.tanggalKegiatan,
                        authorName: item.authorName,
                        createdAtStr: item.createdAt.toString().split(' ')[0], // Date format
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.fotoUrl != null && item.fotoUrl!.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                              child: Stack(
                                children: [
                                  Image.network(
                                    item.fotoUrl!,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 180,
                                      width: double.infinity,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                    ),
                                  ),
                                  if (isLatest)
                                    Positioned(
                                      top: 16,
                                      left: 16,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                            SizedBox(width: 4),
                                            Text(
                                              'TERBARU',
                                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          
                          Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: item.isKegiatan 
                                          ? AppColors.primaryYellow.withOpacity(0.1) 
                                          : AppColors.primaryGreen.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      item.isKegiatan ? 'KEGIATAN' : (item.category?.toUpperCase() ?? 'PENGUMUMAN'),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: item.isKegiatan ? const Color(0xFF856404) : AppColors.primaryGreen,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd MMM yyyy').format(item.createdAt),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimaryLight,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item.content,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                                    child: const Icon(Icons.person, size: 14, color: AppColors.primaryGreen),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.authorName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Text(
                                    'Baca',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: AppColors.primaryGreen, size: 16),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ), // Closes Container
                ); // Closes InkWell
              },
              childCount: _getFiltered(provider).length,
            ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}
