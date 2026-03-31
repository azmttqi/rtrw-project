import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../auth/logic/auth_provider.dart';
import '../data/finance_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FinanceService _service = FinanceService();
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStats();
      context.read<AuthProvider>().refreshProfile();
    });
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    final token = context.read<AuthProvider>().token ?? '';
    try {
      final data = await _service.getDashboardStats(token);
      if (mounted) {
        setState(() {
          _stats = data;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final String nama = user?['nama'] ?? 'Pengguna';
    final String nomorRT = user?['nomor_rt']?.toString() ?? '-';
    final String nomorRW = user?['nomor_rw']?.toString() ?? '-';
    
    final String jabatan = authProvider.isRW
        ? 'Ketua RW $nomorRW • Kelurahan Menteng'
        : authProvider.isRT
            ? 'Ketua RT $nomorRT / RW $nomorRW • Green Garden'
            : 'Warga RT $nomorRT / RW $nomorRW • Green Garden';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadStats();
          if (mounted) await context.read<AuthProvider>().refreshProfile();
        },
        color: AppColors.primaryGreen,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
              const SizedBox(height: 20),
              // Profile Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryGreen.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(
                              'https://api.dicebear.com/7.x/avataaars/png?seed=$nama',
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      nama,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      jabatan,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBadge(
                          authProvider.isRW
                              ? 'VERIFIED OFFICIAL'
                              : (authProvider.isRT ? 'VERIFIKASI AKTIF' : 'WARGA TERVERIFIKASI'),
                          Colors.green.shade50,
                          Colors.green.shade700,
                        ),
                        const SizedBox(width: 8),
                        _buildBadge(
                          authProvider.isRW ? 'AKTIF' : (authProvider.isRT ? 'RT ROLE' : 'WARGA'),
                          authProvider.isRW
                              ? Colors.green.shade600
                              : AppColors.primaryGreen,
                          Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats Section
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      authProvider.isRW ? 'TOTAL RT DIAWASI' : (authProvider.isRT ? 'TOTAL WARGA RT' : 'WARGA SE-RT'),
                      _stats?['totalRT']?.toString() ?? (_stats?['totalWarga']?.toString() ?? '0'),
                      authProvider.isRW
                          ? 'Unit Rukun Tetangga Aktif'
                          : 'Jiwa terdaftar di database',
                      AppColors.primaryGreen,
                      Colors.white,
                      authProvider.isRW
                          ? Icons.grid_view_rounded
                          : Icons.people_outline_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      authProvider.isRW ? 'TOTAL WARGA TERDATA' : (authProvider.isRT ? 'LAPORAN AKTIF' : 'KONTRIBUSI'),
                      authProvider.isRW 
                          ? (_stats?['totalWarga']?.toString() ?? '-') 
                          : (authProvider.isRT 
                              ? (_stats?['totalPendingApprovals']?.toString() ?? '0')
                              : 'AKTIF'),
                      authProvider.isRW
                          ? 'Jiwa Terverifikasi di RW $nomorRW'
                          : (authProvider.isRT 
                              ? 'Butuh tindak lanjut segera'
                              : 'Partisipasi iuran aktif'),
                      const Color(0xFFE8F5E9),
                      AppColors.primaryGreen,
                      authProvider.isRW
                          ? Icons.people_alt_rounded
                          : (authProvider.isRT 
                              ? Icons.notification_important_outlined
                              : Icons.verified_user_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Menu Groups
              _buildMenuGroup('AKUN', [
                _buildMenuItem(
                  Icons.person_outline_rounded,
                  'Ubah Profil',
                  'Update foto dan data diri',
                ),
                _buildMenuItem(
                  Icons.shield_outlined,
                  'Pengaturan Keamanan',
                  'Kata sandi dan verifikasi',
                ),
              ]),
              const SizedBox(height: 24),
              _buildMenuGroup(
                authProvider.isRW ? 'ADMINISTRASI RW' : (authProvider.isRT ? 'ADMINISTRASI RT' : 'LAYANAN WARGA'),
                [
                  _buildMenuItem(
                    authProvider.isRW
                        ? Icons.map_outlined
                        : (authProvider.isRT ? Icons.people_alt_outlined : Icons.description_outlined),
                    authProvider.isRW
                        ? 'Detail Wilayah RW'
                        : (authProvider.isRT ? 'Data Kependudukan RT' : 'Permohonan Surat'),
                    authProvider.isRW
                        ? 'Denah dan batas administratif'
                        : (authProvider.isRT ? 'Manajemen data warga RT' : 'Ajukan surat pengantar digital'),
                  ),
                  _buildMenuItem(
                    authProvider.isRW
                        ? Icons.manage_accounts_outlined
                        : Icons.account_balance_wallet_outlined,
                    authProvider.isRW ? 'Kelola Akun RT' : 'Pengaturan Iuran RT',
                    authProvider.isRW
                        ? 'Manajemen pengurus RT'
                        : 'Konfigurasi tagihan bulanan',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildMenuGroup('BANTUAN & LAINNYA', [
                _buildMenuItem(
                  Icons.help_outline_rounded,
                  'Pusat Bantuan',
                  'Panduan penggunaan aplikasi',
                ),
                _buildMenuItem(
                  Icons.description_outlined,
                  'Syarat & Ketentuan',
                  'Legalitas dan kebijakan',
                ),
                _buildMenuItem(
                  Icons.logout_rounded,
                  'Keluar',
                  'Akhiri sesi aplikasi',
                  isDestructive: true,
                  onTap: () => _showLogoutDialog(context, authProvider),
                ),
              ]),

              const SizedBox(height: 40),
              const Text(
                'LINGKARWARGA v2.4.0-STABLE • CIVIC CONCIERGE SUITE',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String subLabel,
    Color bgColor,
    Color textColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (bgColor == AppColors.primaryGreen)
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: textColor.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, color: textColor.withOpacity(0.2), size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subLabel,
            style: TextStyle(
              fontSize: 10,
              color: textColor.withOpacity(0.6),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final color = isDestructive ? Colors.redAccent : AppColors.primaryGreen;

    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDestructive
                          ? Colors.redAccent
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Keluar Aplikasi?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Apakah Anda yakin ingin mengakhiri sesi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await authProvider.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Keluar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
