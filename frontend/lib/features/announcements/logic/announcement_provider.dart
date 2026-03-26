import 'package:flutter/material.dart';
import '../data/announcement_model.dart';
import '../data/announcement_service.dart';

class AnnouncementProvider with ChangeNotifier {
  final AnnouncementService _service = AnnouncementService();

  List<Announcement> _announcements = [];
  bool _isLoading = false;
  String? _error;

  List<Announcement> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAnnouncements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _announcements = await _service.getAnnouncements();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAnnouncement(String title, String content, String? category) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.createAnnouncement(title, content, category);
      await fetchAnnouncements(); // Refresh list
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }
}
