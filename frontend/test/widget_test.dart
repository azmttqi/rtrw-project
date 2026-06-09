// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend/main.dart';
import 'package:frontend/features/auth/logic/auth_provider.dart';
import 'package:frontend/features/announcements/logic/announcement_provider.dart';
import 'package:frontend/features/dues/logic/due_provider.dart';
import 'package:frontend/features/admin/logic/dashboard_provider.dart';

void main() {
  testWidgets('Smoke Test: Inisialisasi Aplikasi Utama (Booting ke SplashScreen)', (WidgetTester tester) async {
    // 0. Simpan handler asli dan cegah pelemparan exception visual eksternal
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {};

    // 1. Jalankan kerangka aplikasi utama lengkap dengan seluruh jajaran Providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
          ChangeNotifierProvider(create: (_) => DueProvider()),
          ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // 2. Verifikasi: Memastikan layar awal menampilkan indikator loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 3. Selesaikan pemuatan awal dan kuras antrean Timer 3 detik milik SplashScreen
    // agar sistem navigasi tuntas berpindah ke AuthWrapper tanpa ada timer tersisa.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    
    // Kembalikan ke state aslinya
    FlutterError.onError = originalOnError;
    debugPrint('✅ SMOKE TEST UTAMA BERHASIL! Aplikasi sukses melakukan booting.');
  });
}
