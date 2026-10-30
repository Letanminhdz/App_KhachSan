import '../mo_hinh/dich_vu.dart';
import 'api_dich_vu.dart';

class KhachSanDichVu {
  static Future<List<DichVu>> layDanhSachDichVu() async {
    final phanHoi = await ApiDichVu.layDuLieu('dich-vu');
    if (phanHoi is List) {
      return phanHoi.map((item) => DichVu.tuJson(item)).toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>> goiDichVu({
    required int idDichVu,
    required int soLuong,
    String? soPhong,
    int? idDatPhong,
  }) async {
    final phanHoi = await ApiDichVu.guiDuLieu('yeu-cau-dich-vu', {
      'id_dich_vu': idDichVu,
      'so_luong': soLuong,
      'so_phong': soPhong,
      'id_dat_phong': idDatPhong,
    });
    if (phanHoi is Map<String, dynamic>) {
      return phanHoi;
    }
    return {'message': 'Đã gửi yêu cầu thành công'};
  }
}
