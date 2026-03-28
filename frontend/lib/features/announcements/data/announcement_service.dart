import '../../../core/api_client.dart';
import 'announcement_model.dart';

class AnnouncementService {
  Future<List<Announcement>> getAnnouncements() async {
    try {
      final response = await apiClient.get('/announcements');
      
      if (response.statusCode == 200) {
        final dynamic body = response.data;
        List<dynamic> listData = [];
        
        if (body is Map) {
          final dynamic dataField = body['data'];
          if (dataField is List) {
            listData = dataField;
          } else if (dataField is Map) {
             if (dataField['announcements'] is List) {
               listData = dataField['announcements'];
             } else if (dataField['data'] is List) {
               listData = dataField['data'];
             }
          } else if (body['announcements'] is List) {
            listData = body['announcements'];
          }
        } else if (body is List) {
          listData = body;
        }
        
        return listData.map((json) => Announcement.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil pengumuman');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<void> createAnnouncement({
    required String title,
    required String content,
    required String target,
    String? fotoUrl,
    bool isKegiatan = false,
    String? tanggalKegiatan,
  }) async {
    try {
      await apiClient.post('/announcements', data: {
        'judul': title,
        'konten': content,
        'target': target,
        if (fotoUrl != null && fotoUrl.isNotEmpty) 'foto_url': fotoUrl,
        'is_kegiatan': isKegiatan,
        if (tanggalKegiatan != null) 'tanggal_kegiatan': tanggalKegiatan,
      });
    } catch (e) {
      throw Exception('Gagal membuat pengumuman: $e');
    }
  }
}
