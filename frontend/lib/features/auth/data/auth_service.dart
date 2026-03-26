import 'package:dio/dio.dart';
import '../../../core/api_client.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String noWa, String password) async {
    try {
      final response = await apiClient.post('/auth/login', data: {
        'no_wa': noWa,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan login');
    }
  }

  Future<Map<String, dynamic>> registerGoogle(String idToken, {String? tokenInvitation}) async {
    try {
      final response = await apiClient.post('/auth/register-google', data: {
        'idToken': idToken,
        'token_invitation': tokenInvitation,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal login/registrasi Google');
    }
  }

  Future<Map<String, dynamic>> registerWarga({
    required String nama,
    required String noWa,
    required String password,
    required String tokenInvitation,
  }) async {
    try {
      final response = await apiClient.post('/auth/register', data: {
        'nama': nama,
        'no_wa': noWa,
        'password': password,
        'token_invitation': tokenInvitation,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal registrasi warga');
    }
  }
}
