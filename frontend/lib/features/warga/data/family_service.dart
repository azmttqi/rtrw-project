import 'package:dio/dio.dart';
import '../../../../core/api_client.dart';

class FamilyService {
  Future<Map<String, dynamic>> getMyFamily() async {
    try {
      final response = await apiClient.get('/families/me');
      return response.data['data'];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Keluarga belum terdaftar');
      }
      throw Exception(e.response?.data['message'] ?? 'Gagal mengambil data keluarga');
    }
  }

  Future<List<dynamic>> getFamilyMembers(int familyId) async {
    try {
      final response = await apiClient.get('/residents', queryParameters: {
        'family_id': familyId,
      });
      return response.data['data'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengambil anggota keluarga');
    }
  }
}
