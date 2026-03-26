import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/auth_provider.dart';
import '../../../../core/api_client.dart';
import '../../warga/presentation/register_warga_screen.dart';

class InviteHandlerScreen extends StatefulWidget {
  final String token;
  const InviteHandlerScreen({super.key, required this.token});

  @override
  State<InviteHandlerScreen> createState() => _InviteHandlerScreenState();
}

class _InviteHandlerScreenState extends State<InviteHandlerScreen> {
  bool _isValidating = true;
  String? _role;

  @override
  void initState() {
    super.initState();
    _validateToken();
  }

  Future<void> _validateToken() async {
    if (widget.token.isEmpty) {
      setState(() {
        _isValidating = false;
        _role = 'INVALID';
      });
      return;
    }

    try {
      final response = await apiClient.get('/invitations/${widget.token}');
      setState(() {
        _role = response.data['data']['role'];
        _isValidating = false;
      });
    } catch (e) {
      setState(() {
        _isValidating = false;
        _role = 'INVALID';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isValidating) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_role == 'INVALID') {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Undangan Tidak Valid', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Link ini sudah tidak berlaku atau salah.'),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('KEMBALI')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.mail_outline_rounded, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              'Undangan Diterima!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _role == 'RT' 
                ? 'Anda diundang sebagai Ketua RT. Silakan masuk menggunakan Akun Google Anda.'
                : 'Anda diundang sebagai Warga. Silakan verifikasi nomor WhatsApp Anda.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            
            if (_role == 'RT')
              ElevatedButton.icon(
                onPressed: () async {
                  final authProvider = context.read<AuthProvider>();
                  final success = await authProvider.loginGoogle('mock_id_token', tokenInvitation: widget.token);
                  if (success && mounted) {
                    // Navigate to Dashboard or Pending Verification Screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Registrasi RT berhasil. Menunggu verifikasi RW.')),
                    );
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.login),
                label: const Text('Login dengan Google (RT)'),
              )
            else
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => RegisterWargaScreen(token: widget.token)
                  ));
                },
                child: const Text('Lanjut Verifikasi WA (Warga)'),
              ),
          ],
        ),
      ),
    );
  }
}
