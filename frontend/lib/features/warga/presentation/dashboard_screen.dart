import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/molecules/custom_bottom_navbar.dart';
import '../../../../widgets/molecules/custom_top_app_bar.dart';
import '../../admin/presentation/inbox_screen.dart';
import '../../admin/presentation/finance_screen.dart';
import '../../admin/presentation/profile_screen.dart';

class WargaDashboardScreen extends StatefulWidget {
  const WargaDashboardScreen({super.key});

  @override
  State<WargaDashboardScreen> createState() => _WargaDashboardScreenState();
}

class _WargaDashboardScreenState extends State<WargaDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
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
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeOverview(context);
      case 1:
        return const InboxScreen();
      case 2:
        return const FinanceScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeOverview(context);
    }
  }

  Widget _buildHomeOverview(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Implement refresh logic if needed
      },
      color: AppColors.primaryGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildKeuanganCard(),
            const SizedBox(height: 24),
            _buildMenuUtama(),
            const SizedBox(height: 32),
            _buildSectionHeader('Pembaruan Komunitas', 'Lihat Semua'),
            const SizedBox(height: 16),
            _buildKomunitasCard(
              'RAPAT RT',
              'Hari ini, 20:30 WIB',
              'Koordinasi Bulanan Warga & Pengarahan Keamanan',
              'Agenda: Persiapan HUT RI ke-78 dan jadwal baru pengelolaan sampah...',
              Colors.greenAccent.shade700,
            ),
            const SizedBox(height: 16),
            _buildKomunitasCard(
              'PERBAIKAN',
              '24 Apr 2023',
              'Perbaikan Paving Block di Blok C & D',
              'Penutupan jalan sementara akan dilakukan pukul 09:00 hingga 15:00 WIB. Mohon...',
              Colors.tealAccent.shade700,
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Pantauan CCTV', null),
            const SizedBox(height: 16),
            _buildCCTVCard(),
            const SizedBox(height: 32),
            _buildSectionHeader('Fasilitas Warga', 'Cek ketersediaan dan pesan'),
            const SizedBox(height: 16),
            _buildFasilitasGrid(),
            const SizedBox(height: 32),
            _buildSuratBanner(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }



  Widget _buildKeuanganCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Keuangan Warga', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBD5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'MENUNGGU',
                  style: TextStyle(color: Color(0xFFD4822B), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'IDR 150.000',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
          ),
          const Text(
            'Jatuh tempo 10 Okt 2023',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const Text(
            '• Iuran Keamanan & Kebersihan',
            style: TextStyle(color: Colors.black87, fontSize: 12),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildKeuanganSubCard('SALDO KOMUNITAS', 'IDR 42.5Jt')),
              const SizedBox(width: 12),
              Expanded(child: _buildKeuanganSubCard('TRANSAKSI', 'Terdiaudit', subtitle: 'Diperbarui 2 hari lalu')),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CB050),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: const Text('Bayar Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade100),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Liat Riwayat', style: TextStyle(color: Color(0xFF4CB050), fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildKeuanganSubCard(String title, String value, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 8, color: Colors.grey)),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuUtama() {
    return Column(
      children: [
        _buildMenuTile(Icons.description_outlined, 'Persuratan', 'Surat Domisili, dsb.', const Color(0xFFE0FAF2)),
        const SizedBox(height: 12),
        _buildMenuTile(Icons.campaign_outlined, 'Lapor Masalah', 'Sampah, Lampu, Keamanan', const Color(0xFFE7F9F5)),
        const SizedBox(height: 12),
        _buildMenuTile(Icons.handyman_outlined, 'Booking Fasilitas', 'Clubhouse, Lapangan Olahraga', const Color(0xFFFFF7EA)),
      ],
    );
  }

  Widget _buildMenuTile(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: Colors.teal.shade700),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (action != null && action != 'Lihat Semua')
              Text(action, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        if (action == 'Lihat Semua')
          Text(action!, style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildKomunitasCard(String tag, String date, String title, String desc, Color tagColor) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            width: double.infinity,
            color: Colors.black26,
            child: const Center(
              child: Text('RV', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: tagColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(tag, style: TextStyle(color: tagColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text(date, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCCTVCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            color: Colors.black,
            child: Stack(
              children: [
                Center(
                  child: Icon(Icons.videocam_outlined, color: Colors.white.withOpacity(0.5), size: 40),
                ),
                const Positioned(
                  left: 16, top: 16,
                  child: Text('GERBANG 01 PINTU UTARA', style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
                const Positioned(
                  right: 16, bottom: 16,
                  child: Text('2023-10-05 09:30:21', style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
                Positioned(
                  left: 16, bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.fullscreen, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFFE8ECEF),
            child: Row(
              children: [
                Expanded(child: _buildCCTVButton('Pindah ke Gerbang 02')),
                const SizedBox(width: 12),
                Expanded(child: _buildCCTVButton('Area Taman')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCCTVButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFasilitasGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildFasilitasTile(Icons.pool, 'Kolam Renang', 'Tersedia', const Color(0xFFE0FAF2), Colors.teal),
        _buildFasilitasTile(Icons.sports_tennis, 'Lapangan Tenis', 'Dipakai', const Color(0xFFF1FDF4), Colors.green),
        _buildFasilitasTile(Icons.business_outlined, 'Gedung Serbaguna', 'Tersedia', const Color(0xFFF7F1FF), Colors.purple),
        _buildFasilitasTile(Icons.child_care, 'Taman Bermain', 'Buka', const Color(0xFFFFF7EA), Colors.orange),
      ],
    );
  }

  Widget _buildFasilitasTile(IconData icon, String title, String status, Color color, Color iconColor) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text(status, style: TextStyle(fontSize: 10, color: iconColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSuratBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7F5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text('Butuh surat pengantar khusus?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E7D32))),
          const SizedBox(height: 8),
          const Text(
            'Lewati antrean. Ajukan surat pengantar RT/RW digital langsung dari ponsel Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CB050),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text('Ajukan Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

}

