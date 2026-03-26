import 'package:flutter/material.dart';
import '../data/due_model.dart';
import '../data/due_service.dart';

class DueProvider with ChangeNotifier {
  final DueService _service = DueService();

  List<Due> _duesHistory = [];
  bool _isLoading = false;
  String? _error;

  List<Due> get duesHistory => _duesHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDuesHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _duesHistory = await _service.getDueHistory();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> payDue(int dueId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.confirmPayment(dueId);
      await fetchDuesHistory(); // Refresh list
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }
}
