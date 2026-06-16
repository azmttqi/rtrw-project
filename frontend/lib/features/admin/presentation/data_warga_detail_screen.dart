import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/admin_service.dart';

class DataWargaDetailScreen extends StatefulWidget {
  final dynamic familyData;

  const DataWargaDetailScreen({super.key, required this.familyData});

  @override
  State<DataWargaDetailScreen> createState() => _DataWargaDetailScreenState();
}

class _DataWargaDetailScreenState extends State<DataWargaDetailScreen> {
  bool _isLoading = true;
  List<dynamic> _members = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final familyId = widget.familyData['id'];
      final result = await adminService.getFamilyMembers(familyId);
      
      // Sort so that "Kepala Keluarga" is at the top
      result.sort((a, b) {
        if (a['hubungan_keluarga'] == 'Kepala Keluarga') return -1;
        if (b['hubungan_keluarga'] == 'Kepala Keluarga') return 1;
        return 0;
      });

      setState(() {
        _members = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final family = widget.familyData;
    final kepalaKeluarga = family['nama'] ?? 'Tanpa Nama';
    final noKK = family['no_kk'] ?? family['nomor_kk'] ?? '-';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Detail Data Warga'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Container(
            color: AppColors.primaryGreen,
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    kepalaKeluarga.isNotEmpty ? kepalaKeluarga[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kepalaKeluarga,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nomor KK: $noKK',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                : _error != null
                    ? Center(child: Text(_error!))
                    : _members.isEmpty
                        ? const Center(child: Text('Belum ada data anggota keluarga.'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _members.length,
                            itemBuilder: (context, index) {
                              final member = _members[index];
                              final isKepalaKeluarga = member['hubungan_keluarga'] == 'Kepala Keluarga';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              member['nama_lengkap'] ?? 'Tanpa Nama',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isKepalaKeluarga ? FontWeight.w900 : FontWeight.bold,
                                                color: isKepalaKeluarga ? AppColors.primaryGreen : Colors.black87,
                                              ),
                                            ),
                                          ),
                                          if (isKepalaKeluarga)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryGreen.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'Kepala Keluarga',
                                                style: TextStyle(
                                                  color: AppColors.primaryGreen,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoRow('NIK', member['nik'] ?? '-'),
                                      _buildInfoRow('Hubungan', member['hubungan_keluarga'] ?? '-'),
                                      _buildInfoRow('Jenis Kelamin', member['jenis_kelamin'] ?? '-'),
                                      _buildInfoRow('Tanggal Lahir', _formatDate(member['tanggal_lahir'])),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          const Text(': ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}-${date.month}-${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
