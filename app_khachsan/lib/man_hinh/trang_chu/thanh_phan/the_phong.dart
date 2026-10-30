import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../cau_hinh/cau_hinh_api.dart';
import '../../../cau_hinh/mau_sac_app.dart';
import '../../../mo_hinh/loai_phong.dart';
import '../../../tien_ich/dinh_dang.dart';

class ThePhong extends StatelessWidget {
  final LoaiPhong loaiPhong;
  final VoidCallback khiBamXemChiTiet;
  final VoidCallback khiBamDatPhong;

  const ThePhong({
    super.key,
    required this.loaiPhong,
    required this.khiBamXemChiTiet,
    required this.khiBamDatPhong,
  });

  @override
  Widget build(BuildContext nguoiCanh) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: MauSacApp.mauBeMat,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: khiBamXemChiTiet,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Anh loai phong
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Builder(
                      builder: (context) {
                        final duongDanAnh = CauHinhApi.layDuongDanAnh(loaiPhong.hinhAnh);
                        if (duongDanAnh.isEmpty) {
                          return Container(
                            color: MauSacApp.mauBeMatPhu,
                            child: const Center(
                              child: Icon(Icons.hotel_rounded, size: 48, color: MauSacApp.mauChuMo),
                            ),
                          );
                        }
                        return CachedNetworkImage(
                          imageUrl: duongDanAnh,
                          fit: BoxFit.cover,
                          placeholder: (nguoiCanhAnh, duongDan) => Container(
                            color: MauSacApp.mauBeMatPhu,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (nguoiCanhAnh, duongDan, loi) => Container(
                            color: MauSacApp.mauBeMatPhu,
                            child: const Center(
                              child: Icon(Icons.hotel_rounded, size: 48, color: MauSacApp.mauChuMo),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Huy hieu suc chua
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_alt_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '${loaiPhong.sucChua} Người',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Huy hieu so luong phong con trong neu co
                if (loaiPhong.soLuongTrong != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: loaiPhong.soLuongTrong! > 0
                            ? MauSacApp.mauThanhCong
                            : MauSacApp.mauLoi,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        loaiPhong.soLuongTrong! > 0
                            ? 'Còn ${loaiPhong.soLuongTrong} phòng'
                            : 'Hết phòng',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Thong tin phong
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          loaiPhong.tenLoai,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: MauSacApp.mauChuChinh,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DinhDang.dinhDangTien(loaiPhong.giaCoBan),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: MauSacApp.mauDiemNhan,
                            ),
                          ),
                          const Text(
                            '/ đêm',
                            style: TextStyle(
                              fontSize: 11,
                              color: MauSacApp.mauChuMo,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (loaiPhong.moTa != null && loaiPhong.moTa!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      loaiPhong.moTa!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: MauSacApp.mauChuPhu,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Cac tien ich noi bat
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: loaiPhong.tienIch.take(3).map((tienIch) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: MauSacApp.mauBeMatPhu,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tienIch,
                          style: const TextStyle(
                            fontSize: 11,
                            color: MauSacApp.mauChuPhu,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  // Nut hanh dong
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: khiBamXemChiTiet,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Xem Chi Tiết',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: MauSacApp.mauChuChinh,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: khiBamDatPhong,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MauSacApp.mauChinh,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Đặt Ngay',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
