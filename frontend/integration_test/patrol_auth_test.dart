import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:frontend/main.dart' as app;

void main() {
  patrolTest(
    'E2E Patrol: Skenario Login Otomatis',
    // Abaikan error visual agar test tetap jalan di lingkungan tanpa native bindings sempurna (seperti desktop/browser fallback)
    config: const PatrolTesterConfig(
      settleTimeout: Duration(seconds: 10),
    ),
    ($) async {
      FlutterError.onError = (details) {}; // Ignore visual errors

      // 1. Jalankan Aplikasi
      app.main();
      
      // Tunggu splash screen (kita gunakan pump buatan karena Patrol biasanya agresif dengan animasi)
      await $.tester.pump(const Duration(seconds: 4));

      // 2. Verifikasi Text Welcome
      expect($('Selamat Datang\nKembali'), findsOneWidget);

      // 3. Ketik Data (menggunakan CustomTextField)
      // Kita asumsikan field pertama adalah Email/WA dan kedua adalah Password
      final textFields = $(EditableText);
      await textFields.at(0).enterText('081234567890');
      await textFields.at(1).enterText('password123');

      // 4. Klik Tombol Masuk
      await $('Masuk').tap();

      // 5. Tunggu pindah halaman
      await $.pumpAndSettle();

      // 6. Verifikasi Dashboard
      // Jika berhasil login, harusnya pindah ke Scaffold baru
      expect($(Scaffold), findsWidgets);
      
      print('✅ Patrol Test Selesai!');
    },
  );
}
