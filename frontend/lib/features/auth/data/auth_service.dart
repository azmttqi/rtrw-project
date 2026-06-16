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

  Future<Map<String, dynamic>> registerRT({
    required String nama,
    required String noWa,
    required String email,
    required String password,
    required String nomorRt,
    required String tokenInvitation,
  }) async {
    try {
      final response = await apiClient.post('/auth/register', data: {
        'nama': nama,
        'no_wa': noWa,
        'email': email,
        'password': password,
        'nomor_rt': nomorRt,
        'token_invitation': tokenInvitation,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal registrasi RT');
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

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await apiClient.get('/auth/me');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengambil profil');
    }
  }

<<<<<<< Updated upstream
  Future<Map<String, dynamic>> updateProfile({String? nama, String? noWa, String? email}) async {
    try {
      final response = await apiClient.patch('/auth/me', data: {
        if (nama != null) 'nama': nama,
        if (noWa != null) 'no_wa': noWa,
        if (email != null) 'email': email,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memperbarui profil');
    }
  }

  Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await apiClient.patch('/auth/password', data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengubah kata sandi');
=======
  Future<Map<String, dynamic>> updateProfile(String nama, String noWa) async {
    try {
      final response = await apiClient.put('/users/profile', data: {
        'nama': nama,
        'no_wa': noWa,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengubah profil');
>>>>>>> Stashed changes
    }
  }
}
