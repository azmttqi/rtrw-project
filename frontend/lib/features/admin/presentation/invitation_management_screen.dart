import 'package:flutter/material.dart';
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
  bool _isLoading = true;
  List<dynamic> _invitations = [];

  @override
  void initState() {
    super.initState();
    _fetchInvitations();
  }

  Future<void> _fetchInvitations() async {
    setState(() => _isLoading = true);
    try {
      final result = await adminService.getInvitations();
      setState(() {
        _invitations = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
      
      // OPTIONAL: Show the link in a dialog
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
              // Copy to clipboard logic would go here
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Undangan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      auth.isRW ? 'Buat Undangan Ketua RT' : 'Buat Undangan Warga',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (auth.isRT)
                      TextField(
                        controller: _noWaController,
                        decoration: const InputDecoration(labelText: 'Nomor WA Warga', hintText: '08123456789'),
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
              child: Text('Daftar Undangan Terakhir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _invitations.isEmpty
                      ? const Center(child: Text('Belum ada undangan.'))
                      : ListView.builder(
                          itemCount: _invitations.length,
                          itemBuilder: (context, index) {
                            final inv = _invitations[index];
                            return ListTile(
                              leading: Icon(Icons.link, color: inv['is_used'] ? Colors.grey : AppColors.primaryGreen),
                              title: Text(inv['no_wa'] ?? (auth.isRW ? 'Calon Ketua RT' : 'Warga')),
                              subtitle: Text('Token: ${inv['token']}'),
                              trailing: Chip(
                                label: Text(inv['is_used'] ? 'Digunakan' : 'Tersedia'),
                                backgroundColor: inv['is_used'] ? Colors.grey.shade200 : Colors.green.shade100,
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
