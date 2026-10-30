import 'package:shared_preferences/shared_preferences.dart';

/// Dịch vụ quản lý bảo mật Mã PIN (Mục 5.c Báo cáo đồ án: Mã PIN mở ứng dụng)
class BaoMatDichVu {
  static const String _khoaBatPin = 'cai_dat_bat_khoa_pin';
  static const String _khoaGiaTriPin = 'cai_dat_ma_pin';

  /// Kiểm tra người dùng đã kích hoạt khóa PIN chưa
  static Future<bool> daBatKhoaPin() async {
    final prefs = await SharedPreferences.getInstance();
    final bat = prefs.getBool(_khoaBatPin) ?? false;
    final pin = prefs.getString(_khoaGiaTriPin);
    return bat && pin != null && pin.length == 4;
  }

  /// Kiểm tra mã PIN nhập vào có chính xác không
  static Future<bool> kiemTraPin(String pinNhap) async {
    final prefs = await SharedPreferences.getInstance();
    final pinLuu = prefs.getString(_khoaGiaTriPin);
    return pinLuu != null && pinLuu == pinNhap;
  }

  /// Thiết lập mã PIN mới và tự động kích hoạt
  static Future<void> datMaPin(String pinMoi) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_khoaGiaTriPin, pinMoi);
    await prefs.setBool(_khoaBatPin, true);
  }

  /// Tắt tính năng khóa PIN
  static Future<void> tatKhoaPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_khoaBatPin, false);
    await prefs.remove(_khoaGiaTriPin);
  }
}
