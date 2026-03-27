import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../auth/logic/auth_provider.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  String _selectedCategory = 'Semua';

  List<Map<String, dynamic>> _getCategories(bool isRW) {
    if (isRW) {
      return [
        {'name': 'Semua', 'count': null},
        {'name': 'Keuangan RT', 'count': null},
        {'name': 'Koordinasi', 'count': null},
        {'name': 'Warga', 'count': null},
      ];
    } else {
      return [
        {'name': 'Semua', 'count': null},
        {'name': 'Aspirasi', 'count': null},
        {'name': 'Permohonan', 'count': null},
        {'name': 'RW 08', 'count': null},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final categories = _getCategories(auth.isRW);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              auth.isRW ? 'PUSAT INFORMASI' : 'KOTAK MASUK KETUA RT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen.withOpacity(0.8),
                letterSpacing: 1.2,
              ),
            ),
            if (auth.isRT) ...[
              const SizedBox(height: 8),
              const Text(
                'Pantau aspirasi warga dan instruksi koordinasi wilayah dalam satu pintu digital.',
                style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
              ),
            ],
            const SizedBox(height: 24),

            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    icon: auth.isRW ? Icons.mail_outline_rounded : Icons.pending_actions_rounded,
                    label: auth.isRW ? 'UNREAD' : 'STATUS TINDAK LANJUT',
                    value: auth.isRW ? '12 Pesan' : '85%',
                    isDark: false,
                    showProgress: auth.isRT,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    icon: auth.isRW ? Icons.bolt_rounded : Icons.emoji_events_outlined,
                    label: auth.isRW ? 'URGENT' : 'TARGET RT PINTAR',
                    value: auth.isRW ? '3 Laporan' : 'LEVEL 4',
                    isDark: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) => _buildFilterChip(cat['name'] as String)).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Message List
            if (auth.isRW) ...[
              _buildMessageItem(
                title: 'Laporan Keuangan RT 04',
                sender: 'Bapak Rahardi (Ketua RT 04)',
                snippet: 'Mohon izin Pak RW, berikut kami lampirkan rekapitulasi iuran warga RT...',
                time: '10:45 AM',
                statusColor: Colors.redAccent,
                icon: Icons.assignment_outlined,
                actions: [Icons.archive_outlined, Icons.reply_rounded],
              ),
              const SizedBox(height: 16),
              _buildMessageItem(
                title: 'Koordinasi HUT RI',
                sender: 'Panitia 17-an (Sdr. Dimas)',
                snippet: 'Update progres lomba: Lapangan bulutangkis sudah siap digunakan...',
                time: '08:12 AM',
                statusColor: Colors.green,
                icon: Icons.celebration_outlined,
                actions: [Icons.star_outline_rounded, Icons.ios_share_rounded],
              ),
            ] else ...[
              _buildMessageItem(
                title: 'Pengajuan Surat Domisili',
                sender: 'Bp. Ahmad (Blok C-12)',
                snippet: 'Selamat siang Pak RT, saya ingin mengajukan surat domisili untuk...',
                time: '09:30 AM',
                statusColor: Colors.orangeAccent,
                icon: Icons.description_outlined,
                actions: [Icons.check_circle_outline_rounded, Icons.close_rounded],
              ),
              const SizedBox(height: 16),
              _buildMessageItem(
                title: 'Aspirasi: Perbaikan Lampu Gg. 3',
                sender: 'Ibu Siti (Warga RT 04)',
                snippet: 'Pak RT, lampu jalan di depan rumah no 42 mati sudah 3 hari...',
                time: '08:15 AM',
                statusColor: AppColors.primaryGreen,
                icon: Icons.lightbulb_outline_rounded,
                actions: [Icons.reply_rounded],
              ),
              const SizedBox(height: 16),
              _buildMessageItem(
                title: 'Instruksi: Kerja Bakti Serentak',
                sender: 'Ketua RW 08 (Bapak Heru)',
                snippet: 'Diharapkan seluruh RT dapat menggerakkan warganya pada hari Minggu...',
                time: 'Kemarin',
                statusColor: Colors.blueAccent,
                icon: Icons.campaign_outlined,
                isRead: true,
                actions: [Icons.priority_high_rounded],
              ),
            ],
            const SizedBox(height: 16),
            _buildMessageItem(
              title: auth.isRW ? 'Pengumuman Kerja Bakti RW' : 'Konfirmasi Iuran Keamanan',
              sender: auth.isRW ? 'Sekretaris RW (Ibu Maya)' : 'Sdr. Rizky (Bendahara)',
              snippet: auth.isRW ? 'Draft pengumuman untuk seluruh RT sudah siap dipublikasikan...' : 'Pak, iuran keamanan Blok B sudah terkumpul 100%...',
              time: 'Kemarin',
              statusColor: AppColors.primaryGreen,
              icon: auth.isRW ? Icons.campaign_outlined : Icons.account_balance_wallet_outlined,
              isRead: true,
              actions: [Icons.check_circle_outline_rounded],
            ),
            const SizedBox(height: 16),
            _buildMessageItem(
              title: 'Surat Pengantar - RT 02',
              sender: 'Ibu Anita (Bendahara RT 02)',
              snippet: 'Ada pengajuan surat keterangan domisili dari Warga (Bp. Slamet). Mohon...',
              time: 'Kemarin',
              statusColor: Colors.orangeAccent,
              icon: Icons.description_outlined,
              actions: [Icons.file_download_outlined],
            ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    bool showProgress = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primaryGreen.withOpacity(0.9) : const Color(0xFFF1F5F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isDark ? Colors.white : AppColors.primaryGreen, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white.withOpacity(0.7) : Colors.grey,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          if (showProgress) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: const LinearProgressIndicator(
                value: 0.85,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                minHeight: 3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.greenAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.green.shade900,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem({
    required String title,
    required String sender,
    required String snippet,
    required String time,
    required Color statusColor,
    required IconData icon,
    bool isRead = false,
    List<IconData> actions = const [],
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: statusColor, size: 20),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            time,
                            style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isRead ? FontWeight.bold : FontWeight.w800,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sender,
                      style: const TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snippet,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions.map((aIcon) => Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Icon(aIcon, color: Colors.grey.shade400, size: 20),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
