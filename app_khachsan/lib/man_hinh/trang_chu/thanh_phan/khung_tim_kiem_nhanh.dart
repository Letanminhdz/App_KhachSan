import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../cau_hinh/mau_sac_app.dart';
import '../../../quan_ly_trang_thai/dat_phong_provider.dart';
import '../../../tien_ich/dinh_dang.dart';
import '../../../tien_ich/xu_ly_ngay.dart';

class KhungTimKiemNhanh extends StatelessWidget {
  final VoidCallback khiBamTimKiem;

  const KhungTimKiemNhanh({
    super.key,
    required this.khiBamTimKiem,
  });

  Future<void> _moHopThoaiChonNgayNhan(
    BuildContext nguoiCanh,
    DatPhongProvider datPhongProvider,
  ) async {
    final ngayHienTai = DateTime.now();
    final mocDauHomNay = DateTime(ngayHienTai.year, ngayHienTai.month, ngayHienTai.day);

    final thoiGianMoi = await XuLyNgay.chonNgayVaGio(
      context: nguoiCanh,
      thoiGianHienTai: datPhongProvider.ngayNhanPhong,
      mocToiThieu: mocDauHomNay,
      tieuDeNgay: 'CHỌN NGÀY NHẬN PHÒNG',
      tieuDeGio: 'CHỌN GIỜ NHẬN PHÒNG',
    );

    if (thoiGianMoi != null) {
      datPhongProvider.datNgayNhan(thoiGianMoi);
    }
  }

  Future<void> _moHopThoaiChonGioNhan(
    BuildContext nguoiCanh,
    DatPhongProvider datPhongProvider,
  ) async {
    final thoiGianMoi = await XuLyNgay.chonGio(
      context: nguoiCanh,
      thoiGianHienTai: datPhongProvider.ngayNhanPhong,
      tieuDeGio: 'CHỌN GIỜ NHẬN PHÒNG',
    );
    if (thoiGianMoi != null) {
      datPhongProvider.datNgayNhan(thoiGianMoi);
    }
  }

  Future<void> _moHopThoaiChonNgayTra(
    BuildContext nguoiCanh,
    DatPhongProvider datPhongProvider,
  ) async {
    final mocToiThieu = DateTime(
      datPhongProvider.ngayNhanPhong.year,
      datPhongProvider.ngayNhanPhong.month,
      datPhongProvider.ngayNhanPhong.day,
    );

    final thoiGianMoi = await XuLyNgay.chonNgayVaGio(
      context: nguoiCanh,
      thoiGianHienTai: datPhongProvider.ngayTraPhong,
      mocToiThieu: mocToiThieu,
      tieuDeNgay: 'CHỌN NGÀY TRẢ PHÒNG',
      tieuDeGio: 'CHỌN GIỜ TRẢ PHÒNG',
    );

    if (thoiGianMoi != null) {
      if (thoiGianMoi.isAfter(datPhongProvider.ngayNhanPhong)) {
        datPhongProvider.datNgayTra(thoiGianMoi);
      } else {
        if (nguoiCanh.mounted) {
          ScaffoldMessenger.of(nguoiCanh).showSnackBar(
            const SnackBar(content: Text('Thời gian trả phòng phải sau thời gian nhận phòng!')),
          );
        }
      }
    }
  }

  Future<void> _moHopThoaiChonGioTra(
    BuildContext nguoiCanh,
    DatPhongProvider datPhongProvider,
  ) async {
    final thoiGianMoi = await XuLyNgay.chonGio(
      context: nguoiCanh,
      thoiGianHienTai: datPhongProvider.ngayTraPhong,
      tieuDeGio: 'CHỌN GIỜ TRẢ PHÒNG',
    );
    if (thoiGianMoi != null) {
      if (thoiGianMoi.isAfter(datPhongProvider.ngayNhanPhong)) {
        datPhongProvider.datNgayTra(thoiGianMoi);
      } else {
        if (nguoiCanh.mounted) {
          ScaffoldMessenger.of(nguoiCanh).showSnackBar(
            const SnackBar(content: Text('Thời gian trả phòng phải sau thời gian nhận phòng!')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext nguoiCanh) {
    final datPhongProvider = Provider.of<DatPhongProvider>(nguoiCanh);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: MauSacApp.mauBeMat,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MauSacApp.mauChinh.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.hotel_rounded,
                  color: MauSacApp.mauChinh,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Tìm & Đặt Phòng Nhanh',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: MauSacApp.mauChuChinh,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Khung chon ngay va gio
          Row(
            children: [
              // Hop ngay & gio nhan
              Expanded(
                child: InkWell(
                  onTap: () => _moHopThoaiChonNgayNhan(nguoiCanh, datPhongProvider),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: MauSacApp.mauBeMatPhu,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 12, color: MauSacApp.mauChuPhu),
                            SizedBox(width: 5),
                            Text(
                              'Nhận phòng',
                              style: TextStyle(
                                fontSize: 11,
                                color: MauSacApp.mauChuPhu,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DinhDang.dinhDangNgay(datPhongProvider.ngayNhanPhong),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: MauSacApp.mauChuChinh,
                          ),
                        ),
                        const SizedBox(height: 3),
                        GestureDetector(
                          onTap: () => _moHopThoaiChonGioNhan(nguoiCanh, datPhongProvider),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time_rounded, size: 11, color: MauSacApp.mauChinh),
                              const SizedBox(width: 3),
                              Text(
                                DinhDang.dinhDangGio(datPhongProvider.ngayNhanPhong),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: MauSacApp.mauChinh,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: MauSacApp.mauDiemNhan.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${datPhongProvider.soDem} đêm',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: MauSacApp.mauDiemNhan,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Hop ngay & gio tra
              Expanded(
                child: InkWell(
                  onTap: () => _moHopThoaiChonNgayTra(nguoiCanh, datPhongProvider),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: MauSacApp.mauBeMatPhu,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.event_available_rounded, size: 12, color: MauSacApp.mauChuPhu),
                            SizedBox(width: 5),
                            Text(
                              'Trả phòng',
                              style: TextStyle(
                                fontSize: 11,
                                color: MauSacApp.mauChuPhu,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DinhDang.dinhDangNgay(datPhongProvider.ngayTraPhong),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: MauSacApp.mauChuChinh,
                          ),
                        ),
                        const SizedBox(height: 3),
                        GestureDetector(
                          onTap: () => _moHopThoaiChonGioTra(nguoiCanh, datPhongProvider),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time_rounded, size: 11, color: MauSacApp.mauDiemNhan),
                              const SizedBox(width: 3),
                              Text(
                                DinhDang.dinhDangGio(datPhongProvider.ngayTraPhong),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: MauSacApp.mauDiemNhan,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // So luong nguoi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: MauSacApp.mauBeMatPhu,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.people_alt_rounded, size: 18, color: MauSacApp.mauChinh),
                    SizedBox(width: 8),
                    Text(
                      'Số người:',
                      style: TextStyle(
                        fontSize: 13,
                        color: MauSacApp.mauChuChinh,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (datPhongProvider.soKhach > 1) {
                          datPhongProvider.datSoKhach(datPhongProvider.soKhach - 1);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(Icons.remove, size: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${datPhongProvider.soKhach} Người',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: MauSacApp.mauChuChinh,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        datPhongProvider.datSoKhach(datPhongProvider.soKhach + 1);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(Icons.add, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Nut tim kiem
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: khiBamTimKiem,
              style: ElevatedButton.styleFrom(
                backgroundColor: MauSacApp.mauChinh,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.search_rounded, size: 20),
              label: const Text(
                'Tìm Phòng Trống Ngay',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
