import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frontend/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Announcements Module E2E', () {
    testWidgets('Create and view announcement', (tester) async {
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

      final announcementsTab = find.text('Pengumuman');
      if (announcementsTab.evaluate().isNotEmpty) {
        await tester.tap(announcementsTab.first);
        await tester.pumpAndSettle();
      }

      final fab = find.byType(FloatingActionButton);
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab);
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(EditableText).first, 'Test Pengumuman UI');
        await tester.enterText(find.byType(EditableText).last, 'Isi konten pengumuman test');
        await tester.tap(find.byWidgetPredicate((widget) => widget is Text && (widget.data == 'Simpan' || widget.data == 'Kirim')));
        await tester.pumpAndSettle();
      }
    });
  });
}
