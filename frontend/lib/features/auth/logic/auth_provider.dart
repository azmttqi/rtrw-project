import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;
  
  bool get isAdmin => _user != null && (_user!['role'] == 'RT' || _user!['role'] == 'RW');
  bool get isRT => _user != null && _user!['role'] == 'RT';
  bool get isRW => _user != null && _user!['role'] == 'RW';
  bool get isWarga => _user != null && _user!['role'] == 'WARGA';
  bool get isVerified => _user != null && _user!['is_verified'] == true;

  AuthProvider() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    
    final userData = prefs.getString('user');
    if (userData != null) {
      _user = json.decode(userData);
    }
    
    notifyListeners();
  }

  Future<bool> login(String identifier, String password) async {
    return _handleAuth(() => _authService.login(identifier, password));
  }

  Future<bool> loginGoogle(String idToken, {String? tokenInvitation}) async {
    return _handleAuth(() => _authService.registerGoogle(idToken, tokenInvitation: tokenInvitation));
  }

  Future<bool> registerWarga({
    required String nama,
    required String noWa,
    required String password,
    required String tokenInvitation,
  }) async {
    return _handleAuth(() => _authService.registerWarga(
          nama: nama,
          noWa: noWa,
          password: password,
          tokenInvitation: tokenInvitation,
        ));
  }

  Future<bool> registerRW({
    required String nama,
    required String noWa,
    required String email,
    required String password,
    required String nomorRw,
    String? alamat,
    String? namaWilayah,
  }) async {
    return _handleAuth(() => _authService.registerRW(
          nama: nama,
          noWa: noWa,
          email: email,
          password: password,
          nomorRw: nomorRw,
          alamat: alamat,
          namaWilayah: namaWilayah,
        ));
  }

  Future<bool> verifyEmail(String identifier, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.verifyEmail(identifier, otp);
      if (_user != null) {
        _user!['is_verified'] = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', json.encode(_user));
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> _handleAuth(Future<Map<String, dynamic>> Function() authCall) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await authCall();
      _token = result['data']['token'];
      _user = result['data']['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('user', json.encode(_user));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    notifyListeners();
  }
}
