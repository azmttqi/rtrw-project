import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../auth/logic/auth_provider.dart';
import '../data/inbox_service.dart';
import '../../announcements/presentation/widgets/announcement_detail_modal.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final InboxService _service = InboxService();

  List<Map<String, dynamic>> _duesNotifs = [];
  List<Map<String, dynamic>> _announcements = [];
  List<Map<String, dynamic>> _letters = [];

  bool _loadingDues = true;
  bool _loadingAnnouncements = true;
  bool _loadingLetters = true;

  String? _errorDues;
  String? _errorAnnouncements;
  String? _errorLetters;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    final token = context.read<AuthProvider>().token ?? '';
    _fetchDues(token);
    _fetchAnnouncements(token);
    _fetchLetters(token);
  }

  Future<void> _fetchDues(String token) async {
    setState(() { _loadingDues = true; _errorDues = null; });
    try {
      final data = await _service.getDuesNotifications(token);
      setState(() { _duesNotifs = data; _loadingDues = false; });
    } catch (e) {
      setState(() { _errorDues = e.toString(); _loadingDues = false; });
    }
  }

  Future<void> _fetchAnnouncements(String token) async {
    setState(() { _loadingAnnouncements = true; _errorAnnouncements = null; });
    try {
      final data = await _service.getAnnouncements(token);
      setState(() { _announcements = data; _loadingAnnouncements = false; });
    } catch (e) {
      setState(() { _errorAnnouncements = e.toString(); _loadingAnnouncements = false; });
    }
  }

  Future<void> _fetchLetters(String token) async {
    setState(() { _loadingLetters = true; _errorLetters = null; });
    try {
      final data = await _service.getLetterInbox(token);
      setState(() { _letters = data; _loadingLetters = false; });
    } catch (e) {
      setState(() { _errorLetters = e.toString(); _loadingLetters = false; });
    }
  }

  Future<void> _verifyLetter(int letterId, String status) async {
    final token = context.read<AuthProvider>().token ?? '';
    try {
      await _service.verifyLetter(token, letterId, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 'APPROVED' ? 'Surat telah disetujui' : 'Surat telah ditolak'),
          backgroundColor: status == 'APPROVED' ? AppColors.primaryGreen : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _fetchLetters(token);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auth.isRW ? 'PUSAT KOORDINASI' : 'KOTAK MASUK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen.withOpacity(0.8),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Inbox',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimaryLight),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    auth.isRW
                        ? 'Pantau keuangan RT, pengumuman, dan surat menyurat.'
                        : 'Pantau iuran warga, pengumuman, dan permohonan surat.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // TabBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade500,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Keuangan'),
                    Tab(text: 'Pengumuman'),
                    Tab(text: 'Surat'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDuesTab(),
                  _buildAnnouncementsTab(),
                  _buildLettersTab(auth),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  // TAB 1: KEUANGAN
  // ────────────────────────────────────────────────
  Widget _buildDuesTab() {
    if (_loadingDues) return const Center(child: CircularProgressIndicator());
    if (_errorDues != null) return _buildError(_errorDues!, () => _fetchDues(context.read<AuthProvider>().token ?? ''));
    if (_duesNotifs.isEmpty) return _buildEmpty('Belum ada data keuangan.');

    return RefreshIndicator(
      onRefresh: () => _fetchDues(context.read<AuthProvider>().token ?? ''),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        itemCount: _duesNotifs.length,
        itemBuilder: (context, index) {
          final item = _duesNotifs[index];
          final status = item['status'] as String? ?? 'BELUM_BAYAR';
          final isLunas = status == 'LUNAS';
          final isUrgent = status == 'HAMPIR_JATUH_TEMPO';

          Color statusColor = isLunas ? AppColors.primaryGreen
              : isUrgent ? Colors.orangeAccent
              : Colors.redAccent;
          IconData statusIcon = isLunas ? Icons.check_circle_outline_rounded
              : isUrgent ? Icons.warning_amber_rounded
              : Icons.cancel_outlined;
          String statusLabel = isLunas ? 'LUNAS'
              : isUrgent ? 'HAMPIR JATUH TEMPO'
              : 'BELUM BAYAR';

          final String nama = item['nama_ketua_rt'] ?? item['nama_kepala_keluarga'] ?? '-';
          final String sub = item['nomor_rt'] != null
              ? 'RT ${item['nomor_rt']}'
              : 'KK: ${item['no_kk'] ?? '-'}';
          final num nominal = item['nominal'] ?? 0;
          final int bulan = item['bulan'] ?? 0;
          final int tahun = item['tahun'] ?? 0;
          final int? sisaHari = item['hari_tersisa'] as int?;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), bottomLeft: Radius.circular(18)),
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
                              Row(
                                children: [
                                  Icon(statusIcon, color: statusColor, size: 16),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
                                  ),
                                ],
                              ),
                              Text(
                                _bulanName(bulan) + ' $tahun',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Rp ${NumberFormat('#,###', 'id').format(nominal)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                              ),
                              if (!isLunas && sisaHari != null)
                                Text(
                                  sisaHari >= 0 ? 'Jatuh tempo: $sisaHari hari lagi' : 'Terlambat ${-sisaHari} hari',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: sisaHari < 0 ? Colors.red : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (isLunas && item['dibayar_pada'] != null)
                                Text(
                                  'Bayar: ${item['dibayar_pada'].toString().split('T')[0]}',
                                  style: TextStyle(fontSize: 11, color: AppColors.primaryGreen),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ────────────────────────────────────────────────
  // TAB 2: PENGUMUMAN
  // ────────────────────────────────────────────────
  Widget _buildAnnouncementsTab() {
    if (_loadingAnnouncements) return const Center(child: CircularProgressIndicator());
    if (_errorAnnouncements != null) return _buildError(_errorAnnouncements!, () => _fetchAnnouncements(context.read<AuthProvider>().token ?? ''));
    if (_announcements.isEmpty) return _buildEmpty('Belum ada pengumuman.');

    return RefreshIndicator(
      onRefresh: () => _fetchAnnouncements(context.read<AuthProvider>().token ?? ''),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        itemCount: _announcements.length,
        itemBuilder: (context, index) {
          final item = _announcements[index];
          final isKegiatan = item['is_kegiatan'] == true;

          return InkWell(
            onTap: () => AnnouncementDetailModal.show(
              context,
              title: item['judul'] ?? '',
              content: item['konten'] ?? '',
              category: item['kategori'],
              fotoUrl: item['foto_url'],
              isKegiatan: isKegiatan,
              tanggalKegiatan: item['tanggal_kegiatan']?.toString(),
              createdAtStr: item['created_at']?.toString().split('T')[0],
            ),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isKegiatan ? AppColors.primaryYellow.withOpacity(0.15) : AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isKegiatan ? Icons.event_note_rounded : Icons.campaign_outlined,
                      color: isKegiatan ? const Color(0xFF856404) : AppColors.primaryGreen,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isKegiatan ? 'KEGIATAN' : 'PENGUMUMAN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isKegiatan ? const Color(0xFF856404) : AppColors.primaryGreen,
                          ),
                        ),
                        Text(item['judul'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(item['konten'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item['created_at']?.toString().split('T')[0] ?? '',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                      ),
                      const SizedBox(height: 4),
                      const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ────────────────────────────────────────────────
  // TAB 3: SURAT
  // ────────────────────────────────────────────────
  Widget _buildLettersTab(AuthProvider auth) {
    if (_loadingLetters) return const Center(child: CircularProgressIndicator());
    if (_errorLetters != null) return _buildError(_errorLetters!, () => _fetchLetters(auth.token ?? ''));
    if (_letters.isEmpty) return _buildEmpty('Tidak ada permohonan surat.');

    return RefreshIndicator(
      onRefresh: () => _fetchLetters(auth.token ?? ''),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        itemCount: _letters.length,
        itemBuilder: (context, index) {
          final item = _letters[index];
          final status = item['status'] as String? ?? '';
          final canApprove = (auth.isRW && status == 'APPROVED_RT_PENDING_RW') ||
                             (auth.isRT && status == 'PENDING_RT');

          Color statusColor;
          String statusLabel;
          switch (status) {
            case 'PENDING_RT': statusColor = Colors.orangeAccent; statusLabel = 'Menunggu RT'; break;
            case 'APPROVED_RT_PENDING_RW': statusColor = Colors.blue; statusLabel = 'Menunggu RW'; break;
            case 'APPROVED_RW': statusColor = AppColors.primaryGreen; statusLabel = 'Disetujui RW'; break;
            case 'REJECTED_RT': statusColor = Colors.redAccent; statusLabel = 'Ditolak RT'; break;
            case 'REJECTED_RW': statusColor = Colors.redAccent; statusLabel = 'Ditolak RW'; break;
            default: statusColor = Colors.grey; statusLabel = status;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), bottomLeft: Radius.circular(18)),
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              Text(
                                item['created_at']?.toString().split('T')[0] ?? '',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(item['jenis_surat'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(
                            'Pemohon: ${item['pemohon_nama'] ?? '-'}${item['nomor_rt'] != null ? ' (RT ${item['nomor_rt']})' : ''}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                          if ((item['keterangan_keperluan'] as String? ?? '').isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              item['keterangan_keperluan'],
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (canApprove) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _showConfirmDialog(item['id'], 'REJECTED'),
                                  icon: const Icon(Icons.close_rounded, size: 16),
                                  label: const Text('Tolak'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                    side: const BorderSide(color: Colors.redAccent),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _showConfirmDialog(item['id'], 'APPROVED'),
                                  icon: const Icon(Icons.check_rounded, size: 16),
                                  label: const Text('Setujui'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGreen,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showConfirmDialog(dynamic letterId, String status) {
    final isApprove = status == 'APPROVED';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isApprove ? 'Setujui Surat?' : 'Tolak Surat?'),
        content: Text(isApprove
            ? 'Surat ini akan diteruskan dan disetujui. Yakin?'
            : 'Surat ini akan ditolak. Yakin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _verifyLetter(letterId is int ? letterId : int.parse(letterId.toString()), status);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? AppColors.primaryGreen : Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isApprove ? 'Setujui' : 'Tolak', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────
  Widget _buildEmpty(String message) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.inbox_rounded, size: 52, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(message, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
      ],
    ),
  );

  Widget _buildError(String error, VoidCallback retry) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: AppColors.error, size: 48),
        const SizedBox(height: 12),
        Text(error, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: retry,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
          child: const Text('Coba Lagi'),
        ),
      ],
    ),
  );

  String _bulanName(int bulan) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return bulan >= 1 && bulan <= 12 ? months[bulan] : '-';
  }
}
