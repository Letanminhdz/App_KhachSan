import '../mo_hinh/nguoi_dung.dart';
import 'api_dich_vu.dart';

class XacThucDichVu {
  static Future<Map<String, dynamic>> dangNhap({
    required String email,
    required String matKhau,
  }) async {
    final phanHoi = await ApiDichVu.guiDuLieu('login', {
      'email': email.trim(),
      'mat_khau': matKhau,
    });

    if (phanHoi != null && phanHoi['access_token'] != null) {
      final maToken = phanHoi['access_token'].toString();
      await ApiDichVu.luuToken(maToken);
      final nguoiDung = NguoiDung.tuJson(phanHoi['user'] ?? {});
      return {
        'thanh_cong': true,
        'nguoi_dung': nguoiDung,
        'token': maToken,
      };
    }
    throw Exception('Dang nhap that bai, du lieu khong hop le');
  }

  static Future<Map<String, dynamic>> dangKy({
    required String hoTen,
    required String email,
    required String matKhau,
    required String soDienThoai,
  }) async {
    final phanHoi = await ApiDichVu.guiDuLieu('register', {
      'ho_ten': hoTen.trim(),
      'email': email.trim(),
      'mat_khau': matKhau,
      'so_dien_thoai': soDienThoai.trim(),
    });

    if (phanHoi != null && phanHoi['access_token'] != null) {
      final maToken = phanHoi['access_token'].toString();
      await ApiDichVu.luuToken(maToken);
      final nguoiDung = NguoiDung.tuJson(phanHoi['user'] ?? {});
      return {
        'thanh_cong': true,
        'nguoi_dung': nguoiDung,
        'token': maToken,
      };
    }
    throw Exception('Dang ky that bai');
  }

  static Future<NguoiDung?> layThongTinNguoiDungHienTai() async {
    try {
      final maToken = await ApiDichVu.layToken();
      if (maToken == null || maToken.isEmpty) return null;

      final phanHoi = await ApiDichVu.layDuLieu('user', canToken: true);
      if (phanHoi != null && phanHoi is Map<String, dynamic>) {
        return NguoiDung.tuJson(phanHoi);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> dangXuat() async {
    try {
      await ApiDichVu.guiDuLieu('logout', {}, canToken: true);
    } catch (_) {}
    await ApiDichVu.xoaToken();
  }
}
