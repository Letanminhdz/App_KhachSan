import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../cau_hinh/mau_sac_app.dart';

class BannerQuangCao extends StatelessWidget {
  const BannerQuangCao({super.key});

  @override
  Widget build(BuildContext nguoiCanh) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MauSacApp.mauChinhDam.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl:
                    'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=1200&auto=format&fit=crop&q=80',
                fit: BoxFit.cover,
                placeholder: (nguoiCanhAnh, duongDan) => Container(
                  color: MauSacApp.mauChinhDam,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
                errorWidget: (nguoiCanhAnh, duongDan, loi) => Container(
                  color: MauSacApp.mauChinhDam,
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      MauSacApp.mauChinhDam.withValues(alpha: 0.85),
                      MauSacApp.mauChinh.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: MauSacApp.mauDiemNhan,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ƯU ĐÃI ĐẶT PHÒNG',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Khám Phá Không Gian Nghỉ Dưỡng Đẳng Cấp',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Giảm đến 20% khi đặt phòng trực tiếp trên ứng dụng',
                    style: TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 12,
                    ),
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
