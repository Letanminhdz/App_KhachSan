import 'package:flutter/material.dart';

class DatPhong {
  final int id;
  final int? idTaiKhoan;
  final String tenKhachHang;
  final String sdtKhachHang;
  final DateTime ngayNhanPhong;
  final DateTime ngayTraPhong;
  final int idLoaiPhong;
  final String tenLoaiPhong;
  final int soLuongPhong;
  final double giaPhong;
  final double tongTien;
  final String trangThai;
  final DateTime? ngayTao;
  final List<String> danhSachSoPhong;

  DatPhong({
    required this.id,
    this.idTaiKhoan,
    required this.tenKhachHang,
    required this.sdtKhachHang,
    required this.ngayNhanPhong,
    required this.ngayTraPhong,
    required this.idLoaiPhong,
    required this.tenLoaiPhong,
    required this.soLuongPhong,
    required this.giaPhong,
    required this.tongTien,
    required this.trangThai,
    this.ngayTao,
    this.danhSachSoPhong = const [],
  });

  factory DatPhong.tuJson(Map<String, dynamic> duLieu) {
    DateTime chuyenNgay(dynamic giaTri) {
      if (giaTri == null) return DateTime.now();
      try {
        return DateTime.parse(giaTri.toString()).toLocal();
      } catch (_) {
        return DateTime.now();
      }
    }

    List<String> danhSachSoPhongDuocCap = [];
    if (duLieu['phan_bo_phongs'] is List) {
      for (var muc in duLieu['phan_bo_phongs']) {
        if (muc is Map && muc['phong'] != null && muc['phong']['so_phong'] != null) {
          danhSachSoPhongDuocCap.add(muc['phong']['so_phong'].toString());
        }
      }
    }

    return DatPhong(
      id: duLieu['id'] is int ? duLieu['id'] : int.tryParse(duLieu['id'].toString()) ?? 0,
      idTaiKhoan: duLieu['id_tai_khoan'] is int
          ? duLieu['id_tai_khoan']
          : (duLieu['id_tai_khoan'] != null ? int.tryParse(duLieu['id_tai_khoan'].toString()) : null),
      tenKhachHang: duLieu['ten_khach_hang']?.toString() ?? '',
      sdtKhachHang: duLieu['sdt_khach_hang']?.toString() ?? '',
      ngayNhanPhong: chuyenNgay(duLieu['ngay_nhan_phong']),
      ngayTraPhong: chuyenNgay(duLieu['ngay_tra_phong']),
      idLoaiPhong: duLieu['id_loai_phong'] is int
          ? duLieu['id_loai_phong']
          : int.tryParse(duLieu['id_loai_phong'].toString()) ?? 0,
      tenLoaiPhong: duLieu['ten_loai_phong_khi_dat']?.toString() ?? 'Phong Khach San',
      soLuongPhong: duLieu['so_luong_phong'] is int
          ? duLieu['so_luong_phong']
          : int.tryParse(duLieu['so_luong_phong'].toString()) ?? 1,
      giaPhong: duLieu['gia_phong_khi_dat'] is num
          ? (duLieu['gia_phong_khi_dat'] as num).toDouble()
          : double.tryParse(duLieu['gia_phong_khi_dat']?.toString() ?? '0') ?? 0.0,
      tongTien: duLieu['tong_tien'] is num
          ? (duLieu['tong_tien'] as num).toDouble()
          : double.tryParse(duLieu['tong_tien']?.toString() ?? '0') ?? 0.0,
      trangThai: duLieu['trang_thai']?.toString() ?? 'Moi_Dat',
      ngayTao: duLieu['created_at'] != null ? chuyenNgay(duLieu['created_at']) : null,
      danhSachSoPhong: danhSachSoPhongDuocCap,
    );
  }

  /// Ten trang thai than thien
  String get tenTrangThai {
    switch (trangThai) {
      case 'Moi_Dat':
        return 'Chờ xác nhận';
      case 'Da_Xac_Nhan':
        return 'Đã xác nhận';
      case 'Da_Nhan_Phong':
        return 'Đang lưu trú';
      case 'Da_Thanh_Toan':
        return 'Hoàn thành';
      case 'Da_Huy':
        return 'Đã hủy';
      default:
        return trangThai;
    }
  }

  /// Mau sac dai dien
  Color get mauTrangThai {
    switch (trangThai) {
      case 'Moi_Dat':
        return const Color(0xFFF59E0B);
      case 'Da_Xac_Nhan':
        return const Color(0xFF3B82F6);
      case 'Da_Nhan_Phong':
        return const Color(0xFF10B981);
      case 'Da_Thanh_Toan':
        return const Color(0xFF8B5CF6);
      case 'Da_Huy':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }
}
