import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../logic/due_provider.dart';

class DueHistoryScreen extends StatefulWidget {
  const DueHistoryScreen({super.key});

  @override
  State<DueHistoryScreen> createState() => _DueHistoryScreenState();
}

class _DueHistoryScreenState extends State<DueHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<DueProvider>().fetchDuesHistory(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DueProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Riwayat Iuran'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchDuesHistory(),
        child: _buildBody(provider),
      ),
    );
  }

  Widget _buildBody(DueProvider provider) {
    if (provider.isLoading && provider.duesHistory.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.duesHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${provider.error}', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.fetchDuesHistory(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (provider.duesHistory.isEmpty) {
      return const Center(child: Text('Belum ada data iuran.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.duesHistory.length,
      itemBuilder: (context, index) {
        final item = provider.duesHistory[index];
        final isLunas = item.status == 'LUNAS';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: isLunas ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              child: Icon(
                isLunas ? Icons.check_circle_outline : Icons.pending_actions_rounded,
                color: isLunas ? Colors.green : Colors.red,
              ),
            ),
            title: Text(
              '${item.month} ${item.year}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(item.amount),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLunas ? Colors.green : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                      color: isLunas ? Colors.white : Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isLunas && item.paidAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('dd/MM/yy').format(item.paidAt!),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
