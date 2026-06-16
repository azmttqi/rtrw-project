import 'package:flutter/material.dart';
import '../data/family_service.dart';

class FamilyProvider with ChangeNotifier {
  final FamilyService _service = FamilyService();

  Map<String, dynamic>? _familyData;
  List<dynamic> _members = [];
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get familyData => _familyData;
  List<dynamic> get members => _members;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchFamilyAndMembers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _familyData = await _service.getMyFamily();
      if (_familyData != null && _familyData!['id'] != null) {
        _members = await _service.getFamilyMembers(_familyData!['id']);
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
