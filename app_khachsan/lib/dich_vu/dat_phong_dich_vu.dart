import '../mo_hinh/dat_phong.dart';
import '../tien_ich/dinh_dang.dart';
import 'api_dich_vu.dart';

class DatPhongDichVu {
  static Future<DatPhong> taoDonDatPhong({
    required DateTime ngayNhanPhong,
    required DateTime ngayTraPhong,
    required int idLoaiPhong,
    required int soLuongPhong,
    required String tenKhachHang,
    required String sdtKhachHang,
    bool daDangNhap = false,
  }) async {
    final duLieuGui = {
      'ngay_nhan_phong': DinhDang.dinhDangGuiApi(ngayNhanPhong),
      'ngay_tra_phong': DinhDang.dinhDangGuiApi(ngayTraPhong),
      'id_loai_phong': idLoaiPhong,
      'so_luong_phong': soLuongPhong,
      'ten_khach_hang': tenKhachHang.trim(),
      'sdt_khach_hang': sdtKhachHang.trim(),
    };

    final duongDan = daDangNhap ? 'dat-phong' : 'dat-phong/khach-vang-lai';
    final phanHoi = await ApiDichVu.guiDuLieu(
      duongDan,
      duLieuGui,
      canToken: daDangNhap,
    );

    if (phanHoi != null && phanHoi is Map<String, dynamic>) {
      // Backend tra ve dat_phong hoac doi tuong truc tiep
      if (phanHoi['dat_phong'] != null) {
        return DatPhong.tuJson(phanHoi['dat_phong']);
      }
      return DatPhong.tuJson(phanHoi);
    }
    throw Exception('Dat phong that bai');
  }

  static Future<List<DatPhong>> layLichSuDatPhong() async {
    final phanHoi = await ApiDichVu.layDuLieu('lich-su-dat-phong', canToken: true);
    if (phanHoi is List) {
      return phanHoi.map((duLieu) => DatPhong.tuJson(duLieu)).toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>> layChiTietDatPhong(int idDon) async {
    final phanHoi = await ApiDichVu.layDuLieu('dat-phong/$idDon/chi-tiet', canToken: true);
    if (phanHoi is Map<String, dynamic>) {
      return phanHoi;
    }
    throw Exception('Không thể tải chi tiết đơn đặt phòng');
  }
}
