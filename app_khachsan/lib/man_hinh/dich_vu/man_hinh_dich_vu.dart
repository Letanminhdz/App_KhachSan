import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../cau_hinh/cau_hinh_api.dart';
import '../../cau_hinh/mau_sac_app.dart';
import '../../dich_vu/dat_phong_dich_vu.dart';
import '../../dich_vu/khach_san_dich_vu.dart';
import '../../mo_hinh/dat_phong.dart';
import '../../mo_hinh/dich_vu.dart';
import '../../quan_ly_trang_thai/xac_thuc_provider.dart';
import '../../tien_ich/dinh_dang.dart';
import '../xac_thuc/man_hinh_dang_nhap.dart';
import '../tai_khoan/man_hinh_chi_tiet_dat_phong.dart';

class ManHinhDichVu extends StatefulWidget {
  const ManHinhDichVu({super.key});

  @override
  State<ManHinhDichVu> createState() => _ManHinhDichVuTrangThai();
}

class _ManHinhDichVuTrangThai extends State<ManHinhDichVu> {
  List<DichVu> _danhSachDichVu = [];
  bool _dangTai = true;
  String? _thongBaoLoi;
  final Map<int, int> _soLuongChon = {};

  DatPhong? _donDangLuuTru;
  bool _dangKiemTraDon = true;

  @override
  void initState() {
    super.initState();
    _khoiTao();
  }

  Future<void> _khoiTao() async {
    final xacThucProvider = Provider.of<XacThucProvider>(context, listen: false);
    if (!xacThucProvider.daDangNhap) {
      setState(() {
        _dangTai = false;
        _dangKiemTraDon = false;
      });
      return;
    }
    await _kiemTraDonDangLuuTru();
    await _taiDanhSachDichVu();
  }

  Future<void> _kiemTraDonDangLuuTru() async {
    try {
      final danhSach = await DatPhongDichVu.layLichSuDatPhong();
      final donActive = danhSach.where((d) => d.trangThai == 'Da_Nhan_Phong').toList();
      setState(() {
        _donDangLuuTru = donActive.isNotEmpty ? donActive.first : null;
        _dangKiemTraDon = false;
      });
    } catch (_) {
      setState(() {
        _donDangLuuTru = null;
        _dangKiemTraDon = false;
      });
    }
  }

