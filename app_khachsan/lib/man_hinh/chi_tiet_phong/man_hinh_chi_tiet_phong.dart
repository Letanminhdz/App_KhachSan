import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../cau_hinh/cau_hinh_api.dart';
import '../../cau_hinh/mau_sac_app.dart';
import '../../mo_hinh/loai_phong.dart';
import '../../quan_ly_trang_thai/dat_phong_provider.dart';
import '../../quan_ly_trang_thai/xac_thuc_provider.dart';
import '../../tien_ich/dinh_dang.dart';
import '../dat_phong/man_hinh_dat_phong.dart';
import '../xac_thuc/man_hinh_dang_nhap.dart';

class ManHinhChiTietPhong extends StatefulWidget {
  final LoaiPhong loaiPhong;

  const ManHinhChiTietPhong({
    super.key,
    required this.loaiPhong,
  });

  @override
  State<ManHinhChiTietPhong> createState() => _ManHinhChiTietPhongTrangThai();
}

class _ManHinhChiTietPhongTrangThai extends State<ManHinhChiTietPhong> {
  int _viTriAnhHienTai = 0;

  List<String> get _danhSachHinhAnh {
    final danhSach = <String>[];
    if (widget.loaiPhong.hinhAnh != null && widget.loaiPhong.hinhAnh!.trim().isNotEmpty) {
      final linkChinh = CauHinhApi.layDuongDanAnh(widget.loaiPhong.hinhAnh);
      if (linkChinh.isNotEmpty) {
        danhSach.add(linkChinh);
      }
    }
    for (var anhPhu in widget.loaiPhong.hinhAnhPhu) {
      if (anhPhu.trim().isNotEmpty) {
        final linkPhu = CauHinhApi.layDuongDanAnh(anhPhu);
        if (linkPhu.isNotEmpty) {
          danhSach.add(linkPhu);
        }
      }
    }
    return danhSach;
  }

  /// Kiem tra dang nhap truoc khi dat phong
  void _xuLyDatPhong(BuildContext nguoiCanh) {
    final xacThucProvider = Provider.of<XacThucProvider>(nguoiCanh, listen: false);

    if (!xacThucProvider.daDangNhap) {
      _hienThiDialogYeuCauDangNhap(nguoiCanh);
      return;
    }

    final datPhongProvider = Provider.of<DatPhongProvider>(nguoiCanh, listen: false);
    datPhongProvider.chonLoaiPhong(widget.loaiPhong);
    Navigator.push(
      nguoiCanh,
      MaterialPageRoute(
        builder: (nguoiCanhMoi) => ManHinhDatPhong(loaiPhong: widget.loaiPhong),
      ),
    );
  }

