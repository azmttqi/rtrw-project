import 'package:dio/dio.dart';
import '../../../core/api_client.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await apiClient.post('/auth/login', data: {
        'no_wa': identifier, // Backend findByIdentifier checks both email & wa
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

  Future<Map<String, dynamic>> registerRW({
    required String nama,
    required String noWa,
    required String email,
    required String password,
    required String nomorRw,
    String? alamat,
    String? namaWilayah,
  }) async {
    try {
      final response = await apiClient.post('/auth/register', data: {
        'nama': nama,
        'no_wa': noWa,
        'email': email,
        'password': password,
        'role': 'RW',
        'nomor_rw': nomorRw,
        'alamat': alamat,
        'nama_wilayah': namaWilayah,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal registrasi RW');
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String identifier, String otp) async {
    try {
      final response = await apiClient.post('/auth/verify-email', data: {
        'identifier': identifier,
        'otp': otp,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memverifikasi email');
    }
  }
}
