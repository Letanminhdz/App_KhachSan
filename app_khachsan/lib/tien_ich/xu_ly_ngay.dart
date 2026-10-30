import 'package:flutter/material.dart';

class XuLyNgay {
  /// Ngay nhan phong mac dinh (14:00 hom nay)
  static DateTime ngayNhanMacDinh() {
    final ngayHienTai = DateTime.now();
    return DateTime(ngayHienTai.year, ngayHienTai.month, ngayHienTai.day, 14, 0);
  }

  /// Ngay tra phong mac dinh (12:00 ngay mai)
  static DateTime ngayTraMacDinh() {
    final ngayMai = DateTime.now().add(const Duration(days: 1));
    return DateTime(ngayMai.year, ngayMai.month, ngayMai.day, 12, 0);
  }

  /// Tinh so dem giua ngay nhan va ngay tra (toi thieu 1 dem)
  static int tinhSoDem(DateTime ngayNhan, DateTime ngayTra) {
    final mocDau = DateTime(ngayNhan.year, ngayNhan.month, ngayNhan.day);
    final mocCuoi = DateTime(ngayTra.year, ngayTra.month, ngayTra.day);
    final soNgayChenhLech = mocCuoi.difference(mocDau).inDays;
    return soNgayChenhLech > 0 ? soNgayChenhLech : 1;
  }

  /// Kiem tra ngay tra phai sau ngay nhan
  static bool kiemTraKhoangNgayHopLe(DateTime ngayNhan, DateTime ngayTra) {
    return ngayTra.isAfter(ngayNhan);
  }

  /// Hop thoai chon ca ngay va gio lien tiep (Chon ngay -> Chon gio)
  static Future<DateTime?> chonNgayVaGio({
    required BuildContext context,
    required DateTime thoiGianHienTai,
    required DateTime mocToiThieu,
    required String tieuDeNgay,
    required String tieuDeGio,
  }) async {
    final ngayKhoiTao = thoiGianHienTai.isBefore(mocToiThieu) ? mocToiThieu : thoiGianHienTai;

    final ngayChon = await showDatePicker(
      context: context,
      initialDate: ngayKhoiTao,
      firstDate: mocToiThieu,
      lastDate: mocToiThieu.add(const Duration(days: 365)),
      helpText: tieuDeNgay,
      cancelText: 'HỦY',
      confirmText: 'TIẾP TỤC',
    );

    if (ngayChon == null) return null;

    if (!context.mounted) return null;

    final gioChon = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: thoiGianHienTai.hour,
        minute: thoiGianHienTai.minute,
      ),
      helpText: tieuDeGio,
      cancelText: 'BỎ QUA',
      confirmText: 'CHỌN',
    );

    final gio = gioChon?.hour ?? thoiGianHienTai.hour;
    final phut = gioChon?.minute ?? thoiGianHienTai.minute;

    return DateTime(
      ngayChon.year,
      ngayChon.month,
      ngayChon.day,
      gio,
      phut,
    );
  }

  /// Hop thoai chon rieng gio
  static Future<DateTime?> chonGio({
    required BuildContext context,
    required DateTime thoiGianHienTai,
    required String tieuDeGio,
  }) async {
    final gioChon = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: thoiGianHienTai.hour,
        minute: thoiGianHienTai.minute,
      ),
      helpText: tieuDeGio,
      cancelText: 'HỦY',
      confirmText: 'CHỌN',
    );

    if (gioChon == null) return null;

    return DateTime(
      thoiGianHienTai.year,
      thoiGianHienTai.month,
      thoiGianHienTai.day,
      gioChon.hour,
      gioChon.minute,
    );
  }
}
