import 'package:flutter/material.dart';
import '../data/admin_service.dart';
import '../../../../core/theme/app_colors.dart';

class RtVerificationScreen extends StatefulWidget {
  const RtVerificationScreen({super.key});

  @override
  State<RtVerificationScreen> createState() => _RtVerificationScreenState();
}

class _RtVerificationScreenState extends State<RtVerificationScreen> {
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
      final result = await adminService.getPendingRT();
      setState(() {
        _pendingList = result['data']['data'] ?? []; // Adjust based on API structure
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleVerify(int id, bool status) async {
    try {
      await adminService.verifyRT(id, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('RT berhasil di${status ? 'setujui' : 'tolak'}')),
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
      appBar: AppBar(title: const Text('Verifikasi Ketua RT')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _pendingList.isEmpty
                  ? const Center(child: Text('Tidak ada RT yang menunggu verifikasi.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _pendingList.length,
                      itemBuilder: (context, index) {
                        final item = _pendingList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(item['nama'] ?? 'Tanpa Nama', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Email: ${item['email'] ?? '-'}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _handleVerify(item['id'], false),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () => _handleVerify(item['id'], true),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
