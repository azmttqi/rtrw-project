import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import '../../../../core/api_client.dart';

class Letter {
  final int id;
  final String jenisSurat;
  final String keteranganKeperluan;
  final String status;
  final String? fileUrl;
  final DateTime createdAt;

  Letter({
    required this.id,
    required this.jenisSurat,
    required this.keteranganKeperluan,
    required this.status,
    this.fileUrl,
    required this.createdAt,
  });

  factory Letter.fromJson(Map<String, dynamic> json) {
    return Letter(
      id: json['id'],
      jenisSurat: json['jenis_surat'],
      keteranganKeperluan: json['keterangan_keperluan'],
      status: json['status'],
      fileUrl: json['file_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class LetterProvider with ChangeNotifier {
  List<Letter> _letters = [];
  bool _isLoading = false;
  String? _error;

  List<Letter> get letters => _letters;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchLetters() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiClient.get('/letters');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        _letters = data.map((item) => Letter.fromJson(item)).toList();
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createLetter(String jenisSurat, String keterangan) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiClient.post(
        '/letters',
        data: {
          'jenis_surat': jenisSurat,
          'keterangan_keperluan': keterangan,
        },
      );
      if (response.statusCode == 201) {
        await fetchLetters(); // Refresh list after creation
        return true;
      }
      return false;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? e.message;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> downloadLetterFile(int id, String fileName) async {
    try {
      // Create safe filename
      final safeFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9_\-\.]'), '_');
      final finalName = '${safeFileName}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      if (kIsWeb) {
        final response = await apiClient.dio.get(
          '/letters/$id/download',
          options: Options(responseType: ResponseType.bytes),
        );
        final blob = html.Blob([response.data], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', finalName)
          ..click();
        html.Url.revokeObjectUrl(url);
        return 'Folder Unduhan Browser';
      } else {
        // Get directory to save
        Directory? dir;
        if (defaultTargetPlatform == TargetPlatform.android) {
          dir = Directory('/storage/emulated/0/Download');
          if (!await dir.exists()) {
             dir = await getExternalStorageDirectory();
          }
        } else {
          dir = await getApplicationDocumentsDirectory();
        }
        
        if (dir == null) return null;
        
        final savePath = '${dir.path}/$finalName';
        
        await apiClient.dio.download(
          '/letters/$id/download',
          savePath,
        );
        return savePath;
      }
    } catch (e) {
      debugPrint("Download error: $e");
      _error = "Gagal mengunduh file surat.";
      notifyListeners();
      return null;
    }
  }
}
