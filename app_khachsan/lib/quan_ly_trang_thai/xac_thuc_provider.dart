import 'package:flutter/material.dart';
import '../mo_hinh/nguoi_dung.dart';
import '../dich_vu/xac_thuc_dich_vu.dart';

class XacThucProvider extends ChangeNotifier {
  NguoiDung? _nguoiDung;
  bool _dangXuLy = false;
  String? _thongBaoLoi;
  bool _daKhoiTao = false;

  NguoiDung? get nguoiDung => _nguoiDung;
  bool get dangXuLy => _dangXuLy;
  String? get thongBaoLoi => _thongBaoLoi;
  bool get daDangNhap => _nguoiDung != null;
  bool get daKhoiTao => _daKhoiTao;

  Future<void> khoiTao() async {
    _dangXuLy = true;
    notifyListeners();
    try {
      _nguoiDung = await XacThucDichVu.layThongTinNguoiDungHienTai();
    } catch (_) {
      _nguoiDung = null;
    } finally {
      _dangXuLy = false;
      _daKhoiTao = true;
      notifyListeners();
    }
  }

  Future<bool> dangNhap({
    required String email,
    required String matKhau,
  }) async {
    _dangXuLy = true;
    _thongBaoLoi = null;
    notifyListeners();

    try {
      final ketQua = await XacThucDichVu.dangNhap(
        email: email,
        matKhau: matKhau,
      );
      _nguoiDung = ketQua['nguoi_dung'] as NguoiDung?;
      _dangXuLy = false;
      notifyListeners();
      return true;
    } catch (e) {
      _dangXuLy = false;
      _thongBaoLoi = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> dangKy({
    required String hoTen,
    required String email,
    required String matKhau,
    required String soDienThoai,
  }) async {
    _dangXuLy = true;
    _thongBaoLoi = null;
    notifyListeners();

    try {
      final ketQua = await XacThucDichVu.dangKy(
        hoTen: hoTen,
        email: email,
        matKhau: matKhau,
        soDienThoai: soDienThoai,
      );
      _nguoiDung = ketQua['nguoi_dung'] as NguoiDung?;
      _dangXuLy = false;
      notifyListeners();
      return true;
    } catch (e) {
      _dangXuLy = false;
      _thongBaoLoi = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> dangXuat() async {
    _dangXuLy = true;
    notifyListeners();
    await XacThucDichVu.dangXuat();
    _nguoiDung = null;
    _dangXuLy = false;
    notifyListeners();
  }

  void xoaThongBaoLoi() {
    _thongBaoLoi = null;
    notifyListeners();
  }
}
