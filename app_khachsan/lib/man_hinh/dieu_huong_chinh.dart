import 'package:flutter/material.dart';
import '../cau_hinh/mau_sac_app.dart';
import 'tai_khoan/man_hinh_tai_khoan.dart';
import 'tim_kiem/man_hinh_tim_kiem.dart';
import 'trang_chu/man_hinh_trang_chu.dart';
import 'tro_ly_ai/man_hinh_tro_ly_ai.dart';

class DieuHuongChinh extends StatefulWidget {
  const DieuHuongChinh({super.key});

  /// Chuyen tab tu bat ky man hinh con nao
  static void chuyenTab(BuildContext context, int viTriTab) {
    final state = context.findAncestorStateOfType<_DieuHuongChinhTrangThai>();
    state?.chonTab(viTriTab);
  }

  @override
  State<DieuHuongChinh> createState() => _DieuHuongChinhTrangThai();
}

class _DieuHuongChinhTrangThai extends State<DieuHuongChinh> {
  int _viTriTabHienTai = 0;

  void chonTab(int viTri) {
    if (mounted) {
      setState(() {
        _viTriTabHienTai = viTri;
      });
    }
  }

  late final List<Widget> _danhSachManHinh = [
    const ManHinhTrangChu(),
    const ManHinhTimKiem(),
    const ManHinhTroLyAi(),
    ManHinhTaiKhoan(onChuyenTab: (viTri) => chonTab(viTri)),
  ];

  @override
  Widget build(BuildContext nguoiCanh) {
    return Scaffold(
      body: IndexedStack(
        index: _viTriTabHienTai,
        children: _danhSachManHinh,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: MauSacApp.mauBeMat,
          border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _viTriTabHienTai,
          onDestinationSelected: (viTri) {
            setState(() {
              _viTriTabHienTai = viTri;
            });
          },
          backgroundColor: MauSacApp.mauBeMat,
          indicatorColor: MauSacApp.mauChinh.withValues(alpha: 0.12),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: MauSacApp.mauChinh),
              label: 'Trang Chủ',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search_rounded, color: MauSacApp.mauChinh),
              label: 'Tìm Phòng',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome, color: MauSacApp.mauDiemNhan),
              label: 'Trợ Lý AI',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: MauSacApp.mauChinh),
              label: 'Tài Khoản',
            ),
          ],
        ),
      ),
    );
  }
}
