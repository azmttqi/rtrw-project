import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/admin_service.dart';
import '../../auth/logic/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/atoms/custom_button.dart';

class InvitationManagementScreen extends StatefulWidget {
  const InvitationManagementScreen({super.key});

  @override
  State<InvitationManagementScreen> createState() => _InvitationManagementScreenState();
}

class _InvitationManagementScreenState extends State<InvitationManagementScreen> {
  final _noWaController = TextEditingController();
  bool _isLoadingInvitations = true;
  bool _isLoadingRegistered = true;
  List<dynamic> _invitations = [];
  List<dynamic> _registeredUsers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInvitations();
      _fetchRegisteredUsers();
    });
  }

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

  Future<void> _fetchRegisteredUsers() async {
    if (!mounted) return;
    setState(() => _isLoadingRegistered = true);
    try {
      final auth = context.read<AuthProvider>();
      final result = auth.isRW 
          ? await adminService.getVerifiedRT() 
          : await adminService.getVerifiedWarga();
      
      if (mounted) {
        setState(() {
          _registeredUsers = result;
          _isLoadingRegistered = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRegistered = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching registered users: $e')));
      }
    }
  }

  Future<void> _createInvitation() async {
    final auth = context.read<AuthProvider>();
    if (auth.isRT && _noWaController.text.isEmpty) {
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
        title: const Text('Link Undangan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bagikan link ini kepada calon pendaftar:'),
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text(auth.isRW ? 'Kelola Akun RT' : 'Kelola Akun Warga'),
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Daftar Undangan'),
              Tab(text: 'Terdaftar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildInvitationsTab(auth),
            _buildRegisteredTab(auth),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationsTab(AuthProvider auth) {
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
                      Text(
                        auth.isRW ? 'Buat Undangan Ketua RT' : 'Buat Undangan Warga',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (auth.isRT)
                    TextField(
                      controller: _noWaController,
                      decoration: InputDecoration(
                        labelText: 'Nomor WA Warga',
                        hintText: '08123456789',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  if (auth.isRT) const SizedBox(height: 16),
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
                                inv['no_wa'] ?? (auth.isRW ? 'Calon Ketua RT' : 'Warga'),
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

  Widget _buildRegisteredTab(AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              auth.isRW ? 'Daftar RT Terverifikasi' : 'Daftar Warga Terverifikasi',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoadingRegistered
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                : _registeredUsers.isEmpty
                    ? Center(child: Text(auth.isRW ? 'Belum ada RT yang terdaftar.' : 'Belum ada warga yang terdaftar.'))
                    : ListView.builder(
                        itemCount: _registeredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _registeredUsers[index];
                          final name = user['nama'] ?? 'Tanpa Nama';
                          final details = auth.isRW 
                              ? 'Ketua RT ${user['nomor_rt'] ?? '-'}' 
                              : 'Nomor KK: ${user['nomor_kk'] ?? '-'}';
                          
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
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
