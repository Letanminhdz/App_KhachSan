import '../dich_vu/man_hinh_dich_vu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../cau_hinh/mau_sac_app.dart';
import '../../dich_vu/phong_dich_vu.dart';
import '../../mo_hinh/loai_phong.dart';
import '../../quan_ly_trang_thai/dat_phong_provider.dart';
import '../../quan_ly_trang_thai/xac_thuc_provider.dart';
import '../chi_tiet_phong/man_hinh_chi_tiet_phong.dart';
import '../dat_phong/man_hinh_dat_phong.dart';
import '../tim_kiem/man_hinh_tim_kiem.dart';
import 'thanh_phan/banner_quang_cao.dart';
import 'thanh_phan/khung_tim_kiem_nhanh.dart';
import 'thanh_phan/the_phong.dart';

class ManHinhTrangChu extends StatefulWidget {
  const ManHinhTrangChu({super.key});

  @override
  State<ManHinhTrangChu> createState() => _ManHinhTrangChuTrangThai();
}

class _ManHinhTrangChuTrangThai extends State<ManHinhTrangChu> {
  List<LoaiPhong> _danhSachLoaiPhong = [];
  bool _dangTai = true;
  String? _thongBaoLoi;

  @override
  void initState() {
    super.initState();
    _taiDanhSachLoaiPhong();
  }

  Future<void> _taiDanhSachLoaiPhong() async {
    setState(() {
      _dangTai = true;
      _thongBaoLoi = null;
    });

    try {
      final ketQua = await PhongDichVu.layDanhSachLoaiPhong();
      setState(() {
        _danhSachLoaiPhong = ketQua;
      });
    } catch (loi) {
      setState(() {
        _thongBaoLoi = loi.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _dangTai = false;
      });
    }
  }

  @override
  Widget build(BuildContext nguoiCanh) {
    final xacThucProvider = Provider.of<XacThucProvider>(nguoiCanh);
    final datPhongProvider = Provider.of<DatPhongProvider>(nguoiCanh);
    final nguoiDung = xacThucProvider.nguoiDung;

    return Scaffold(
      backgroundColor: MauSacApp.mauNen,
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nguoiDung != null
                  ? 'Xin chào, ${nguoiDung.hoTen}'
                  : 'Chào mừng đến với Khách Sạn',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: MauSacApp.mauChuChinh,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Trải nghiệm nghỉ dưỡng đẳng cấp 5 sao',
              style: TextStyle(
                fontSize: 12,
                color: MauSacApp.mauChuPhu,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Dịch vụ phòng',
            icon: const Icon(Icons.room_service_outlined, color: MauSacApp.mauChinh),
            onPressed: () {
              Navigator.push(
                nguoiCanh,
                MaterialPageRoute(builder: (nguoiCanhMoi) => const ManHinhDichVu()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: MauSacApp.mauChinh),
            onPressed: () {
              Navigator.push(
                nguoiCanh,
                MaterialPageRoute(builder: (nguoiCanhMoi) => const ManHinhTimKiem()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _taiDanhSachLoaiPhong,
        color: MauSacApp.mauChinh,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // Banner quang cao
            const BannerQuangCao(),

            // Khung tim kiem nhanh
            KhungTimKiemNhanh(
              khiBamTimKiem: () {
                Navigator.push(
                  nguoiCanh,
                  MaterialPageRoute(builder: (nguoiCanhMoi) => const ManHinhTimKiem()),
                );
              },
            ),

            const SizedBox(height: 12),

            // Tieu de danh sach phong
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Các Hạng Phòng Nổi Bật',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: MauSacApp.mauChuChinh,
                    ),
                  ),
                  Text(
                    '${_danhSachLoaiPhong.length} hạng phòng',
                    style: const TextStyle(
                      fontSize: 13,
                      color: MauSacApp.mauChuPhu,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Danh sach phong
            if (_dangTai)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(color: MauSacApp.mauChinh),
                ),
              )
            else if (_thongBaoLoi != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 48, color: MauSacApp.mauLoi),
                    const SizedBox(height: 12),
                    Text(
                      _thongBaoLoi!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: MauSacApp.mauLoi),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _taiDanhSachLoaiPhong,
                      child: const Text('Thử Lại'),
                    ),
                  ],
                ),
              )
            else
              ..._danhSachLoaiPhong.map((loaiPhong) {
                return ThePhong(
                  loaiPhong: loaiPhong,
                  khiBamXemChiTiet: () {
                    Navigator.push(
                      nguoiCanh,
                      MaterialPageRoute(
                        builder: (nguoiCanhMoi) =>
                            ManHinhChiTietPhong(loaiPhong: loaiPhong),
                      ),
                    );
                  },
                  khiBamDatPhong: () {
                    datPhongProvider.chonLoaiPhong(loaiPhong);
                    Navigator.push(
                      nguoiCanh,
                      MaterialPageRoute(
                        builder: (nguoiCanhMoi) =>
                            ManHinhDatPhong(loaiPhong: loaiPhong),
                      ),
                    );
                  },
                );
              }),
          ],
        ),
      ),
    );
  }
}
