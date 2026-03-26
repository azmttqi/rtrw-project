import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/auth_provider.dart';
import '../../admin/presentation/dashboard_screen.dart'; // RW shared dashboard or separate

class RegisterRwScreen extends StatefulWidget {
  const RegisterRwScreen({super.key});

  @override
  State<RegisterRwScreen> createState() => _RegisterRwScreenState();
}

class _RegisterRwScreenState extends State<RegisterRwScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar RW Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.home_work_rounded,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 32),
            const Text(
              'Bentuk Ekosistem Digital Wilayah Anda',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sebagai RW, Anda dapat mengelola RT dan Warga dalam satu aplikasi terintegrasi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 48),
            
            if (authProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                onPressed: () async {
                  // TODO: Implement actual Google Sign-In flow
                  // For now, testing the provider method
                  final success = await authProvider.loginGoogle('mock_id_token');
                  if (success && mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const DashboardScreen()),
                    );
                  }
                },
                icon: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                  height: 24,
                  errorBuilder: (_, __, ___) => const Icon(Icons.login),
                ),
                label: const Text('Daftar dengan Google'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.grey),
                ),
              ),

            if (authProvider.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  authProvider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