  Future<void> _taiDanhSachDichVu() async {
    setState(() {
      _dangTai = true;
      _thongBaoLoi = null;
    });
    try {
      final ketQua = await KhachSanDichVu.layDanhSachDichVu();
      setState(() {
        _danhSachDichVu = ketQua;
        for (var dv in ketQua) {
          _soLuongChon[dv.id] = 1;
        }
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

  // -----------------------------------------------------------------------
  // Goi dich vu: 1 phong → tu dong chon | nhieu phong → hien list chon
  // -----------------------------------------------------------------------

  Future<void> _moHopThoaiGoiDichVu(DichVu dv) async {
    final danhSachPhong = _donDangLuuTru?.danhSachSoPhong ?? [];
    final soLuong = _soLuongChon[dv.id] ?? 1;
    final tongTien = dv.gia * soLuong;

    String? soPhongDaChon;

    if (danhSachPhong.isEmpty) {
      final phongController = TextEditingController();
      final nhapXong = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.meeting_room_rounded, color: MauSacApp.mauChinh),
              SizedBox(width: 8),
              Text('Nhập số phòng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chưa tìm thấy phòng được gán tự động. Vui lòng nhập số phòng bạn đang lưu trú:'),
              const SizedBox(height: 12),
              TextField(
                controller: phongController,
                autofocus: true,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Ví dụ: 101, 102...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.room_preferences_rounded),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (phongController.text.trim().isNotEmpty) {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('Tiếp tục'),
            ),
          ],
        ),
      );

      if (nhapXong != true || phongController.text.trim().isEmpty) return;
      soPhongDaChon = phongController.text.trim();

      if (!mounted) return;
      final xacNhan = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _bottomSheetXacNhan(
          ctx: ctx,
          dv: dv,
          soLuong: soLuong,
          tongTien: tongTien,
          soPhong: soPhongDaChon!,
        ),
      );
      if (xacNhan != true) return;
    }
    // --- 1 phong: tu dong chon, chi hien xac nhan ---
    else if (danhSachPhong.length == 1) {
      soPhongDaChon = danhSachPhong.first;
      final xacNhan = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _bottomSheetXacNhan(
          ctx: ctx,
          dv: dv,
          soLuong: soLuong,
          tongTien: tongTien,
          soPhong: soPhongDaChon!,
        ),
      );
      if (xacNhan != true) return;
    }
    // --- Nhieu phong: hien danh sach chon ---
    else {
      final ketQua = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _bottomSheetChonPhong(
          ctx: ctx,
          dv: dv,
          soLuong: soLuong,
          tongTien: tongTien,
          danhSachPhong: danhSachPhong,
        ),
      );
      if (ketQua == null) return;
      soPhongDaChon = ketQua;
    }

    // Goi API
    try {
      final kq = await KhachSanDichVu.goiDichVu(
        idDichVu: dv.id,
        soLuong: soLuong,
        soPhong: soPhongDaChon,
        idDatPhong: _donDangLuuTru?.id,
      );
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: MauSacApp.mauThanhCong, size: 28),
                SizedBox(width: 8),
                Text('Gọi Thành Công!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              ],
            ),
            content: Text(
              kq['message'] ?? 'Yêu cầu đã được gửi tới nhân viên phục vụ phòng $soPhongDaChon.',
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đã hiểu'),
              ),
            ],
          ),
        );
      }
    } catch (loi) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $loi'), backgroundColor: MauSacApp.mauLoi),
        );
      }
    }
  }

  /// Bottom sheet xac nhan (1 phong - tu dong dien)
  Widget _bottomSheetXacNhan({
    required BuildContext ctx,
    required DichVu dv,
    required int soLuong,
    required double tongTien,
    required String soPhong,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.room_service_rounded, color: MauSacApp.mauChinh, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Gọi ${dv.tenDichVu} Tới Phòng',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: MauSacApp.mauChuChinh),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // So luong & tong tien
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: MauSacApp.mauNen, borderRadius: BorderRadius.circular(14)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Số lượng đặt:', style: TextStyle(fontSize: 12, color: MauSacApp.mauChuPhu)),
                  Text('$soLuong suất', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text('Tổng thanh toán:', style: TextStyle(fontSize: 12, color: MauSacApp.mauChuPhu)),
                  Text(
                    DinhDang.dinhDangTien(tongTien),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: MauSacApp.mauDiemNhan),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Phong tu dong - hien dep
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: MauSacApp.mauThanhCong.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: MauSacApp.mauThanhCong.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.meeting_room_rounded, color: MauSacApp.mauThanhCong, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Giao tới phòng của bạn', style: TextStyle(fontSize: 12, color: MauSacApp.mauChuPhu)),
                      Text(
                        'Phòng $soPhong',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: MauSacApp.mauThanhCong),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle_rounded, color: MauSacApp.mauThanhCong, size: 22),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MauSacApp.mauChinh,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'Xác Nhận Gọi Tới Phòng',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom sheet chon phong (nhieu phong - radio list)
  Widget _bottomSheetChonPhong({
    required BuildContext ctx,
    required DichVu dv,
    required int soLuong,
    required double tongTien,
    required List<String> danhSachPhong,
  }) {
    String phongDangChon = danhSachPhong.first;

    return StatefulBuilder(
      builder: (_, setStateCon) => Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(Icons.room_service_rounded, color: MauSacApp.mauChinh, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Gọi ${dv.tenDichVu} Tới Phòng',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: MauSacApp.mauChuChinh),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // So luong & tong tien
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: MauSacApp.mauNen, borderRadius: BorderRadius.circular(14)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Số lượng đặt:', style: TextStyle(fontSize: 12, color: MauSacApp.mauChuPhu)),
                    Text('$soLuong suất', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    const Text('Tổng thanh toán:', style: TextStyle(fontSize: 12, color: MauSacApp.mauChuPhu)),
                    Text(
                      DinhDang.dinhDangTien(tongTien),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: MauSacApp.mauDiemNhan),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chọn phòng nhận dịch vụ:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: MauSacApp.mauChuChinh),
            ),
            const SizedBox(height: 10),
            // Danh sach phong - tap de chon
            ...danhSachPhong.map((soPhong) {
              final laDangChon = phongDangChon == soPhong;
              return GestureDetector(
                onTap: () => setStateCon(() => phongDangChon = soPhong),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: laDangChon ? MauSacApp.mauChinh.withValues(alpha: 0.08) : MauSacApp.mauBeMatPhu,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: laDangChon ? MauSacApp.mauChinh : const Color(0xFFE2E8F0),
                      width: laDangChon ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.meeting_room_outlined,
                        color: laDangChon ? MauSacApp.mauChinh : MauSacApp.mauChuMo,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Phòng $soPhong',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: laDangChon ? FontWeight.w800 : FontWeight.w500,
                            color: laDangChon ? MauSacApp.mauChinh : MauSacApp.mauChuChinh,
                          ),
                        ),
                      ),
                      Icon(
                        laDangChon ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                        color: laDangChon ? MauSacApp.mauChinh : MauSacApp.mauChuMo,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MauSacApp.mauChinh,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(ctx, phongDangChon),
                child: const Text(
                  'Xác Nhận Gọi Tới Phòng',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // UI States
  // -----------------------------------------------------------------------

  Widget _xayDungManHinhChuaDangNhap() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: MauSacApp.mauChinh.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_rounded, size: 56, color: MauSacApp.mauChinh),
            ),
            const SizedBox(height: 24),
            const Text(
              'Cần Đăng Nhập',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: MauSacApp.mauChuChinh),
            ),
            const SizedBox(height: 12),
            const Text(
              'Bạn cần đăng nhập để sử dụng dịch vụ tận phòng của khách sạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: MauSacApp.mauChuPhu, height: 1.6),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MauSacApp.mauChinh,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ManHinhDangNhap()),
                  ).then((_) => _khoiTao());
                },
                child: const Text(
                  'Đăng Nhập Ngay',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _xayDungManHinhKhongLuuTru() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hotel_rounded, size: 56, color: Color(0xFFF59E0B)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bạn Chưa Đang Lưu Trú',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: MauSacApp.mauChuChinh),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Dịch vụ tận phòng chỉ dành cho khách hàng đang có đơn đặt phòng ở trạng thái "Đang lưu trú".\n\nVui lòng liên hệ lễ tân để được hỗ trợ nhận phòng.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: MauSacApp.mauChuPhu, height: 1.6),
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: MauSacApp.mauChinh),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => _kiemTraDonDangLuuTru(),
              icon: const Icon(Icons.refresh_rounded, color: MauSacApp.mauChinh),
              label: const Text('Kiểm Tra Lại', style: TextStyle(color: MauSacApp.mauChinh, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final xacThucProvider = Provider.of<XacThucProvider>(context);

    return Scaffold(
      backgroundColor: MauSacApp.mauNen,
      appBar: AppBar(title: const Text('Dịch Vụ Khách Sạn')),
      body: _dangTai || _dangKiemTraDon
          ? const Center(child: CircularProgressIndicator())
          : !xacThucProvider.daDangNhap
              ? _xayDungManHinhChuaDangNhap()
              : _donDangLuuTru == null
                  ? _xayDungManHinhKhongLuuTru()
                  : RefreshIndicator(
                      onRefresh: _taiDanhSachDichVu,
                      color: MauSacApp.mauChinh,
                      child: _thongBaoLoi != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.wifi_off_rounded, size: 48, color: MauSacApp.mauChuMo),
                                  const SizedBox(height: 12),
                                  Text(_thongBaoLoi!, style: const TextStyle(color: MauSacApp.mauChuPhu)),
                                  const SizedBox(height: 12),
                                  ElevatedButton(onPressed: _taiDanhSachDichVu, child: const Text('Thử lại')),
                                ],
                              ),
                            )
                          : ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                // Banner dang luu tru - bam vao de xem chi tiet hoa don
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ManHinhChiTietDatPhong(
                                            idDon: _donDangLuuTru!.id,
                                            donBanDau: _donDangLuuTru,
                                          ),
                                        ),
                                      ).then((_) => _kiemTraDonDangLuuTru());
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF059669), Color(0xFF10B981)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          const CircleAvatar(
                                            radius: 22,
                                            backgroundColor: Colors.white24,
                                            child: Icon(Icons.hotel_rounded, color: Colors.white, size: 24),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Đang Lưu Trú',
                                                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                                                Text(_donDangLuuTru!.tenLoaiPhong,
                                                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                                                if (_donDangLuuTru!.danhSachSoPhong.isNotEmpty)
                                                  Text(
                                                    'Phòng: ${_donDangLuuTru!.danhSachSoPhong.join(', ')}',
                                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Row(
                                              children: [
                                                Text(
                                                  'Chi tiết',
                                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                                                ),
                                                SizedBox(width: 2),
                                                Icon(Icons.chevron_right_rounded, color: Colors.white, size: 16),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Banner dich vu
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [MauSacApp.mauChinhDam, MauSacApp.mauChinh],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: MauSacApp.mauChinh.withValues(alpha: 0.25),
                                        blurRadius: 15,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Dịch Vụ Tận Phòng 24/7',
                                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                                            SizedBox(height: 6),
                                            Text(
                                              'Ẩm thực hảo hạng, đồ uống tươi mát và spa thư giãn phục vụ trực tiếp tại phòng của bạn.',
                                              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Colors.white24,
                                        child: Icon(Icons.room_service_rounded, color: Colors.white, size: 30),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),
                                const Text(
                                  'Danh Sách Dịch Vụ & Món Ăn',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: MauSacApp.mauChuChinh),
                                ),
                                const SizedBox(height: 12),

                                ..._danhSachDichVu.map((dv) {
                                  final soLuong = _soLuongChon[dv.id] ?? 1;
                                  final duongDanAnh = CauHinhApi.layDuongDanAnh(dv.hinhAnh);

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: MauSacApp.mauBeMat,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.03),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                          child: AspectRatio(
                                            aspectRatio: 16 / 9,
                                            child: duongDanAnh.isNotEmpty
                                                ? CachedNetworkImage(
                                                    imageUrl: duongDanAnh,
                                                    fit: BoxFit.cover,
                                                    placeholder: (c, u) => Container(color: MauSacApp.mauBeMatPhu),
                                                    errorWidget: (c, u, e) => Container(
                                                      color: MauSacApp.mauBeMatPhu,
                                                      child: const Icon(Icons.restaurant, color: MauSacApp.mauChuMo, size: 40),
                                                    ),
                                                  )
                                                : Container(
                                                    color: MauSacApp.mauBeMatPhu,
                                                    child: const Icon(Icons.restaurant, color: MauSacApp.mauChuMo, size: 40),
                                                  ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      dv.tenDichVu,
                                                      style: const TextStyle(
                                                          fontSize: 16, fontWeight: FontWeight.w800, color: MauSacApp.mauChuChinh),
                                                    ),
                                                  ),
                                                  Text(
                                                    DinhDang.dinhDangTien(dv.gia),
                                                    style: const TextStyle(
                                                        fontSize: 16, fontWeight: FontWeight.w800, color: MauSacApp.mauDiemNhan),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: MauSacApp.mauBeMatPhu,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(Icons.remove, size: 18),
                                                          onPressed: soLuong > 1
                                                              ? () => setState(() => _soLuongChon[dv.id] = soLuong - 1)
                                                              : null,
                                                        ),
                                                        Text('$soLuong',
                                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                                                        IconButton(
                                                          icon: const Icon(Icons.add, size: 18),
                                                          onPressed: () => setState(() => _soLuongChon[dv.id] = soLuong + 1),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: ElevatedButton.icon(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: MauSacApp.mauChinh,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(12)),
                                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                                      ),
                                                      onPressed: () => _moHopThoaiGoiDichVu(dv),
                                                      icon: const Icon(Icons.room_service, size: 18, color: Colors.white),
                                                      label: const Text(
                                                        'Gọi Tới Phòng',
                                                        style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
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
                                  );
                                }),
                              ],
                            ),
                    ),
    );
  }
}
