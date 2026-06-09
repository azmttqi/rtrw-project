import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/features/announcements/logic/announcement_provider.dart';

// Kelas tiruan terisolasi untuk memvalidasi pemicuan event State Management murni
class MockStateAnnouncementProvider extends AnnouncementProvider {
  void triggerStateUpdate() {
    notifyListeners();
  }
}

void main() {
  group('Logic Unit Test: AnnouncementProvider', () {
    testWidgets('1. Validasi Inisialisasi State Awal', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final provider = AnnouncementProvider();

      // Memastikan koleksi pengumuman berawal dari daftar kosong
      expect(provider.announcements, isEmpty);
      
      // Memastikan indikator pemuatan berawal mati
      expect(provider.isLoading, false);
      
      // Memastikan tidak ada sisa pesan error
      expect(provider.error, isNull);
    });

    testWidgets('2. Pemantauan Pemicuan Perubahan State (ChangeNotifier Listeners)', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final provider = MockStateAnnouncementProvider();
      bool listenerPemicu = false;

      provider.addListener(() {
        listenerPemicu = true;
      });

      // Pemicuan pembaruan state lokal untuk menguji keandalan pendengar (listener)
      provider.triggerStateUpdate();

      expect(listenerPemicu, true);
    });
  });
}
