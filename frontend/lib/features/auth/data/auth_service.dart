import 'package:dio/dio.dart';
import '../../../core/api_client.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String noWa, String password) async {
    try {
      final response = await apiClient.post('/auth/login', data: {
        'no_wa': noWa,
        'password': password,
      });

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal login');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Terjadi kesalahan koneksi';
      throw Exception(message);
    }
  }
}
