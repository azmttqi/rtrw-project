import '../../../core/api_client.dart';
import 'announcement_model.dart';

class AnnouncementService {
  Future<List<Announcement>> getAnnouncements() async {
    try {
      final response = await apiClient.get('/announcements');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Announcement.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil pengumuman');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<void> createAnnouncement(String title, String content, String? category) async {
    try {
      await apiClient.post('/announcements', data: {
        'judul': title,
        'isi': content,
        'kategori': category,
      });
    } catch (e) {
      throw Exception('Gagal membuat pengumuman: $e');
    }
  }
}
