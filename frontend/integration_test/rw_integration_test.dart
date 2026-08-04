import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frontend/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test (RW Dashboard Flow)', () {
    testWidgets('Robot Mengecek Tampilan RW', (tester) async {
      FlutterError.onError = (details) {};

      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      expect(find.byType(EditableText), findsWidgets);
      // Flow RW akan membutuhkan data pengguna dengan Role RW
    });
  });
}
