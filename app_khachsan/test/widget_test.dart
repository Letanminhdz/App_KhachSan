import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_khachsan/cau_hinh/mau_sac_app.dart';
import 'package:app_khachsan/tien_ich/dinh_dang.dart';
import 'package:app_khachsan/tien_ich/xu_ly_ngay.dart';

void main() {
  test('Kiem tra dinh dang tien te Viet Nam', () {
    expect(DinhDang.dinhDangTien(500000), contains('500.000'));
  });

  test('Kiem tra tinh so dem luu tru', () {
    final ngayNhan = DateTime(2026, 10, 15);
    final ngayTra = DateTime(2026, 10, 18);
    expect(XuLyNgay.tinhSoDem(ngayNhan, ngayTra), 3);
  });

  test('Kiem tra khoang ngay hop le', () {
    final ngayNhan = DateTime(2026, 10, 15);
    final ngayTra = DateTime(2026, 10, 18);
    expect(XuLyNgay.kiemTraKhoangNgayHopLe(ngayNhan, ngayTra), isTrue);
  });

  testWidgets('Kiem tra mau sac va giao dien sang', (WidgetTester kiemThu) async {
    await kiemThu.pumpWidget(
      MaterialApp(
        theme: MauSacApp.giaoDienSang,
        home: const Scaffold(
          body: Text('Grand Luxury'),
        ),
      ),
    );
    expect(find.text('Grand Luxury'), findsOneWidget);
  });
}
