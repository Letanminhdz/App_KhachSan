import 'loai_phong.dart';

enum NguoiGuiTin {
  khachHang,
  troLyAi,
}

class TinNhanBot {
  final String id;
  final NguoiGuiTin nguoiGui;
  final String noiDung;
  final DateTime thoiGian;
  final List<LoaiPhong> danhSachPhongGoiY;
  final Map<String, dynamic>? duLieuDatPhong;
  final String? nguon; // 'API' hoặc 'LOCAL'

  TinNhanBot({
    required this.id,
    required this.nguoiGui,
    required this.noiDung,
    required this.thoiGian,
    this.danhSachPhongGoiY = const [],
    this.duLieuDatPhong,
    this.nguon,
  });

  factory TinNhanBot.tuBot({
    required String noiDung,
    List<LoaiPhong> danhSachPhongGoiY = const [],
    Map<String, dynamic>? duLieuDatPhong,
    String? nguon,
  }) {
    return TinNhanBot(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nguoiGui: NguoiGuiTin.troLyAi,
      noiDung: noiDung,
      thoiGian: DateTime.now(),
      danhSachPhongGoiY: danhSachPhongGoiY,
      duLieuDatPhong: duLieuDatPhong,
      nguon: nguon,
    );
  }

  factory TinNhanBot.tuKhachHang(String noiDung) {
    return TinNhanBot(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nguoiGui: NguoiGuiTin.khachHang,
      noiDung: noiDung,
      thoiGian: DateTime.now(),
    );
  }
}
