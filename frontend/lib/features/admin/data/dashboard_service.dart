import 'package:dio/dio.dart';
import '../../../../core/api_client.dart';

class DashboardService {
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await apiClient.get('/dashboard/stats');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengambil statistik dashboard');
    }
  }
}
