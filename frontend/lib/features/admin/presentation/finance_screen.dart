import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../auth/logic/auth_provider.dart';
import '../data/finance_service.dart';
import './atur_tagihan_screen.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final FinanceService _service = FinanceService();
  Map<String, dynamic>? _summary;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    final token = context.read<AuthProvider>().token ?? '';
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getFinanceSummary(token);
      if (mounted) {
        setState(() {
          _summary = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  String _formatRp(dynamic val) {
    if (val == null) return 'Rp 0';
    final double amount = val is double ? val : (val is int ? val.toDouble() : double.tryParse(val.toString()) ?? 0.0);
    return 'Rp ${NumberFormat('#,###', 'id').format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primaryGreen,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
            : _error != null
                ? _buildError()
                : _buildContent(auth),
      ),
    );
  }

  Widget _buildError() => ListView(
    children: [
      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
      const Icon(Icons.error_outline, color: Colors.red, size: 48),
      const SizedBox(height: 16),
      Center(child: Text(_error!, textAlign: TextAlign.center)),
      TextButton(onPressed: _load, child: const Text('Coba Lagi')),
    ],
  );

  Widget _buildContent(AuthProvider auth) {
    final s = _summary!;
    final totalKas = s['total_kas'] ?? 0.0;
    
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                auth.isRW ? 'MANAJEMEN KEUANGAN' : 'KEUANGAN RT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen.withOpacity(0.8),
                  letterSpacing: 1.2,
                ),
              ),
              if (auth.isRT)
                const Icon(Icons.notifications_none_rounded, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 24),

          // Total Kas Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryGreen, Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.isRW ? 'TOTAL KAS RUKUN WARGA' : 'TOTAL SALDO KAS RT',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _formatRp(totalKas),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.trending_up, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '+${_formatRp(s['pemasukan_bulan_ini'])}',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    if (auth.isRT) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Bank Mandiri', style: TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                    ],
                    const Spacer(),
                    if (auth.isRW)
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text('Kirim Laporan', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (auth.isRT) ...[
            _buildUploadCard(),
            const SizedBox(height: 32),
            _buildCitizenDuesStatus(context, s),
            const SizedBox(height: 32),
            _buildCashSummary(s),
          ] else ...[
            const SizedBox(height: 32),
            _buildRWFineBody(context, s),
          ],
          
          const SizedBox(height: 32),
          const Text(
            'Transaksi Terakhir',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 16),
          
          if ((s['transaksi_terbaru'] as List).isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('Belum ada transaksi', style: TextStyle(color: Colors.grey)),
            ))
          else
            ...List<Map<String, dynamic>>.from(s['transaksi_terbaru']).map((tx) {
              final isPositive = true; // For now assuming all additions for RT/RW dues
              final String title;
              if (tx['tipe'] == 'RT') {
                title = 'Iuran RT ${tx['nomor_rt']}';
              } else {
                title = 'Iuran ${tx['nama_pembayar']}';
              }
              return _buildTransactionItem(
                title, 
                _formatRp(tx['nominal']), 
                tx['dibayar_pada']?.split('T')[0] ?? '${tx['bulan']}/${tx['tahun']}', 
                isPositive,
                isVerified: auth.isRT,
              );
            }).toList(),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildUploadCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
            child: const Icon(Icons.note_add_outlined, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            'Upload Bukti Pengeluaran',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildCitizenDuesStatus(BuildContext context, Map<String, dynamic> s) {
    final sudah = s['sudah_bayar'] ?? 0;
    final total = s['total_kk'] ?? 0;
    final belum = total - sudah;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Status Iuran Warga', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${_summary?['bulan']}/${_summary?['tahun']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                child: Text('Oktober 2023', style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildDuesCounter('Sudah Bayar', sudah.toString(), '$total KK', Colors.green, total)),
              const SizedBox(width: 24),
              Expanded(child: _buildDuesCounter('Belum Bayar', belum.toString(), '$total KK', Colors.redAccent, total)),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Lihat Detail Warga', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                  Icon(Icons.chevron_right_rounded, color: AppColors.primaryGreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuesCounter(String label, String count, String totalLabel, Color color, int totalVal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(count, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(width: 4),
            Text('/ $totalLabel', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: totalVal > 0 ? double.parse(count) / totalVal : 0,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildCashSummary(Map<String, dynamic> s) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F1),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan Kas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildSummaryRow(Icons.arrow_circle_down_rounded, 'Pemasukan', _formatRp(s['total_kas']), Colors.green),
          const SizedBox(height: 12),
          _buildSummaryRow(Icons.arrow_circle_up_rounded, 'Pengeluaran', _formatRp(s['total_disetor_ke_rw'] ?? 0), Colors.redAccent),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Saldo Kas', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_formatRp(s['total_kas'] - (s['total_disetor_ke_rw'] ?? 0)), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryGreen, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String amount, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13)),
        const Spacer(),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildRWFineBody(BuildContext context, Map<String, dynamic> s) {
    final List rtList = s['rt_dues_status'] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Arus Kas Bulanan
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Arus Kas Bulanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
            ),
            Row(
              children: [
                _buildSmallFilter('PEMASUKAN', true),
                const SizedBox(width: 8),
                _buildSmallFilter('PENGELUARAN', false),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Center(
            child: Text('Chart Visualisation (Coming Soon)', style: TextStyle(color: Colors.grey.shade400)),
          ),
        ),
        const SizedBox(height: 32),

        // Status Iuran RT
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Status Iuran RT',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AturTagihanScreen()),
                );
              },
              child: const Text('Kelola Tagihan', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (rtList.isEmpty)
          const Center(child: Text('Tidak ada data RT', style: TextStyle(color: Colors.grey)))
        else
          ...rtList.map((rt) {
            Color color = Colors.green;
            if (rt['status'] == 'BELUM_BAYAR') color = Colors.red;
            if (rt['status'] == 'HAMPIR_JATUH_TEMPO') color = Colors.orange;
            
            return _buildRtStatusItem(
              'RT ${rt['nomor_rt']} / RW ${_summary?['nomor_rw'] ?? '08'}', 
              'Ketua: ${rt['nama_ketua']}', 
              rt['status'].replaceAll('_', ' '), 
              color
            );
          }).toList(),
      ],
    );
  }

  Widget _buildSmallFilter(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryGreen : Colors.grey.shade700,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRtStatusItem(String title, String subtitle, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Center(child: Text(title.substring(3, 5), style: TextStyle(color: color, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String title, String amount, String date, bool isPositive, {bool isVerified = false, bool hasEvidence = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: (isPositive ? Colors.green : Colors.orange).withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(isPositive ? Icons.account_balance_wallet_rounded : Icons.construction_rounded, color: isPositive ? Colors.green : Colors.orange, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(date, style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                    if (isVerified) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                        child: Text('TERVERIFIKASI', style: TextStyle(color: Colors.green.shade700, fontSize: 7, fontWeight: FontWeight.bold)),
                      ),
                    ],
                    if (hasEvidence) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(4)),
                        child: Text('BUKTI TERLAMPIR', style: TextStyle(color: Colors.orange.shade700, fontSize: 7, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: isPositive ? AppColors.primaryGreen : Colors.redAccent,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
