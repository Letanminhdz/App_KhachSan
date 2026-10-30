import '../mo_hinh/loai_phong.dart';
import '../tien_ich/dinh_dang.dart';
import 'api_dich_vu.dart';

class PhongDichVu {
  static Future<List<LoaiPhong>> layDanhSachLoaiPhong() async {
    final phanHoi = await ApiDichVu.layDuLieu('loai-phong');
    if (phanHoi is List) {
      return phanHoi.map((duLieu) => LoaiPhong.tuJson(duLieu)).toList();
    }
    return [];
  }

  static Future<LoaiPhong> layChiTietLoaiPhong(int maLoaiPhong) async {
    final phanHoi = await ApiDichVu.layDuLieu('loai-phong/$maLoaiPhong');
    if (phanHoi is Map<String, dynamic>) {
      return LoaiPhong.tuJson(phanHoi);
    }
    throw Exception('Khong tim thay thong tin loai phong');
  }

  static Future<List<LoaiPhong>> timKiemPhongTrong({
    required DateTime ngayNhanPhong,
    required DateTime ngayTraPhong,
    int? soNguoi,
  }) async {
    final body = <String, dynamic>{
      'ngay_nhan_phong': DinhDang.dinhDangGuiApi(ngayNhanPhong),
      'ngay_tra_phong': DinhDang.dinhDangGuiApi(ngayTraPhong),
    };
    if (soNguoi != null && soNguoi > 0) {
      body['so_nguoi'] = soNguoi;
    }
    final phanHoi = await ApiDichVu.guiDuLieu('phong/tim-kiem', body);

    if (phanHoi is List) {
      return phanHoi.map((duLieu) => LoaiPhong.tuJson(duLieu)).toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>> layThongTinKhachSan() async {
    try {
      final phanHoi = await ApiDichVu.layDuLieu('settings');
      if (phanHoi is Map<String, dynamic>) {
        return phanHoi;
      }
    } catch (_) {}
    return {
      'ten_khach_san': 'Khách Sạn Grand Luxury',
      'dia_chi': '123 Đường Bờ Biển, Đà Nẵng (sát bãi biển Mỹ Khê)',
      'so_dien_thoai': '1900 6868',
      'email': 'contact@grandluxury.vn',
      'khoang_cach_bien': '50 mét (chưa đầy 2 phút đi bộ)',
      'gio_check_in': '14:00',
      'gio_check_out': '12:00',
      'ti_le_coc': '30',
      'chinh_sach_huy': 'Miễn phí hủy/đổi lịch trước 48 giờ',
      'buffet_sang_gia': '150000',
      'buffet_sang_gio': '06:30 - 09:30',
      'xe_san_bay_gia': '300000',
      'thue_xe_may_gia': '120000',
      'giuong_phu_gia': '200000',
      'ho_boi_mo_ta': 'Khách sạn chưa có hồ bơi riêng, nằm sát biển cách bãi tắm Mỹ Khê 50 mét.',
      'bai_do_xe_mo_ta': 'Tầng hầm đỗ xe ô tô và xe máy MIỄN PHÍ 24/7 có bảo vệ trực.',
    };
  }

  /// Lấy danh sách dịch vụ thực tế từ CSDL MySQL (ẩm thực, spa, xe cộ...)
  static Future<List<Map<String, dynamic>>> layDanhSachDichVu() async {
    try {
      final phanHoi = await ApiDichVu.layDuLieu('dich-vu');
      if (phanHoi is List) {
        return phanHoi.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }
}
