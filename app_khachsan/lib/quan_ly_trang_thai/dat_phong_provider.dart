import 'package:flutter/material.dart';
import '../mo_hinh/loai_phong.dart';
import '../tien_ich/xu_ly_ngay.dart';

class DatPhongProvider extends ChangeNotifier {
  late DateTime _ngayNhanPhong;
  late DateTime _ngayTraPhong;
  int _soLuongPhong = 1;
  int _soKhach = 1; // Mac dinh 1 nguoi giong web
  LoaiPhong? _loaiPhongDuocChon;

  DatPhongProvider() {
    _ngayNhanPhong = XuLyNgay.ngayNhanMacDinh();
    _ngayTraPhong = XuLyNgay.ngayTraMacDinh();
  }

  /// Kiem tra va tu dong cap nhat lai ngay nhan neu da roi vao qua khu
  bool dongBoNgayNeuQuaHan({bool thongBao = false}) {
    final now = DateTime.now();
    final homNay = DateTime(now.year, now.month, now.day);
    final nhan = DateTime(_ngayNhanPhong.year, _ngayNhanPhong.month, _ngayNhanPhong.day);
    if (nhan.isBefore(homNay)) {
      _ngayNhanPhong = XuLyNgay.ngayNhanMacDinh();
      _ngayTraPhong = XuLyNgay.ngayTraMacDinh();
      if (thongBao) {
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  DateTime get ngayNhanPhong {
    dongBoNgayNeuQuaHan();
    return _ngayNhanPhong;
  }

  DateTime get ngayTraPhong {
    dongBoNgayNeuQuaHan();
    return _ngayTraPhong;
  }

  int get soLuongPhong => _soLuongPhong;
  int get soKhach => _soKhach;
  LoaiPhong? get loaiPhongDuocChon => _loaiPhongDuocChon;

  int get soDem => XuLyNgay.tinhSoDem(_ngayNhanPhong, _ngayTraPhong);

  double get tongTienTamTinh {
    if (_loaiPhongDuocChon == null) return 0.0;
    return _loaiPhongDuocChon!.giaCoBan * _soLuongPhong * soDem;
  }

  void datNgayNhan(DateTime ngayMoi) {
    _ngayNhanPhong = ngayMoi;
    // Dam bao ngay tra luon sau ngay nhan
    if (!_ngayTraPhong.isAfter(_ngayNhanPhong)) {
      _ngayTraPhong = _ngayNhanPhong.add(const Duration(days: 1));
    }
    notifyListeners();
  }

  void datNgayTra(DateTime ngayMoi) {
    if (ngayMoi.isAfter(_ngayNhanPhong)) {
      _ngayTraPhong = ngayMoi;
      notifyListeners();
    }
  }

  void datKhoangNgay(DateTime ngayNhan, DateTime ngayTra) {
    _ngayNhanPhong = ngayNhan;
    if (ngayTra.isAfter(ngayNhan)) {
      _ngayTraPhong = ngayTra;
    } else {
      _ngayTraPhong = ngayNhan.add(const Duration(days: 1));
    }
    notifyListeners();
  }

  void datSoLuongPhong(int soLuong) {
    if (soLuong >= 1) {
      _soLuongPhong = soLuong;
      notifyListeners();
    }
  }

  void datSoKhach(int soLuong) {
    if (soLuong >= 1) {
      _soKhach = soLuong;
      notifyListeners();
    }
  }

  void chonLoaiPhong(LoaiPhong? loaiPhong) {
    _loaiPhongDuocChon = loaiPhong;
    notifyListeners();
  }

  void datLai() {
    _ngayNhanPhong = XuLyNgay.ngayNhanMacDinh();
    _ngayTraPhong = XuLyNgay.ngayTraMacDinh();
    _soLuongPhong = 1;
    _soKhach = 1;
    _loaiPhongDuocChon = null;
    notifyListeners();
  }
}
