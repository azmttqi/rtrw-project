import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../logic/family_provider.dart';

class FamilyMembersScreen extends StatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FamilyProvider>().fetchFamilyAndMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FamilyProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Anggota Keluarga',
          style: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : provider.error != null
              ? _buildErrorState(provider.error!)
              : provider.familyData == null
                  ? _buildEmptyState()
                  : _buildFamilyContent(provider.familyData!, provider.members),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<FamilyProvider>().fetchFamilyAndMembers(),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.family_restroom, size: 80, color: Colors.grey),
            SizedBox(height: 24),
            Text(
              'Belum Ada Data',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
            ),
            SizedBox(height: 12),
            Text(
              'Anda belum mendaftarkan keluarga atau data tidak ditemukan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyContent(Map<String, dynamic> familyData, List<dynamic> members) {
    final statusColor = familyData['status_verifikasi'] == 'APPROVED' 
        ? AppColors.primaryGreen 
        : Colors.orange.shade800;

    return RefreshIndicator(
      onRefresh: () => context.read<FamilyProvider>().fetchFamilyAndMembers(),
      color: AppColors.primaryGreen,
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // KK Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF076633), Color(0xFF4CB050)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('KARTU KELUARGA', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        familyData['status_verifikasi'] ?? 'PENDING',
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  familyData['no_kk'] ?? '-',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildKKInfo('Tipe Warga', familyData['tipe_warga']),
                    _buildKKInfo('Status Tinggal', familyData['status_tinggal']),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Members List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Anggota',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
              ),
              Text(
                '${members.length} Orang',
                style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (members.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24.0),
              child: Center(
                child: Text('Belum ada data anggota keluarga yang ditambahkan.', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...members.map((member) => _buildMemberCard(context, member)),
        ],
      ),
    );
  }

  Widget _buildKKInfo(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value ?? '-', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildMemberCard(BuildContext context, dynamic member) {
    // Assuming backend fields: nik, nama_lengkap, jenis_kelamin, tanggal_lahir, hubungan_keluarga
    return InkWell(
      onTap: () => _showKTPDialog(context, member),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
              child: Icon(
                member['jenis_kelamin'] == 'PEREMPUAN' ? Icons.face_3 : Icons.face,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member['nama_lengkap'] ?? 'Nama Tidak Diketahui',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NIK: ${member['nik'] ?? '-'}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC7EBCB)),
              ),
              child: Text(
                member['hubungan_keluarga'] ?? '-',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showKTPDialog(BuildContext context, dynamic member) {
    // Formatter for date if needed, keeping it simple
    final String tglLahir = member['tanggal_lahir'] != null 
        ? member['tanggal_lahir'].toString().split('T')[0] 
        : '-';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFFBCE3F7), // Light blue background like KTP
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16), // Use more screen width
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'PROVINSI JAWA BARAT\nKABUPATEN KARAWANG',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NIK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                    const SizedBox(width: 32),
                    const Text(':', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${member['nik'] ?? '-'}', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87, letterSpacing: 1.5)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildKtpRow('Nama', member['nama_lengkap']),
                          _buildKtpRow('Tempat/Tgl Lahir', 'KARAWANG, $tglLahir'),
                          _buildKtpRow('Jenis Kelamin', member['jenis_kelamin']),
                          _buildKtpRow('Alamat', '-'),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildKtpRow('RT/RW', '- / -'),
                                _buildKtpRow('Kel/Desa', '-'),
                                _buildKtpRow('Kecamatan', '-'),
                              ],
                            ),
                          ),
                          _buildKtpRow('Agama', '-'),
                          _buildKtpRow('Status Perkawinan', member['hubungan_keluarga'] == 'Istri' || member['hubungan_keluarga'] == 'Kepala Keluarga' ? 'KAWIN' : 'BELUM KAWIN'),
                          _buildKtpRow('Pekerjaan', '-'),
                          _buildKtpRow('Kewarganegaraan', 'WNI'),
                          _buildKtpRow('Berlaku Hingga', 'SEUMUR HIDUP'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        Container(
                          width: 80,
                          height: 110,
                          decoration: BoxDecoration(
                            color: member['jenis_kelamin'] == 'PEREMPUAN' ? Colors.red.shade200 : Colors.blue.shade200,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                            ]
                          ),
                          child: Center(
                            child: Icon(
                              member['jenis_kelamin'] == 'PEREMPUAN' ? Icons.face_3 : Icons.face, 
                              size: 50, 
                              color: Colors.white
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('KARAWANG', style: TextStyle(fontSize: 9, color: Colors.black87)),
                        Text(tglLahir, style: const TextStyle(fontSize: 9, color: Colors.black87)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildKtpRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.black87))
          ),
          const Text(':', style: TextStyle(fontSize: 9, color: Colors.black87)),
          const SizedBox(width: 4),
          Expanded(
            flex: 3,
            child: Text(
              value?.toUpperCase() ?? '-', 
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.black87)
            )
          ),
        ],
      ),
    );
  }
}
