class NguoiDung {
  final int id;
  final String hoTen;
  final String email;
  final String? soDienThoai;
  final String vaiTro;
  final bool dangHoatDong;

  NguoiDung({
    required this.id,
    required this.hoTen,
    required this.email,
    this.soDienThoai,
    required this.vaiTro,
    this.dangHoatDong = true,
  });

  factory NguoiDung.tuJson(Map<String, dynamic> duLieu) {
    return NguoiDung(
      id: duLieu['id'] is int ? duLieu['id'] : int.tryParse(duLieu['id'].toString()) ?? 0,
      hoTen: duLieu['ho_ten']?.toString() ?? '',
      email: duLieu['email']?.toString() ?? '',
      soDienThoai: duLieu['so_dien_thoai']?.toString() ?? duLieu['dien_thoai']?.toString(),
      vaiTro: duLieu['vai_tro']?.toString() ?? 'Khach_Hang',
      dangHoatDong: duLieu['dang_hoat_dong'] == true || duLieu['dang_hoat_dong'] == 1,
    );
  }

  Map<String, dynamic> sangJson() {
    return {
      'id': id,
      'ho_ten': hoTen,
      'email': email,
      'so_dien_thoai': soDienThoai,
      'vai_tro': vaiTro,
      'dang_hoat_dong': dangHoatDong,
    };
  }
}
