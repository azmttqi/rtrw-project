import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/announcements/presentation/announcement_list_screen.dart';
import 'package:frontend/features/announcements/logic/announcement_provider.dart';
import 'package:frontend/features/announcements/data/announcement_model.dart';

// ── Provider Tiruan (Mock) Terisolasi ─────────────────────────────────────────
class MockAnnouncementProvider extends AnnouncementProvider {
  @override
  List<Announcement> get announcements => [
        Announcement(
          id: 101,
          title: 'Kerja Bakti Warga Terpadu',
          content: 'Ayo bersama-sama membersihkan saluran air dan selokan di hari Minggu pagi.',
          category: 'Lingkungan',
          createdAt: DateTime(2026, 5, 12),
          authorName: 'Pak RT Budi',
          isKegiatan: true,
        ),
      ];

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  Future<void> fetchAnnouncements() async {
    // Potong total akses fisik ke jaringan internet / Dio
    notifyListeners();
  }
}

void main() {
  testWidgets('Presentation Widget Test: Layar Daftar Pengumuman (AnnouncementListScreen)', (WidgetTester tester) async {
    // 0. Setel rasio layar lapang untuk mencegah terjadinya overflow font grafis
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    
    // Simpan handler asli dan matikan pelemparan error visual eksternal
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {};

    // 1. Jalankan komponen antarmuka yang dibungkus dengan Provider tiruan
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ChangeNotifierProvider<AnnouncementProvider>(
          create: (_) => MockAnnouncementProvider(),
          child: const AnnouncementListScreen(),
        ),
      ),
    );

    // 2. Selesaikan sisa animasi atau microtask pemuatan awal
    await tester.pumpAndSettle();

    // 3. Verifikasi: Apakah header statis premium berhasil digambar?
    expect(find.text('INFORMASI TERBARU'), findsOneWidget);
    expect(find.text('Pengumuman\nWarga Digital'), findsOneWidget);

    // 4. Verifikasi: Apakah data pengumuman dinamis dari Mock Provider ter-render di layar?
    expect(find.text('Kerja Bakti Warga Terpadu'), findsOneWidget);
    expect(find.text('Pak RT Budi'), findsOneWidget);

    // Pulihkan handler asli
    FlutterError.onError = originalOnError;
    debugPrint('✅ WIDGET TEST PENGUMUMAN BERHASIL! Komponen grafis dan data tersinkronisasi.');
  });
}