  void _hienThiDialogYeuCauDangNhap(BuildContext nguoiCanh) {
    showDialog(
      context: nguoiCanh,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: MauSacApp.mauChinh.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: MauSacApp.mauChinh,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Cần Đăng Nhập',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: MauSacApp.mauChuChinh,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Bạn cần đăng nhập để tiến hành đặt phòng. Vui lòng đăng nhập hoặc tạo tài khoản mới.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: MauSacApp.mauChuPhu,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MauSacApp.mauChinh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      nguoiCanh,
                      MaterialPageRoute(
                        builder: (_) => const ManHinhDangNhap(),
                      ),
                    );
                  },
                  child: const Text(
                    'Đăng Nhập Ngay',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Để Sau',
                  style: TextStyle(color: MauSacApp.mauChuPhu),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext nguoiCanh) {
    final datPhongProvider = Provider.of<DatPhongProvider>(nguoiCanh);
    final soDem = datPhongProvider.soDem;
    final tongTien = widget.loaiPhong.giaCoBan * soDem * datPhongProvider.soLuongPhong;

    return Scaffold(
      backgroundColor: MauSacApp.mauNen,
      body: CustomScrollView(
        slivers: [
          // AppBar cuon voi hinh anh
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(nguoiCanh),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    itemCount: _danhSachHinhAnh.isEmpty ? 1 : _danhSachHinhAnh.length,
                    onPageChanged: (viTri) {
                      setState(() {
                        _viTriAnhHienTai = viTri;
                      });
                    },
                    itemBuilder: (nguoiCanhAnh, viTri) {
                      if (_danhSachHinhAnh.isEmpty) {
                        return Container(
                          color: MauSacApp.mauBeMatPhu,
                          child: const Center(
                            child: Icon(Icons.hotel_rounded, size: 64, color: MauSacApp.mauChuMo),
                          ),
                        );
                      }
                      return CachedNetworkImage(
                        imageUrl: _danhSachHinhAnh[viTri],
                        fit: BoxFit.cover,
                        placeholder: (nguoiCanhDem, duongDan) => Container(
                          color: MauSacApp.mauBeMatPhu,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (nguoiCanhDem, duongDan, loi) => Container(
                          color: MauSacApp.mauBeMatPhu,
                          child: const Center(
                            child: Icon(Icons.hotel_rounded, size: 48, color: MauSacApp.mauChuMo),
                          ),
                        ),
                      );
                    },
                  ),
                  // Chi so trang anh
                  if (_danhSachHinhAnh.length > 1)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_viTriAnhHienTai + 1} / ${_danhSachHinhAnh.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Noi dung chi tiet
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tieu de & Gia
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.loaiPhong.tenLoai,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: MauSacApp.mauChuChinh,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.people_outline, size: 16, color: MauSacApp.mauChuPhu),
                                const SizedBox(width: 4),
                                Text(
                                  'Tiêu chuẩn: ${widget.loaiPhong.sucChua} người lớn',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: MauSacApp.mauChuPhu,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DinhDang.dinhDangTien(widget.loaiPhong.giaCoBan),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: MauSacApp.mauDiemNhan,
                            ),
                          ),
                          const Text(
                            '/ 1 đêm',
                            style: TextStyle(
                              fontSize: 12,
                              color: MauSacApp.mauChuMo,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  // Mo ta
                  const Text(
                    'Mô tả phòng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: MauSacApp.mauChuChinh,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.loaiPhong.moTa ?? 'Không gian nghỉ dưỡng sang trọng đầy đủ tiện nghi.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: MauSacApp.mauChuPhu,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  // Tien ich phong
                  const Text(
                    'Tiện nghi phòng nghỉ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: MauSacApp.mauChuChinh,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.loaiPhong.tienIch.map((tienIch) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: MauSacApp.mauBeMat,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 16, color: MauSacApp.mauThanhCong),
                            const SizedBox(width: 8),
                            Text(
                              tienIch,
                              style: const TextStyle(
                                fontSize: 13,
                                color: MauSacApp.mauChuChinh,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  // Thoi gian nhan tra phong
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: MauSacApp.mauChinh.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: MauSacApp.mauChinh.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ngày nhận phòng:',
                              style: TextStyle(fontSize: 13, color: MauSacApp.mauChuPhu),
                            ),
                            Text(
                              DinhDang.dinhDangNgay(datPhongProvider.ngayNhanPhong),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ngày trả phòng:',
                              style: TextStyle(fontSize: 13, color: MauSacApp.mauChuPhu),
                            ),
                            Text(
                              DinhDang.dinhDangNgay(datPhongProvider.ngayTraPhong),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tổng thời gian lưu trú:',
                              style: TextStyle(fontSize: 13, color: MauSacApp.mauChuPhu),
                            ),
                            Text(
                              '$soDem đêm ($soDem ngày)',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: MauSacApp.mauChinh,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Khoang trong duoi cung cho bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      // Thanh dat phong co dinh o duoi
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: MauSacApp.mauBeMat,
          border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tổng tạm tính:',
                      style: TextStyle(fontSize: 12, color: MauSacApp.mauChuPhu),
                    ),
                    Text(
                      DinhDang.dinhDangTien(tongTien),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: MauSacApp.mauDiemNhan,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _xuLyDatPhong(nguoiCanh),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MauSacApp.mauChinh,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                ),
                child: const Text(
                  'Tiến Hành Đặt Phòng',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
