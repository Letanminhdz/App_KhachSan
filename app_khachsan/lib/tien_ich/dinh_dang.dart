import 'package:intl/intl.dart';

class DinhDang {
  /// Dinh dang so tien thanh chuoi tien te Viet Nam (Vi du: 500.000 d)
  static String dinhDangTien(dynamic soTien) {
    if (soTien == null) return '0 ₫';
    final num soParsed = (soTien is num)
        ? soTien
        : (double.tryParse(soTien.toString()) ?? 0);
    final boDinhDang = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return boDinhDang.format(soParsed);
  }

  /// Dinh dang ngay thanh dd/MM/yyyy
  static String dinhDangNgay(DateTime? ngayThang) {
    if (ngayThang == null) return '';
    return DateFormat('dd/MM/yyyy').format(ngayThang);
  }

  /// Dinh dang gio thanh HH:mm
  static String dinhDangGio(DateTime? ngayThang) {
    if (ngayThang == null) return '';
    return DateFormat('HH:mm').format(ngayThang);
  }

  /// Dinh dang ngay gio thanh HH:mm dd/MM/yyyy
  static String dinhDangGioNgay(DateTime? ngayThang) {
    if (ngayThang == null) return '';
    return DateFormat('HH:mm dd/MM/yyyy').format(ngayThang);
  }

  /// Dinh dang ngay gio de gui len Backend API (yyyy-MM-dd HH:mm:ss)
  static String dinhDangGuiApi(DateTime ngayThang) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(ngayThang);
  }

  /// Chuyen chuoi ngay thanh DateTime
  static DateTime? chuyenChuoiSangNgay(String? chuoiNgay) {
    if (chuoiNgay == null || chuoiNgay.isEmpty) return null;
    try {
      return DateTime.parse(chuoiNgay).toLocal();
    } catch (_) {
      try {
        return DateFormat('yyyy-MM-dd HH:mm:ss').parse(chuoiNgay);
      } catch (_) {
        return null;
      }
    }
  }
}
