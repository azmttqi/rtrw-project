import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/atoms/custom_button.dart';
import '../data/admin_service.dart';
import 'data_warga_detail_screen.dart';

class DataKependudukanScreen extends StatefulWidget {
  const DataKependudukanScreen({super.key});

  @override
  State<DataKependudukanScreen> createState() => _DataKependudukanScreenState();
}

class _DataKependudukanScreenState extends State<DataKependudukanScreen> {
  // Tab 1: Invitations State
  final TextEditingController _noWaController = TextEditingController();
  bool _isLoadingInvitations = true;
  List<dynamic> _invitations = [];

  // Tab 2: Warga State
  bool _isLoadingWarga = true;
  List<dynamic> _wargaList = [];
  List<dynamic> _filteredList = [];
  String? _errorWarga;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInvitations();
    _fetchWarga();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _noWaController.dispose();
    super.dispose();
  }

  // --- Invitations Logic ---
  Future<void> _fetchInvitations() async {
    if (!mounted) return;
    setState(() => _isLoadingInvitations = true);
    try {
      final result = await adminService.getInvitations();
      if (mounted) {
        setState(() {
          _invitations = result;
          _isLoadingInvitations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingInvitations = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching invitations: $e')));
      }
    }
  }

  Future<void> _createInvitation() async {
    if (_noWaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nomor WA wajib diisi untuk mengundang Warga')));
      return;
    }

    try {
      final result = await adminService.createInvitation(_noWaController.text.isEmpty ? null : _noWaController.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Undangan berhasil dibuat')));
      _noWaController.clear();
      _fetchInvitations();
      
      _showLinkDialog(result['token']);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  void _showLinkDialog(String token) {
    final baseUri = Uri.base;
    final link = '${baseUri.origin}/#/invite?token=$token';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link Undangan Warga'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bagikan link ini kepada calon warga yang akan mendaftar:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: SelectableText(link, style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('TUTUP')),
          CustomButton(
            text: 'SALIN',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: link)).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link berhasil disalin')));
                Navigator.pop(context);
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteInvitation(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Undangan?'),
        content: const Text('Undangan ini akan dihapus dan link-nya tidak akan bisa digunakan lagi oleh siapapun.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('BATAL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('HAPUS', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await adminService.deleteInvitation(id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Undangan berhasil dihapus')));
      _fetchInvitations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  void _copyLink(String token) {
    final baseUri = Uri.base;
    final link = '${baseUri.origin}/#/invite?token=$token';
    Clipboard.setData(ClipboardData(text: link)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link berhasil disalin ke clipboard')));
    });
  }

  // --- Warga Logic ---
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredList = _wargaList.where((user) {
        final name = (user['nama'] ?? '').toLowerCase();
        final noKK = (user['no_kk'] ?? user['nomor_kk'] ?? '').toLowerCase();
        return name.contains(query) || noKK.contains(query);
      }).toList();
    });
  }

  Future<void> _fetchWarga() async {
    setState(() {
      _isLoadingWarga = true;
      _errorWarga = null;
    });
    try {
      final result = await adminService.getVerifiedWarga();
      setState(() {
        _wargaList = result;
        _filteredList = result;
        _isLoadingWarga = false;
      });
    } catch (e) {
      setState(() {
        _errorWarga = e.toString();
        _isLoadingWarga = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Data Kependudukan Warga'),
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Daftar Undangan'),
              Tab(text: 'Warga Terdaftar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildInvitationsTab(),
            _buildWargaTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_add_alt_1, color: AppColors.primaryGreen),
                      const SizedBox(width: 12),
                      const Text(
                        'Buat Undangan Warga',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noWaController,
                    decoration: InputDecoration(
                      labelText: 'Nomor WA Warga',
                      hintText: '08123456789',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(text: 'BUAT UNDANGAN', onPressed: _createInvitation),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Riwayat Undangan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoadingInvitations
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                : _invitations.isEmpty
                    ? const Center(child: Text('Belum ada undangan yang dibuat.'))
                    : ListView.builder(
                        itemCount: _invitations.length,
                        itemBuilder: (context, index) {
                          final inv = _invitations[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 1,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: inv['is_used'] ? Colors.grey.shade200 : AppColors.primaryGreen.withOpacity(0.1),
                                child: Icon(Icons.link, color: inv['is_used'] ? Colors.grey : AppColors.primaryGreen),
                              ),
                              title: Text(
                                inv['no_wa'] ?? 'Warga',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text('Token: ${inv['token']}', style: const TextStyle(fontFamily: 'monospace')),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!inv['is_used']) ...[
                                    IconButton(
                                      icon: const Icon(Icons.copy, size: 20, color: AppColors.primaryGreen),
                                      onPressed: () => _copyLink(inv['token']),
                                      tooltip: 'Salin Link',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                      onPressed: () => _deleteInvitation(inv['id']),
                                      tooltip: 'Hapus Undangan',
                                    ),
                                  ],
                                  Chip(
                                    label: Text(
                                      inv['is_used'] ? 'Digunakan' : 'Tersedia',
                                      style: TextStyle(
                                        color: inv['is_used'] ? Colors.grey.shade700 : AppColors.primaryGreen,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    backgroundColor: inv['is_used'] ? Colors.grey.shade200 : Colors.green.shade50,
                                    side: BorderSide.none,
                                  ),
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

  Widget _buildWargaTab() {
    return Column(
      children: [
        // Search Bar Section
        Container(
          color: AppColors.primaryGreen,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                icon: Icon(Icons.search, color: Colors.grey),
                hintText: 'Cari nama atau nomor KK...',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        
        const Padding(
          padding: EdgeInsets.only(top: 24, left: 16, bottom: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Daftar Keluarga Terverifikasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
            ),
          ),
        ),
        
        Expanded(
          child: _isLoadingWarga
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
              : _errorWarga != null
                  ? Center(child: Text(_errorWarga!))
                  : _filteredList.isEmpty
                      ? const Center(child: Text('Tidak ada data yang ditemukan.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredList.length,
                          itemBuilder: (context, index) {
                            final user = _filteredList[index];
                            final name = user['nama'] ?? 'Tanpa Nama';
                            final details = 'No. KK: ${user['no_kk'] ?? user['nomor_kk'] ?? '-'}';
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 1,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                                  child: Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                                    style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(details),
                                trailing: const Icon(Icons.check_circle, color: AppColors.primaryGreen),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DataWargaDetailScreen(familyData: user),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}
