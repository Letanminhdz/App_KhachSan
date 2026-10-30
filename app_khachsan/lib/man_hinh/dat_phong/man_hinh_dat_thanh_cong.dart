import 'package:flutter/material.dart';
import '../../cau_hinh/mau_sac_app.dart';
import '../../mo_hinh/dat_phong.dart';
import '../../tien_ich/dinh_dang.dart';
import '../tai_khoan/man_hinh_lich_su_don.dart';

class ManHinhDatThanhCong extends StatelessWidget {
  final DatPhong datPhong;

  const ManHinhDatThanhCong({
    super.key,
    required this.datPhong,
  });

  @override
  Widget build(BuildContext nguoiCanh) {
    return Scaffold(
      backgroundColor: MauSacApp.mauNen,
      appBar: AppBar(
        title: const Text('Đặt Phòng Thành Công'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: MauSacApp.mauThanhCong.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: MauSacApp.mauThanhCong,
                size: 72,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Đặt Phòng Thành Công!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: MauSacApp.mauChuChinh,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mã đơn đặt phòng: #${datPhong.id}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: MauSacApp.mauChinh,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Chúng tôi đã ghi nhận yêu cầu đặt phòng của quý khách và sẽ liên hệ sớm nhất để hỗ trợ.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: MauSacApp.mauChuPhu,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            // The thong tin don
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: MauSacApp.mauBeMat,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _dongThongTin('Khách hàng:', datPhong.tenKhachHang),
                  const Divider(height: 20),
                  _dongThongTin('Số điện thoại:', datPhong.sdtKhachHang),
                  const Divider(height: 20),
                  _dongThongTin('Hạng phòng:', datPhong.tenLoaiPhong),
                  const Divider(height: 20),
                  _dongThongTin('Số lượng phòng:', '${datPhong.soLuongPhong} phòng'),
                  const Divider(height: 20),
                  _dongThongTin(
                    'Ngày nhận phòng:',
                    DinhDang.dinhDangGioNgay(datPhong.ngayNhanPhong),
                  ),
                  const Divider(height: 20),
                  _dongThongTin(
                    'Ngày trả phòng:',
                    DinhDang.dinhDangGioNgay(datPhong.ngayTraPhong),
                  ),
                  const Divider(height: 20),
                  _dongThongTin(
                    'Tổng thanh toán:',
                    DinhDang.dinhDangTien(datPhong.tongTien),
                    laGiaTien: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    nguoiCanh,
                    MaterialPageRoute(
                      builder: (nguoiCanhMoi) => const ManHinhLichSuDon(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MauSacApp.mauChinh,
                ),
                child: const Text(
                  'Xem Danh Sách Đặt Phòng',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.popUntil(nguoiCanh, (duongDan) => duongDan.isFirst);
                },
                child: const Text(
                  'Quay Về Trang Chủ',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dongThongTin(String tieuDe, String noiDung, {bool laGiaTien = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          tieuDe,
          style: const TextStyle(
            fontSize: 13,
            color: MauSacApp.mauChuPhu,
          ),
        ),
        Text(
          noiDung,
          style: TextStyle(
            fontSize: laGiaTien ? 16 : 14,
            fontWeight: laGiaTien ? FontWeight.w800 : FontWeight.w600,
            color: laGiaTien ? MauSacApp.mauDiemNhan : MauSacApp.mauChuChinh,
          ),
        ),
      ],
    );
  }
}
