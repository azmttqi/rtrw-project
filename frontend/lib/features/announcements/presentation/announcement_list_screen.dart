import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../logic/announcement_provider.dart';

class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({super.key});

  @override
  State<AnnouncementListScreen> createState() => _AnnouncementListScreenState();
}

class _AnnouncementListScreenState extends State<AnnouncementListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<AnnouncementProvider>().fetchAnnouncements(),
    );
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
              ],
            ),
          ),
        ),

        if (provider.announcements.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey.shade400, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada pengumuman.',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // List of Announcements
        if (provider.announcements.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = provider.announcements[index];
                  final isLatest = index == 0;
                  
                  return Container(
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
                        if (isLatest)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                            child: Stack(
                              children: [
                                Image.network(
                                  'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?q=80&w=2013&auto=format&fit=crop',
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
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
                                      color: AppColors.primaryYellow.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      item.category?.toUpperCase() ?? 'PENGUMUMAN',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF856404),
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
                  );
                },
                childCount: provider.announcements.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}
