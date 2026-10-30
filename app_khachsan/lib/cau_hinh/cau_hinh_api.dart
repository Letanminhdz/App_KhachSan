import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class CauHinhApi {
  // Cho phép truyền URL tùy chọn khi build: flutter run --dart-define=API_URL=http://...
  static const String _envApiUrl = String.fromEnvironment('API_URL', defaultValue: '');

  /// Đường dẫn máy chủ API gốc - Tự động nhận diện thiết bị chạy:
  /// - Android Emulator: http://10.0.2.2:8000 (trỏ thẳng vào Docker máy host)
  /// - Web / Linux / Desktop: http://localhost:8000
  static String get duongDanGoc {
    if (_envApiUrl.isNotEmpty) {
      return _envApiUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:8000';
    }

    try {
      if (Platform.isAndroid) {
        // Mặc định cho Android Emulator kết nối thẳng tới Docker API
        return 'http://10.0.2.2:8000';
      }
      if (Platform.isIOS) {
        return 'http://localhost:8000';
      }
    } catch (_) {
      // Fallback nếu không đọc được platform
    }

    return 'http://localhost:8000';
  }

  static Future<void> khoiTao() async {
    // Không lưu URL vào SharedPreferences để tránh lộ cài đặt hoặc cache URL hỏng
  }

  static String get duongDanApi => '$duongDanGoc/api';

  /// Lấy link ảnh đầy đủ từ server
  static String layDuongDanAnh(String? duongDanTuongDoi) {
    if (duongDanTuongDoi == null || duongDanTuongDoi.trim().isEmpty) {
      return '';
    }
    final duongDan = duongDanTuongDoi.trim();
    if (duongDan.startsWith('http://') || duongDan.startsWith('https://')) {
      return duongDan;
    }
    final duongDanSach = duongDan.startsWith('/')
        ? duongDan.substring(1)
        : duongDan;
    return '$duongDanGoc/$duongDanSach';
  }
}
