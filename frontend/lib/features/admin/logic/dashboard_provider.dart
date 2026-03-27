import 'package:flutter/material.dart';
import '../data/dashboard_service.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardService _service = DashboardService();
  
  Map<String, dynamic>? _stats;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getStats();
      _stats = result['data'];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }
}
