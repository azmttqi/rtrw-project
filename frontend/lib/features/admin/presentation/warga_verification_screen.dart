import 'package:flutter/material.dart';
import '../data/admin_service.dart';

class WargaVerificationScreen extends StatefulWidget {
  const WargaVerificationScreen({super.key});

  @override
  State<WargaVerificationScreen> createState() => _WargaVerificationScreenState();
}

class _WargaVerificationScreenState extends State<WargaVerificationScreen> {
  bool _isLoading = true;
  List<dynamic> _pendingList = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPending();
  }

  Future<void> _fetchPending() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await adminService.getPendingWarga();
      setState(() {
        _pendingList = result['data']['families'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleVerify(int id, String status) async {
    try {
      await adminService.verifyWarga(id, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Warga berhasil di${status == 'APPROVED' ? 'setujui' : 'tolak'}')),
      );
      _fetchPending();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Warga')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _pendingList.isEmpty
                  ? const Center(child: Text('Tidak ada warga yang menunggu verifikasi.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _pendingList.length,
                      itemBuilder: (context, index) {
                        final item = _pendingList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(item['nama'] ?? 'Tanpa Nama', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('No. KK: ${item['no_kk']}'),
                                Text('Status: ${item['tipe_warga']}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _handleVerify(item['id'], 'REJECTED'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () => _handleVerify(item['id'], 'APPROVED'),
                                ),
                              ],
                            ),
                            onTap: () {
                              // TODO: Show Detail & Document view
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
