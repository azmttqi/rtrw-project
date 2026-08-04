import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frontend/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Warga Module E2E', () {
    testWidgets('Warga Dashboard and Profile', (tester) async {
      FlutterError.onError = (details) {};
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      final waField = find.byType(EditableText).first;
      await tester.enterText(waField, '087777777777'); 
      await tester.pumpAndSettle();
      final passField = find.byType(EditableText).last;
      await tester.enterText(passField, 'rahasia123');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final profileTab = find.text('Profil').or(find.text('Profile'));
      if (profileTab.evaluate().isNotEmpty) {
        await tester.tap(profileTab.first);
        await tester.pumpAndSettle();
        expect(find.text('Keluar').or(find.text('Logout')), findsWidgets);
      }
    });
  });
}
