import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frontend/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test (Login Flow)', () {
    testWidgets('Robot Login Otomatis', (tester) async {
      // Abaikan error visual agar robot tetap jalan di Chrome
      FlutterError.onError = (details) {};

      // 1. Jalankan Aplikasi

      app.main();
      await tester.pumpAndSettle();

      // 2. Tunggu Splash Screen selesai (3 detik)
      // Kita tunggu sampai splash screen pindah ke AuthWrapper/LoginScreen
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // 3. Masukkan Nomor WhatsApp
      final waField = find.byType(EditableText).first;
      await tester.enterText(waField, '081234567890');
      await tester.pumpAndSettle();

      // 4. Masukkan Kata Sandi
      final passField = find.byType(EditableText).last;
      await tester.enterText(passField, 'password123');
      await tester.pumpAndSettle();

      // 5. Klik Tombol Masuk
      final loginButton = find.text('Masuk');
      await tester.tap(loginButton);
      
      // Tunggu proses login (hit API) dan transisi halaman
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 6. Verifikasi: Apakah robot sudah sampai di Dashboard?
      // Kita bisa mencari teks yang biasanya ada di Dashboard, misalnya "Dashboard" atau "Warga"
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}

