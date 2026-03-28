import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api_client.dart';

class FinanceService {
  final String _base = ApiClient.baseUrl;

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> getFinanceSummary(String token) async {
    final res = await http.get(
      Uri.parse('$_base/dashboard/finance'),
      headers: _headers(token),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return Map<String, dynamic>.from(body['data'] ?? {});
    }
    throw Exception('Gagal memuat ringkasan keuangan');
  }

  Future<Map<String, dynamic>> getDashboardStats(String token) async {
    final res = await http.get(
      Uri.parse('$_base/dashboard/stats'),
      headers: _headers(token),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return Map<String, dynamic>.from(body['data'] ?? {});
    }
    throw Exception('Gagal memuat statistik dashboard');
  }
}
