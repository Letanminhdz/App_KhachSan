import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../cau_hinh/mau_sac_app.dart';
import '../../dich_vu/dat_phong_dich_vu.dart';
import '../../mo_hinh/dat_phong.dart';
import '../../quan_ly_trang_thai/xac_thuc_provider.dart';
import '../../tien_ich/dinh_dang.dart';
import '../xac_thuc/man_hinh_dang_nhap.dart';
import 'man_hinh_chi_tiet_dat_phong.dart';

class ManHinhLichSuDon extends StatefulWidget {
  const ManHinhLichSuDon({super.key});

  @override
  State<ManHinhLichSuDon> createState() => _ManHinhLichSuDonTrangThai();
}

class _ManHinhLichSuDonTrangThai extends State<ManHinhLichSuDon> {
  List<DatPhong> _danhSachDon = [];
  bool _dangTai = true;
  String? _thongBaoLoi;

  @override
  void initState() {
    super.initState();
    _taiLichSuDatPhong();
  }

  Future<void> _taiLichSuDatPhong() async {
    final xacThucProvider = Provider.of<XacThucProvider>(context, listen: false);
    if (!xacThucProvider.daDangNhap) {
      setState(() {
        _dangTai = false;
      });
      return;
    }

    setState(() {
      _dangTai = true;
      _thongBaoLoi = null;
    });

    try {
      final ketQua = await DatPhongDichVu.layLichSuDatPhong();
      setState(() {
        _danhSachDon = ketQua;
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

    if (!xacThucProvider.daDangNhap) {
      return Scaffold(
        backgroundColor: MauSacApp.mauNen,
        appBar: AppBar(title: const Text('Lịch Sử Đặt Phòng')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_person_outlined, size: 64, color: MauSacApp.mauChuMo),
                const SizedBox(height: 16),
                const Text(
                  'Yêu Cầu Đăng Nhập',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: MauSacApp.mauChuChinh,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Vui lòng đăng nhập để xem danh sách lịch sử các đơn đặt phòng của bạn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: MauSacApp.mauChuPhu),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      nguoiCanh,
                      MaterialPageRoute(builder: (nguoiCanhMoi) => const ManHinhDangNhap()),
                    ).then((_) => _taiLichSuDatPhong());
                  },
                  child: const Text('Đăng Nhập Ngay'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: MauSacApp.mauNen,
      appBar: AppBar(
        title: const Text('Lịch Sử Đặt Phòng'),
      ),
      body: RefreshIndicator(
        onRefresh: _taiLichSuDatPhong,
        color: MauSacApp.mauChinh,
        child: _dangTai
            ? const Center(
                child: CircularProgressIndicator(color: MauSacApp.mauChinh),
              )
            : _thongBaoLoi != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: MauSacApp.mauLoi),
                          const SizedBox(height: 12),
                          Text(
                            _thongBaoLoi!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: MauSacApp.mauLoi),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _taiLichSuDatPhong,
                            child: const Text('Thử Lại'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _danhSachDon.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: MauSacApp.mauChuMo,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Chưa Có Đơn Đặt Phòng',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: MauSacApp.mauChuChinh,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Bạn chưa có giao dịch đặt phòng nào gần đây.',
                                style: TextStyle(fontSize: 14, color: MauSacApp.mauChuPhu),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _danhSachDon.length,
                        itemBuilder: (nguoiCanhMoi, viTri) {
                          final don = _danhSachDon[viTri];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  nguoiCanhMoi,
                                  MaterialPageRoute(
                                    builder: (_) => ManHinhChiTietDatPhong(
                                      idDon: don.id,
                                      donBanDau: don,
                                    ),
                                  ),
                                ).then((_) => _taiLichSuDatPhong());
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: MauSacApp.mauBeMat,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Đơn hàng #${don.id}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: MauSacApp.mauChuChinh,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: don.mauTrangThai.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            don.tenTrangThai,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: don.mauTrangThai,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      don.tenLoaiPhong,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: MauSacApp.mauChinh,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.door_front_door_outlined,
                                            size: 15, color: MauSacApp.mauChuPhu),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Số lượng: ${don.soLuongPhong} phòng',
                                          style: const TextStyle(
                                              fontSize: 13, color: MauSacApp.mauChuPhu),
                                        ),
                                        if (don.danhSachSoPhong.isNotEmpty) ...[
                                          const SizedBox(width: 10),
                                          Text(
                                            '(Phòng: ${don.danhSachSoPhong.join(", ")})',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: MauSacApp.mauThanhCong,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.date_range_outlined,
                                            size: 15, color: MauSacApp.mauChuPhu),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${DinhDang.dinhDangNgay(don.ngayNhanPhong)} - ${DinhDang.dinhDangNgay(don.ngayTraPhong)}',
                                          style: const TextStyle(
                                              fontSize: 13, color: MauSacApp.mauChuPhu),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Tiền phòng:',
                                          style: TextStyle(
                                              fontSize: 13, color: MauSacApp.mauChuPhu),
                                        ),
                                        Text(
                                          DinhDang.dinhDangTien(don.tongTien),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: MauSacApp.mauDiemNhan,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: MauSacApp.mauChinh.withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.receipt_long_rounded, size: 15, color: MauSacApp.mauChinh),
                                              SizedBox(width: 6),
                                              Text(
                                                'Xem phòng, dịch vụ đã gọi & tổng tiền',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: MauSacApp.mauChinh,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 12,
                                            color: MauSacApp.mauChinh,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
