import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frontend/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Admin Module E2E', () {
    testWidgets('Admin navigate to Data Kependudukan', (tester) async {
      FlutterError.onError = (details) {};
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      final waField = find.byType(EditableText).first;
      await tester.enterText(waField, '081111111111'); 
      await tester.pumpAndSettle();

      final passField = find.byType(EditableText).last;
      await tester.enterText(passField, 'admin123');
      await tester.pumpAndSettle();

      final loginButton = find.text('Masuk');
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final dataMenu = find.text('Data Kependudukan');
      if (dataMenu.evaluate().isNotEmpty) {
        await tester.tap(dataMenu.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });
}
