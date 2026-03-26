import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/atoms/custom_button.dart';
import '../../auth/logic/auth_provider.dart';
import '../data/admin_service.dart';
import './warga_verification_screen.dart';
import './rt_verification_screen.dart';
import './invitation_management_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _currentMenu = 'Dashboard';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isVerified) {
      return _buildUnverifiedScreen(context);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Sidebar
            Expanded(
              flex: 2,
              child: _buildSidebar(context, authProvider),
            ),
            // Right Content Area
            Expanded(
              flex: 8,
              child: _buildContent(context, authProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AuthProvider auth) {
    switch (_currentMenu) {
      case 'Verifikasi':
        return _buildVerificationView(context, auth);
      case 'Daftar RT':
      case 'Daftar Warga':
        return _buildUserListView(context, auth);
      case 'Dashboard':
      default:
        return _buildDashboardOverview(context, auth);
    }
  }

  Widget _buildSidebar(BuildContext context, AuthProvider auth) {
    return Container(
      color: AppColors.primaryGreen,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.home_filled, color: Colors.white, size: 32),
                const SizedBox(height: 16),
                Text(
                  auth.isRW ? 'Administrator\nRW' : 'Pengurus\nRT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildSidebarItem(Icons.dashboard_rounded, 'Dashboard'),
          _buildSidebarItem(Icons.group_rounded, auth.isRW ? 'Daftar RT' : 'Daftar Warga'),
          _buildSidebarItem(Icons.verified_user_rounded, 'Verifikasi'),
          _buildSidebarItem(Icons.share_rounded, 'Undangan', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InvitationManagementScreen()),
            );
          }),
          _buildSidebarItem(Icons.campaign_rounded, 'Pengumuman'),
          _buildSidebarItem(Icons.payments_rounded, 'Iuran'),
          const Spacer(),
          _buildSidebarItem(Icons.logout_rounded, 'Keluar', onTap: () => auth.logout()),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, {VoidCallback? onTap}) {
    final isActive = _currentMenu == title;
    return GestureDetector(
      onTap: onTap ?? () => setState(() => _currentMenu = title),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(isActive ? 1.0 : 0.7), size: 24),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(isActive ? 1.0 : 0.7),
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardOverview(BuildContext context, AuthProvider auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(auth),
          const SizedBox(height: 16),
          const Text(
            'Ringkasan Lingkungan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInviterSection(context, auth),
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang,\n${auth.user?['nama'] ?? 'Pengurus'}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
                ),
                const SizedBox(height: 12),
                const Text('Lihat ringkasan kegiatan warga di lingkungan.', style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Kegiatan Cepat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip('Pengumuman Baru'),
              _buildChip('Cek Iuran'),
              _buildChip('Review Laporan'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationView(BuildContext context, AuthProvider auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(auth),
          const SizedBox(height: 16),
          const Text('Daftar Verifikasi Pending', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            auth.isRW ? 'Daftar Ketua RT yang memerlukan verifikasi Anda.' : 'Daftar Warga yang memerlukan verifikasi berkas.',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          _buildPendingList(context, auth),
        ],
      ),
    );
  }

  Widget _buildUserListView(BuildContext context, AuthProvider auth) {
    final title = auth.isRW ? 'Daftar Ketua RT' : 'Daftar Warga (Keluarga)';
    final subtitle = auth.isRW ? 'Daftar Ketua RT yang terdaftar aktif di RW ini.' : 'Daftar seluruh keluarga yang aktif di wilayah RT Anda.';

    return FutureBuilder<List<dynamic>>(
      future: auth.isRW ? adminService.getVerifiedRT() : adminService.getVerifiedWarga(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final items = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(auth),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              if (items.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: Text('Tidak ada data ditemukan.', style: TextStyle(color: Colors.grey)),
                ))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                          child: Icon(Icons.person, color: AppColors.primaryGreen),
                        ),
                        title: Text(item['nama'] ?? 'Tanpa Nama', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(auth.isRW ? 'Pengurus RT' : 'No KK: ${item['no_kk'] ?? '-'}'),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingList(BuildContext context, AuthProvider auth) {
    return FutureBuilder<Map<String, dynamic>>(
      future: auth.isRW ? adminService.getPendingRT() : adminService.getPendingWarga(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data?['data'] as Map<String, dynamic>?;
        final items = auth.isRW 
            ? (data?['users'] as List? ?? []) 
            : (data?['families'] as List? ?? []);

        if (items.isEmpty) {
          return const Center(child: Text('Tidak ada pengajuan pending.'));
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(backgroundColor: AppColors.primaryGreen.withOpacity(0.1), child: Icon(Icons.person, color: AppColors.primaryGreen)),
                title: Text(item['nama'] ?? 'Tanpa Nama', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(auth.isRW ? 'Calon Ketua RT' : 'Warga Baru - Klik Detail untuk Berkas'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => auth.isRW ? const RtVerificationScreen() : const WargaVerificationScreen()),
                      );
                    }, child: const Text('Detail', style: TextStyle(color: Colors.blue))),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          if (auth.isRW) {
                            await adminService.verifyRT(item['id'], true);
                          } else {
                            await adminService.verifyWarga(item['id'], 'APPROVED');
                          }
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil disetujui')));
                          setState(() {});
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                      child: const Text('Setujui', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(AuthProvider auth) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(auth.user?['nama'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryYellow.withOpacity(0.5),
            child: const Icon(Icons.person, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildInviterSection(BuildContext context, AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryYellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryYellow.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.share_rounded, color: AppColors.primaryGreen),
              const SizedBox(width: 12),
              Text(auth.isRW ? 'Undang Ketua RT Baru' : 'Undang Warga Baru', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Bagikan link di bawah ini kepada calon pengurus atau warga.', style: TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 20),
          CustomButton(
            text: 'KELOLA UNDANGAN', 
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvitationManagementScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: AppColors.primaryYellow.withOpacity(0.4), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 14)),
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
