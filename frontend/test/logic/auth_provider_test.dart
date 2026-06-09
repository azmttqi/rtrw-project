import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/features/auth/logic/auth_provider.dart';

void main() {
  group('Logic Unit Test: AuthProvider', () {
    test('1. Inisialisasi Awal (Unauthenticated State)', () async {
      // Siapkan memori SharedPreferences kosong
      SharedPreferences.setMockInitialValues({});
      
      final authProvider = AuthProvider();
      // Tunggu proses checkAuthStatus asinkron internal selesai
      await Future.delayed(Duration.zero);

      expect(authProvider.isAuthenticated, false);
      expect(authProvider.token, null);
      expect(authProvider.user, null);
      expect(authProvider.isAdmin, false);
      expect(authProvider.isWarga, false);
      expect(authProvider.isLoading, false);
    });

    test('2. Deteksi Otorisasi Peran: Akun Ketua RT (Admin)', () async {
      // Simulasikan memori SharedPreferences berisi sesi login aktif milik Ketua RT
      final mockUserProfil = {
        'id': 101,
        'nama': 'Pak RT Budi',
        'role': 'RT',
        'is_verified': true,
      };
      
      SharedPreferences.setMockInitialValues({
        'token': 'mock_jwt_token_rt_secure_123',
        'user': json.encode(mockUserProfil),
      });

      final authProvider = AuthProvider();
      await Future.delayed(Duration.zero);

      expect(authProvider.isAuthenticated, true);
      expect(authProvider.token, 'mock_jwt_token_rt_secure_123');
      expect(authProvider.isRT, true);
      expect(authProvider.isAdmin, true); // RT atau RW dianggap Admin di sistem
      expect(authProvider.isWarga, false);
      expect(authProvider.isVerified, true);
    });

    test('3. Deteksi Otorisasi Peran: Akun Warga Biasa', () async {
      // Simulasikan memori SharedPreferences berisi sesi login aktif milik Warga
      final mockUserProfil = {
        'id': 202,
        'nama': 'Siti Warga',
        'role': 'WARGA',
        'is_verified': false, // Simulasi akun belum diverifikasi
      };
      
      SharedPreferences.setMockInitialValues({
        'token': 'mock_jwt_token_warga_secure_456',
        'user': json.encode(mockUserProfil),
      });

      final authProvider = AuthProvider();
      await Future.delayed(Duration.zero);

      expect(authProvider.isAuthenticated, true);
      expect(authProvider.isWarga, true);
      expect(authProvider.isAdmin, false);
      expect(authProvider.isVerified, false);
    });

    test('4. Eksekusi Logika Pembersihan Sesi (Logout)', () async {
      // Set sesi aktif terlebih dahulu
      SharedPreferences.setMockInitialValues({
        'token': 'active_token',
        'user': json.encode({'id': 1, 'role': 'WARGA'}),
      });

      final authProvider = AuthProvider();
      await Future.delayed(Duration.zero);
      expect(authProvider.isAuthenticated, true);

      // Panggil metode logout
      await authProvider.logout();

      // Verifikasi state lokal terhapus
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.token, null);
      expect(authProvider.user, null);

      // Verifikasi penyimpanan fisik tiruan juga terkuras
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('token'), false);
      expect(prefs.containsKey('user'), false);
    });
  });
}
