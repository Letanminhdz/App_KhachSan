class DichVu {
  final int id;
  final String tenDichVu;
  final double gia;
  final String? hinhAnh;
  final bool dangHoatDong;

  DichVu({
    required this.id,
    required this.tenDichVu,
    required this.gia,
    this.hinhAnh,
    this.dangHoatDong = true,
  });

  factory DichVu.tuJson(Map<String, dynamic> json) {
    return DichVu(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      tenDichVu: json['ten_dich_vu']?.toString() ?? '',
      gia: json['gia'] is num
          ? (json['gia'] as num).toDouble()
          : double.tryParse(json['gia']?.toString() ?? '0') ?? 0.0,
      hinhAnh: json['hinh_anh']?.toString(),
      dangHoatDong: json['dang_hoat_dong'] == 1 || json['dang_hoat_dong'] == true,
    );
  }
}
