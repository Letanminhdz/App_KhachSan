class LoaiPhong {
  final int id;
  final String tenLoai;
  final int sucChua;
  final double giaCoBan;
  final String? hinhAnh;
  final String? moTa;
  final List<String> tienIch;
  final List<String> hinhAnhPhu;
  final int? soLuongTrong;

  LoaiPhong({
    required this.id,
    required this.tenLoai,
    required this.sucChua,
    required this.giaCoBan,
    this.hinhAnh,
    this.moTa,
    this.tienIch = const [],
    this.hinhAnhPhu = const [],
    this.soLuongTrong,
  });

  factory LoaiPhong.tuJson(Map<String, dynamic> duLieu) {
    // Lay hinh anh chinh tu duLieu hoac tu danh_sach_phong (khi tim kiem)
    String? hinhAnhChinh = duLieu['hinh_anh']?.toString();
    if ((hinhAnhChinh == null || hinhAnhChinh.isEmpty) &&
        duLieu['danh_sach_phong'] is List &&
        (duLieu['danh_sach_phong'] as List).isNotEmpty) {
      final phongDau = (duLieu['danh_sach_phong'] as List)[0];
      if (phongDau is Map) {
        if (phongDau['loai_phong'] is Map) {
          hinhAnhChinh = phongDau['loai_phong']['hinh_anh']?.toString();
        }
        hinhAnhChinh ??= phongDau['hinh_anh']?.toString();
      }
    }

    // Lay tien ich tu duLieu hoac danh_sach_phong
    dynamic rawTienIch = duLieu['tien_ich'];
    if (rawTienIch == null &&
        duLieu['danh_sach_phong'] is List &&
        (duLieu['danh_sach_phong'] as List).isNotEmpty) {
      final phongDau = (duLieu['danh_sach_phong'] as List)[0];
      if (phongDau is Map && phongDau['loai_phong'] is Map) {
        rawTienIch = phongDau['loai_phong']['tien_ich'];
      }
    }

    // Xu ly danh sach tien ich
    List<String> danhSachTienIch = [];
    if (rawTienIch != null) {
      if (rawTienIch is List) {
        danhSachTienIch = rawTienIch.map((muc) => muc.toString()).toList();
      } else if (rawTienIch is String) {
        final chuoiTienIch = rawTienIch;
        if (chuoiTienIch.isNotEmpty) {
          danhSachTienIch = chuoiTienIch
              .split(',')
              .map((muc) => muc.trim())
              .where((muc) => muc.isNotEmpty)
              .toList();
        }
      }
    }

    // Dong bo tien ich mac dinh voi Web khi database chua co du lieu
    if (danhSachTienIch.isEmpty) {
      danhSachTienIch = [
        'Wifi miễn phí',
        'Điều hòa',
        'Tivi',
        'Phòng tắm riêng',
      ];
    }

    // Xu ly danh sach hinh anh phu
    List<String> danhSachAnhPhu = [];
    if (duLieu['hinh_anh_phu'] != null) {
      if (duLieu['hinh_anh_phu'] is List) {
        danhSachAnhPhu = (duLieu['hinh_anh_phu'] as List).map((muc) => muc.toString()).toList();
      } else if (duLieu['hinh_anh_phu'] is String) {
        final chuoiAnhPhu = duLieu['hinh_anh_phu'] as String;
        if (chuoiAnhPhu.isNotEmpty) {
          danhSachAnhPhu = chuoiAnhPhu
              .split(',')
              .map((muc) => muc.trim())
              .where((muc) => muc.isNotEmpty)
              .toList();
        }
      }
    }

    return LoaiPhong(
      id: duLieu['id'] is int ? duLieu['id'] : int.tryParse(duLieu['id'].toString()) ?? 0,
      tenLoai: duLieu['ten_loai']?.toString() ?? 'Phong Khach San',
      sucChua: duLieu['suc_chua'] is int
          ? duLieu['suc_chua']
          : int.tryParse(duLieu['suc_chua'].toString()) ?? 2,
      giaCoBan: duLieu['gia_co_ban'] is num
          ? (duLieu['gia_co_ban'] as num).toDouble()
          : double.tryParse(duLieu['gia_co_ban']?.toString() ?? '0') ?? 0.0,
      hinhAnh: hinhAnhChinh,
      moTa: duLieu['mo_ta']?.toString() ??
          'Không gian lưu trú tiêu chuẩn cao cấp với đầy đủ tiện nghi hiện đại, mang lại sự thoải mái tối đa cho kỳ nghỉ của quý khách.',
      tienIch: danhSachTienIch,
      hinhAnhPhu: danhSachAnhPhu,
      soLuongTrong: duLieu['so_luong_trong'] is int
          ? duLieu['so_luong_trong']
          : (duLieu['so_luong_trong'] != null
              ? int.tryParse(duLieu['so_luong_trong'].toString())
              : null),
    );
  }

  Map<String, dynamic> sangJson() {
    return {
      'id': id,
      'ten_loai': tenLoai,
      'suc_chua': sucChua,
      'gia_co_ban': giaCoBan,
      'hinh_anh': hinhAnh,
      'mo_ta': moTa,
      'tien_ich': tienIch,
      'hinh_anh_phu': hinhAnhPhu,
      'so_luong_trong': soLuongTrong,
    };
  }
}
