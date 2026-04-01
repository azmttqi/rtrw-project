import 'package:flutter/material.dart';

class WargaFinanceScreen extends StatelessWidget {
  const WargaFinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCF8),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const Text(
                'Keuangan Saya',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF076633),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Current Bill Card
            _buildCurrentBillCard(),
            const SizedBox(height: 24),

            // Community Fund Card
            _buildCommunityFundCard(),
            const SizedBox(height: 32),

            // Community Spending Section
            _buildSpendingSection(),
            const SizedBox(height: 24),

            // Audit Banner
            _buildAuditBanner(),
            const SizedBox(height: 32),

            // Payment History Section
            _buildPaymentHistory(),
            const SizedBox(height: 24),

            // Download Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.file_download_outlined, size: 20),
                  label: const Text('Unduh Rekap Tahunan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8ECEF),
                    foregroundColor: const Color(0xFF076633),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentBillCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF076633),
            Color(0xFF4CB050),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF076633).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TAGIHAN BULAN INI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Rp 150.000',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: const [
              Text(
                'Batas Waktu: ',
                style: TextStyle(fontSize: 13, color: Colors.white70),
              ),
              Text(
                '10 Oktober 2023',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                  label: const Text('Bayar Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF076633),
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.receipt_long_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 4),
                  const Text('Rincian', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityFundCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF076633),
            Color(0xFF4CB050),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'KAS WARGA TERKUMPUL',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Rp 12.450k',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Transparansi penuh untuk harmoni lingkungan kita.',
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.8,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF90FFB5)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {},
            child: const Row(
              children: [
                Text(
                  'Lihat Laporan',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Penggunaan Dana\nKomunitas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B), height: 1.2),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Detail\nPengeluaran',
                  textAlign: TextAlign.end,
                  style: TextStyle(color: Color(0xFF076633), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSpendingItem(Icons.security, 'Keamanan & Ronda', 'Gaji personil & perlengkapan', 'Rp 4.200k', '35%', const Color(0xFFC7EBCB), const Color(0xFF076633)),
          const SizedBox(height: 12),
          _buildSpendingItem(Icons.cleaning_services_outlined, 'Kebersihan Lingkungan', 'Angkutan sampah & taman', 'Rp 3.100k', '25%', const Color(0xFFFFE5E5), const Color(0xFFC0392B)),
          const SizedBox(height: 12),
          _buildSpendingItem(Icons.celebration_outlined, 'Kegiatan Sosial', 'Dana darurat & acara warga', 'Rp 1.500k', '12%', const Color(0xFFE8ECEF), const Color(0xFF40624E)),
        ],
      ),
    );
  }

  Widget _buildSpendingItem(IconData icon, String title, String desc, String amount, String percent, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(desc, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                child: Text(percent, style: TextStyle(color: iconColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuditBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFC7EBCB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.verified_user_outlined, color: Color(0xFF076633), size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Laporan Audit September Selesai',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF076633)),
                ),
                Text(
                  'Diverifikasi oleh Ketua RT & Bendahara.',
                  style: TextStyle(fontSize: 11, color: const Color(0xFF076633).withOpacity(0.8)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF076633)),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Riwayat Bayar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B)),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              children: [
                _buildHistoryItem('September 2023', 'Dibayar pada 05 Sep 2023', 'Rp 150.000'),
                const Divider(height: 1, indent: 24, endIndent: 24),
                _buildHistoryItem('Agustus 2023', 'Dibayar pada 02 Aug 2023', 'Rp 150.000'),
                const Divider(height: 1, indent: 24, endIndent: 24),
                _buildHistoryItem('Juli 2023', 'Dibayar pada 10 Jul 2023', 'Rp 150.000'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String title, String date, String amount) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFF1FDF4), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: Color(0xFF28A745), size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(date, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              const Text('BERHASIL', style: TextStyle(color: Color(0xFF28A745), fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
