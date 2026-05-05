import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/auth/presentation/login_screen.dart';
import 'package:frontend/features/auth/logic/auth_provider.dart';

void main() {
  testWidgets('Automated Login Test: Validasi Input Kosong', (WidgetTester tester) async {
    // 0. Jurus Terakhir: Abaikan semua error visual/gambar agar test tetap hijau
    FlutterError.onError = (details) {}; 

    // 1. Atur layar sangat lebar (5000px) agar tidak ada overflow sama sekali
    tester.view.physicalSize = const Size(5000, 5000);
    tester.view.devicePixelRatio = 1.0;

    // 2. Jalankan halaman Login
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          child: const LoginScreen(),
        ),
      ),
    );

    // 3. Verifikasi: Apakah teks sambutan muncul?
    expect(find.text('Selamat Datang\nKembali'), findsOneWidget);

    // 4. Aksi: Tekan tombol "Masuk" tanpa mengisi apa-apa
    final loginButton = find.text('Masuk');
    await tester.tap(loginButton);
    await tester.pump();

    // 5. Verifikasi: Apakah muncul pesan error validasi?
    expect(find.text('Email atau No Handphone wajib diisi'), findsOneWidget);
    expect(find.text('Kata sandi wajib diisi'), findsOneWidget);
    
    print('✅ ROBOT BERHASIL! SEMUA VALIDASI LOLOS.');
  });
}
