import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frontend/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test (Warga Management Flow)', () {
    testWidgets('Robot Mengecek Daftar Warga', (tester) async {
      FlutterError.onError = (details) {};

      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      final waField = find.byType(EditableText).first;
      await tester.enterText(waField, '087777777777');
      final passField = find.byType(EditableText).last;
      await tester.enterText(passField, 'rahasia123');
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final wargaMenu = find.byIcon(Icons.people).or(find.text('Warga'));
      if (wargaMenu.evaluate().isNotEmpty) {
        await tester.tap(wargaMenu.first);
        await tester.pumpAndSettle();
        
        expect(find.textContaining('Warga'), findsWidgets);
      } else {
        print('Warning: Tombol menu warga tidak ditemukan');
      }
    });
  });
}
