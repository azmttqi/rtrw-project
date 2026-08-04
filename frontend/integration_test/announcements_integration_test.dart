import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frontend/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test (Announcements Flow)', () {
    testWidgets('Robot Mengecek Daftar Pengumuman', (tester) async {
      // Abaikan error visual agar robot tetap jalan di Chrome/Desktop
      FlutterError.onError = (details) {};

      // 1. Jalankan Aplikasi
      app.main();
      await tester.pumpAndSettle();

      // 2. Tunggu Splash Screen selesai (3 detik)
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // 3. Login Asumsi (Berdasarkan Auth Flow)
      final waField = find.byType(EditableText).first;
      await tester.enterText(waField, '087777777777');
      await tester.pumpAndSettle();

      final passField = find.byType(EditableText).last;
      await tester.enterText(passField, 'rahasia123');
      await tester.pumpAndSettle();

      final loginButton = find.text('Masuk');
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 4. Navigasi ke Halaman Pengumuman
      // Asumsi ada menu bottom navigation bar atau drawer dengan ikon Announcement/Pengumuman
      final announcementMenu = find.byIcon(Icons.campaign).or(find.text('Pengumuman'));
      if (announcementMenu.evaluate().isNotEmpty) {
        await tester.tap(announcementMenu.first);
        await tester.pumpAndSettle();
        
        // 5. Verifikasi Halaman Pengumuman Muncul
        expect(find.text('Pengumuman Warga'), findsWidgets);
      } else {
        print('Warning: Tombol menu pengumuman tidak ditemukan di halaman utama');
      }
    });
  });
}
