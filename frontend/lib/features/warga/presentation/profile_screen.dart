import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/logic/auth_provider.dart';

class WargaProfileScreen extends StatefulWidget {
  const WargaProfileScreen({super.key});

  @override
  State<WargaProfileScreen> createState() => _WargaProfileScreenState();
}

class _WargaProfileScreenState extends State<WargaProfileScreen> {
  Future<void> _refreshData() async {
    await context.read<AuthProvider>().refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final String nama = user?['nama'] ?? 'User';
    final String role = user?['role'] ?? 'WARGA';
    final String address = user?['alamat'] ?? 'Alamat belum diatur';
    final bool isVerified = user?['is_verified'] ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCF8),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFF076633),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const SizedBox(height: 32),

              // Profile Info Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF39C12),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.network(
                              'https://api.dicebear.com/7.x/avataaars/png?seed=$nama',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (isVerified)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CB050),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.verified, color: Colors.white, size: 14),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      nama,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B1B1B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          address,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isVerified ? const Color(0xFFC7EBCB) : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isVerified ? role : 'MENUNGGU VERIFIKASI',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isVerified ? const Color(0xFF076633) : Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Stats Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Warga',
                        'STATUS\nKEPENDUDUKAN',
                        Icons.home_outlined,
                        const Color(0xFFF1FDF4),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        isVerified ? 'Terverifikasi' : 'Proses',
                        'VERIFIKASI\nIDENTITAS',
                        Icons.verified_user_outlined,
                        isVerified ? const Color(0xFFE8F5E9) : Colors.orange.shade50,
                        isVerified: isVerified,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Menu Groups
              _buildMenuGroup('AKUN', [
                _buildMenuItem(Icons.person_outline, 'Ubah Profil'),
                _buildMenuItem(Icons.security_outlined, 'Pengaturan Keamanan'),
              ]),
              const SizedBox(height: 24),
              _buildMenuGroup('DATA WARGA', [
                _buildMenuItem(Icons.work_outline, 'Dokumen Saya', subtitle: 'KTP, KK, & Surat Nikah'),
                _buildMenuItem(Icons.people_outline, 'Anggota Keluarga'),
              ]),
              const SizedBox(height: 24),
              _buildMenuGroup('BANTUAN & LAINNYA', [
                _buildMenuItem(Icons.help_outline, 'Pusat Bantuan'),
                _buildMenuItem(Icons.home_outlined, 'Hubungi RT'),
                _buildMenuItem(Icons.logout, 'Keluar', isDestructive: true, onTap: () => _showLogoutDialog(context, authProvider)),
              ]),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String subtitle, IconData icon, Color bgColor, {bool isVerified = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF076633), size: 24),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: isVerified ? 16 : 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF076633),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: const Color(0xFF076633).withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGroup(String title, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE9EFEC),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {String? subtitle, bool isDestructive = false, VoidCallback? onTap}) {
    final color = isDestructive ? const Color(0xFFC0392B) : const Color(0xFF1B1B1B);
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isDestructive ? color : const Color(0xFF076633), size: 20),
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
                      color: color,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: isDestructive ? color.withOpacity(0.5) : Colors.grey.shade400, size: 18),
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
        title: const Text('Keluar Aplikasi?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin mengakhiri sesi ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC0392B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
