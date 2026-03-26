import '../../../core/api_client.dart';

class AdminService {
  Future<Map<String, dynamic>> getPendingWarga() async {
    try {
      final response = await apiClient.get('/families', queryParameters: {'status': 'PENDING'});
      return response.data;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> verifyWarga(int familyId, String status) async {
    try {
      await apiClient.patch('/families/$familyId/verify', data: {'status': status});
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> getPendingRT() async {
    try {
      final response = await apiClient.get('/users', queryParameters: {'role': 'RT', 'is_verified': 'false'});
      return response.data;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> verifyRT(int userId, bool status) async {
    try {
      await apiClient.patch('/users/$userId/verify-rt', data: {'is_verified': status});
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<dynamic>> getInvitations() async {
    try {
      final response = await apiClient.get('/invitations');
      return response.data['data'] ?? [];
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> createInvitation(String? noWa) async {
    try {
      final response = await apiClient.post('/invitations', data: {'no_wa': noWa});
      return response.data['data'];
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<dynamic>> getVerifiedWarga() async {
    try {
      final response = await apiClient.get('/families');
      return response.data['data']['families'] ?? [];
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<dynamic>> getVerifiedRT() async {
    try {
      final response = await apiClient.get('/users', queryParameters: {'role': 'RT', 'is_verified': 'true'});
      return response.data['data']['users'] ?? [];
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

final adminService = AdminService();
