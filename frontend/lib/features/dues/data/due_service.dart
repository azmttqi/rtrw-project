import '../../../core/api_client.dart';
import 'due_model.dart';

class DueService {
  Future<List<Due>> getDueHistory() async {
    try {
      final response = await apiClient.get('/dues/history');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Due.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil riwayat iuran');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<void> confirmPayment(int dueId) async {
    try {
      await apiClient.post('/dues/confirm/$dueId');
    } catch (e) {
      throw Exception('Gagal konfirmasi pembayaran: $e');
    }
  }
}
