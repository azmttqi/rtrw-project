import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/atoms/custom_button.dart';
import '../../../../widgets/molecules/custom_bottom_navbar.dart';
import '../../../../widgets/molecules/custom_top_app_bar.dart';
import '../../auth/logic/auth_provider.dart';
import './inbox_screen.dart';
import './finance_screen.dart';
import './profile_screen.dart';
import '../../announcements/presentation/create_announcement_screen.dart';
import '../../announcements/presentation/widgets/announcement_detail_modal.dart';
import '../logic/dashboard_provider.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchStats();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isVerified) {
      return _buildUnverifiedScreen(context);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const CustomTopAppBar(),
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: _currentIndex == 0 
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateAnnouncementScreen()),
                ).then((_) {
                  if (context.mounted) {
                    context.read<DashboardProvider>().fetchStats();
                  }
                });
              },
              backgroundColor: AppColors.primaryGreen,
              elevation: 4,
              child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 28),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => context.read<DashboardProvider>().fetchStats(),
        color: AppColors.primaryGreen,
        child: _buildBody(context, authProvider),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AuthProvider auth) {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardOverview(context, auth);
      case 1:
        return const InboxScreen();
      case 2:
        return const FinanceScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildDashboardOverview(context, auth);
    }
  }

  Widget _buildDashboardOverview(BuildContext context, AuthProvider auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Text(
            'OVERVIEW DASHBOARD',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen.withOpacity(0.8),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_getGreeting()}, ${auth.isRW ? "Ketua RW" : "Ketua RT"}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryLight,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          
          if (auth.isRW) ...[
            _buildRWDashboard(context, auth),
          ] else ...[
            _buildRTDashboard(context, auth),
          ],
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRWDashboard(BuildContext context, AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kelola harmoni dan administrasi lingkungan dengan satu sentuhan presisi digital.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondaryLight,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(
                DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        Consumer<DashboardProvider>(
          builder: (context, dashboard, _) {
            final stats = dashboard.stats;
            final isLoading = dashboard.isLoading;

            if (isLoading && stats == null) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
            }

            final totalRT = stats?['totalRT']?.toString() ?? '0';
            final totalWarga = stats?['totalWarga']?.toString() ?? '0';
            final totalBalance = NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(stats?['totalBalance'] ?? 0);

            final latestAnnouncements = stats?['latestAnnouncements'] as List? ?? [];
            final rtFinancialStatus = stats?['rtFinancialStatus'] as List? ?? [];
            final latestComplaints = stats?['latestComplaints'] as List? ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatCard(
                  label: 'Total Unit RT',
                  value: totalRT,
                  icon: Icons.menu_rounded,
                  tag: 'Aktif',
                  tagColor: Colors.greenAccent,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  label: 'Total Warga',
                  value: totalWarga,
                  icon: Icons.groups_rounded,
                  isWarga: true,
                ),
                const SizedBox(height: 16),
                _buildDarkStatCard(
                  label: 'Saldo Kas RW',
                  value: totalBalance,
                  trend: 'Teraktual',
                ),
                
                const SizedBox(height: 32),

                // Layer 2: Announcement Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pengumuman Terpusat',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/announcements'),
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (latestAnnouncements.isNotEmpty)
                  latestAnnouncements[0]['foto_url'] != null && latestAnnouncements[0]['foto_url'].toString().isNotEmpty
                    ? _buildFeaturedAnnouncement(latestAnnouncements[0])
                    : _buildMinorAnnouncement(latestAnnouncements[0])
                else
                  _buildEmptyState('Belum ada pengumuman.'),
                
                if (latestAnnouncements.length > 1) ...[
                  const SizedBox(height: 16),
                  ...latestAnnouncements.skip(1).map((a) => _buildMinorAnnouncement(a)).toList(),
                ],
                const SizedBox(height: 32),

                // Layer 3: RT Financial Status
                const Text(
                  'Status Keuangan RT',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildFinancialStatusList(rtFinancialStatus),
                const SizedBox(height: 32),

                // Layer 4: Aspirasi
                _buildAspirationSection(latestComplaints),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRTDashboard(BuildContext context, AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monitoring RT 04 / RW 08 • Green Garden Residence',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondaryLight,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(
                'Friday, 27 March 2026',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),        Consumer<DashboardProvider>(
          builder: (context, dashboard, _) {
            final stats = dashboard.stats;
            final isLoading = dashboard.isLoading;

            if (isLoading && stats == null) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
            }

            final totalWarga = stats?['totalWarga']?.toString() ?? '0';
            final totalBalance = NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(stats?['totalBalance'] ?? 0);
            final pendingApprovals = stats?['totalPendingApprovals']?.toString() ?? '0';

            return Column(
              children: [
                // Green Residents Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL RESIDENTS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        totalWarga,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.trending_up, color: Colors.greenAccent, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Real-time data',
                            style: TextStyle(fontSize: 12, color: Colors.greenAccent.withOpacity(0.8)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSubStat(totalWarga, 'RESIDENTS\nTOTAL'),
                          _buildSubStat('-', 'MALE'),
                          _buildSubStat('-', 'FEMALE'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildAgeDistribution(),
                const SizedBox(height: 32),

                // Community Fund Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'COMMUNITY FUND',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalBalance,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimaryLight),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Status', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          const Text('Terverifikasi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          value: 1.0,
                          minHeight: 8,
                          backgroundColor: Color(0xFFF1F1F1),
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: const Color(0xFFF8F9F8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'View Ledger',
                            style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Pending Approvals
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pending Approvals',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$pendingApprovals ACTIONS',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        _buildApprovalItem('Aditya Wijaya', 'New Resident • Block C-12'),
        _buildApprovalItem('Siti Aminah', 'Address Change • Block A-05 to B-02'),
        _buildApprovalItem('Budi Santoso', 'Venue Booking • Community Center • Oct 28'),
        const SizedBox(height: 32),

        // Gate Monitoring
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Gate Monitoring',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCameraGrid(),
      ],
    );
  }

  Widget _buildSubStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 8, color: Colors.white.withOpacity(0.5), letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildApprovalItem(String name, String detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
            child: const Icon(Icons.person_add_rounded, color: AppColors.primaryGreen, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(detail, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Row(
            children: [
              _buildApprovalButton('Decline', Colors.grey.shade100, Colors.grey.shade700),
              const SizedBox(width: 8),
              _buildApprovalButton('Approve', AppColors.primaryGreen, Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalButton(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildCameraGrid() {
    return Column(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1557597774-9d273605dfa9?q=80&w=2044&auto=format&fit=crop'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(4)),
                  child: const Text('CAM_01 • MAIN GATE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
              const Center(child: Icon(Icons.play_circle_fill_rounded, color: Colors.white38, size: 48)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSmallCamera('SIDE_A', 'https://images.unsplash.com/photo-1558002038-103792e37483?q=80&w=2040')),
            const SizedBox(width: 12),
            Expanded(child: _buildSmallCamera('BACK_B', 'https://images.unsplash.com/photo-1620067925053-bc26900e5e01?q=80&w=2040')),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.videocam_rounded, size: 18),
            label: const Text('View All Cameras'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallCamera(String label, String url) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(4)),
              child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeDistribution() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AGE DISTRIBUTION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          _buildAgeRow('0-17', '22%'),
          _buildAgeRow('18-60', '64%'),
          _buildAgeRow('60+', '14%'),
          const SizedBox(height: 12),
          Text(
            'Productive age residents are dominant this quarter.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeRow(String label, String percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          Text(
            percent,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    String? tag,
    Color? tagColor,
    bool isWarga = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryGreen, size: 20),
              ),
              if (tag != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: tagColor!.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                  ),
                )
              else if (isWarga)
                const SizedBox(
                  width: 32,
                  child: Stack(
                    children: [
                      CircleAvatar(radius: 10, backgroundColor: Colors.blueGrey),
                      Positioned(
                        left: 12,
                        child: CircleAvatar(radius: 10, backgroundColor: Colors.grey),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkStatCard({
    required String label,
    required String value,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3436),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.greenAccent, size: 20),
              ),
              Text(
                trend,
                style: const TextStyle(fontSize: 10, color: Colors.greenAccent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedAnnouncement(dynamic data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              data['foto_url'] ?? 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?q=80&w=2013&auto=format&fit=crop',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          data['created_at'] != null 
                            ? data['created_at'].toString().split('T')[0] 
                            : 'Baru saja', 
                          style: const TextStyle(fontSize: 10, color: Colors.grey)
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.push_pin_outlined, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          data['nomor_rt'] != null ? 'RT ${data['nomor_rt']}' : 'SEMUA RW', 
                          style: const TextStyle(fontSize: 10, color: Colors.grey)
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  data['judul'] ?? 'No Title',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.3),
                ),
                const SizedBox(height: 8),
                Text(
                  data['konten'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    AnnouncementDetailModal.show(
                      context,
                      title: data['judul'] ?? 'No Title',
                      content: data['konten'] ?? '',
                      isKegiatan: data['is_kegiatan'] == true,
                      tanggalKegiatan: data['tanggal_kegiatan']?.toString(),
                      createdAtStr: data['created_at']?.toString().split('T')[0],
                      fotoUrl: data['foto_url'],
                    );
                  },
                  child: Row(
                    children: [
                      const Text('Baca Selengkapnya', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryGreen, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinorAnnouncement(dynamic data) {
    return InkWell(
      onTap: () {
        AnnouncementDetailModal.show(
          context,
          title: data['judul'] ?? 'No Title',
          content: data['konten'] ?? '',
          isKegiatan: data['is_kegiatan'] == true,
          tanggalKegiatan: data['tanggal_kegiatan']?.toString(),
          createdAtStr: data['created_at']?.toString().split('T')[0],
          fotoUrl: data['foto_url'],
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(
                data['is_kegiatan'] == true ? Icons.event_note : Icons.campaign_outlined, 
                color: AppColors.primaryGreen, 
                size: 24
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['is_kegiatan'] == true ? 'KEGIATAN' : 'PENGUMUMAN', 
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)
                  ),
                  Text(
                    data['judul'] ?? '', 
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    data['konten'] ?? '', 
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialStatusList(List statusList) {
    if (statusList.isEmpty) return _buildEmptyState('Data RT belum tersedia.');
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ...statusList.map((item) {
            final rt = item['rt']?.toString() ?? 'RT ??';
            final percentage = double.tryParse(item['percentage']?.toString() ?? '0') ?? 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildFinancialRow(rt, percentage, percentage > 0.5 ? Colors.green : Colors.orange),
            );
          }).toList(),
          const SizedBox(height: 8),
          CustomButton(
            text: 'Laporan Detail Keuangan',
            variant: ButtonVariant.google,
            onPressed: () {
              setState(() {
                _currentIndex = 2; // Ke Tab Finance
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String rt, double percentage, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(rt, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${(percentage * 100).toInt()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAspirationSection(List complaints) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                   Icon(Icons.feed_outlined, color: AppColors.primaryGreen, size: 20),
                   SizedBox(width: 8),
                   Text('Aspirasi Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 1; // Ke Tab Inbox
                  });
                },
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (complaints.isEmpty)
             _buildEmptyState('Belum ada aspirasi masuk.')
          else
            ...complaints.map((c) => _buildAspirationItem(
              c['pelapor_nama'] ?? 'Warga', 
              'RT ${c['nomor_rt']}', 
              c['judul'] ?? 'No Title'
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(Icons.info_outline, color: Colors.grey.shade400, size: 32),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildAspirationItem(String name, String detail, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                child: const Icon(Icons.person, size: 14, color: AppColors.primaryGreen),
              ),
              const SizedBox(width: 8),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const Spacer(),
              Text(detail, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 13, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildUnverifiedScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pending_actions_rounded, size: 100, color: Colors.orange),
              const SizedBox(height: 24),
              const Text(
                'Akun Menunggu Verifikasi',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Akun Anda sedang ditinjau oleh pengurus di atas Anda. Silakan hubungi pengurus terkait atau tunggu hingga diverifikasi.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 48),
              CustomButton(
                text: 'KELUAR',
                onPressed: () => context.read<AuthProvider>().logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
