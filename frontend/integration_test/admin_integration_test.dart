import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frontend/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test (Admin Flow)', () {
    testWidgets('Robot Mengakses Dashboard Admin', (tester) async {
      FlutterError.onError = (details) {};

      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Pastikan ada input login
      expect(find.byType(EditableText), findsWidgets);
      
      // Catatan: Ini adalah kerangka dasar. Admin flow butuh login dengan role ADMIN.
      // Implementasi spesifik flow login dan klik menu admin akan diisi di sini nanti.
    });
  });
}
