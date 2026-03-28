import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api_client.dart';

class InboxService {
  final String _base = ApiClient.baseUrl;

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Notifikasi Keuangan
  Future<List<Map<String, dynamic>>> getDuesNotifications(String token) async {
    final res = await http.get(
      Uri.parse('$_base/notifications/dues'),
      headers: _headers(token),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(body['data'] ?? []);
    }
    throw Exception('Gagal memuat notifikasi keuangan');
  }

  // Inbox Surat
  Future<List<Map<String, dynamic>>> getLetterInbox(String token) async {
    final res = await http.get(
      Uri.parse('$_base/notifications/letters'),
      headers: _headers(token),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(body['data'] ?? []);
    }
    throw Exception('Gagal memuat inbox surat');
  }

  // Verifikasi surat (approve/reject)
  Future<void> verifyLetter(String token, int letterId, String status) async {
    final res = await http.patch(
      Uri.parse('$_base/letters/$letterId/verify'),
      headers: _headers(token),
      body: jsonEncode({'status': status}),
    );
    if (res.statusCode != 200) {
      throw Exception('Gagal memverifikasi surat');
    }
  }

  // Pengumuman (pakai endpoint existing)
  Future<List<Map<String, dynamic>>> getAnnouncements(String token) async {
    final res = await http.get(
      Uri.parse('$_base/announcements'),
      headers: _headers(token),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final list = body['data'] != null ? body['data']['announcements'] : [];
      return List<Map<String, dynamic>>.from(list ?? []);
    }
    throw Exception('Gagal memuat pengumuman');
  }
}
