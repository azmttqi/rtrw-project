import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frontend/main.dart' as app;

void main() {
  // Inisialisasi engine Integration Test bawaan Flutter yang kompatibel dengan Web/Chrome
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Visual E2E Demo: Simulasi Pengetikan dan Login Otomatis di Browser', (WidgetTester tester) async {
    // Abaikan penangkapan eksternal error gambar/jaringan agar demo mulus
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {};

    // 1. Jalankan aplikasi utama secara utuh
    app.main();

    // 2. Tunggu transisi booting SplashScreen selesai (kuras timer 3 detik)
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // 3. Verifikasi apakah kita sudah berada di halaman Login
    expect(find.text('Selamat Datang\nKembali'), findsOneWidget);

    // 4. Cari kedua kolom isian teks (Email/HP dan Password)
    final textFields = find.byType(TextField);
    expect(textFields, findsAtLeastNWidgets(2));

    // 5. Animasi Visual: Robot mengetikkan alamat email/nomor HP secara nyata di layar
    await tester.enterText(textFields.at(0), 'warga_demo@rtrw.id');
    await tester.pump(const Duration(milliseconds: 500)); // Jeda agar mata Anda bisa melihatnya

    // 6. Animasi Visual: Robot mengetikkan kata sandi
    await tester.enterText(textFields.at(1), 'rahasia123');
    await tester.pump(const Duration(milliseconds: 500));

    // 7. Animasi Visual: Robot menekan tombol Masuk
    final loginButton = find.text('Masuk');
    await tester.tap(loginButton);
    await tester.pump();

    // Jeda sedikit untuk memberi waktu peramban menampilkan pesan feedback
    await tester.pump(const Duration(seconds: 2));

    // Pulihkan handler
    FlutterError.onError = originalOnError;
    debugPrint('🎉 DEMO VISUAL E2E SELESAI! Robot berhasil menggerakkan Chrome.');
  });
}
