import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../cau_hinh/mau_sac_app.dart';
import '../../dich_vu/dat_phong_dich_vu.dart';
import '../../mo_hinh/loai_phong.dart';
import '../../quan_ly_trang_thai/dat_phong_provider.dart';
import '../../quan_ly_trang_thai/xac_thuc_provider.dart';
import '../../tien_ich/dinh_dang.dart';
import '../../tien_ich/xu_ly_ngay.dart';
import '../xac_thuc/man_hinh_dang_nhap.dart';
import 'man_hinh_dat_thanh_cong.dart';

class ManHinhDatPhong extends StatefulWidget {
  final LoaiPhong loaiPhong;

  const ManHinhDatPhong({
    super.key,
    required this.loaiPhong,
  });

  @override
  State<ManHinhDatPhong> createState() => _ManHinhDatPhongTrangThai();
}

class _ManHinhDatPhongTrangThai extends State<ManHinhDatPhong> {
  final _khoaBieuMau = GlobalKey<FormState>();
  late TextEditingController _dieuKhienTen;
  late TextEditingController _dieuKhienSdt;
  bool _dangXuLy = false;
  String? _thongBaoLoi;

  @override
  void initState() {
    super.initState();
    final xacThucProvider = Provider.of<XacThucProvider>(context, listen: false);
    final nguoiDung = xacThucProvider.nguoiDung;
    _dieuKhienTen = TextEditingController(text: nguoiDung?.hoTen ?? '');
    _dieuKhienSdt = TextEditingController(text: nguoiDung?.soDienThoai ?? '');

    // Kiem tra dang nhap — chuyen den trang dang nhap neu chua dang nhap
    if (!xacThucProvider.daDangNhap) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pop(context);
          _hienThiDialogYeuCauDangNhap(context);
        }
      });
    }
  }

  /// Hien dialog yeu cau dang nhap
  void _hienThiDialogYeuCauDangNhap(BuildContext ctx) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
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
                    Navigator.pop(dialogCtx);
                    Navigator.push(
                      ctx,
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
                onPressed: () => Navigator.pop(dialogCtx),
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
  void dispose() {
    _dieuKhienTen.dispose();
    _dieuKhienSdt.dispose();
    super.dispose();
  }

  Future<void> _moHopThoaiChonNgayNhan(DatPhongProvider provider) async {
    final ngayHienTai = DateTime.now();
    final mocDauHomNay = DateTime(ngayHienTai.year, ngayHienTai.month, ngayHienTai.day);

    final thoiGianMoi = await XuLyNgay.chonNgayVaGio(
      context: context,
      thoiGianHienTai: provider.ngayNhanPhong,
      mocToiThieu: mocDauHomNay,
      tieuDeNgay: 'CHỌN NGÀY NHẬN PHÒNG',
      tieuDeGio: 'CHỌN GIỜ NHẬN PHÒNG',
    );

    if (thoiGianMoi != null) {
      provider.datNgayNhan(thoiGianMoi);
    }
  }

  Future<void> _moHopThoaiChonGioNhan(DatPhongProvider provider) async {
    final thoiGianMoi = await XuLyNgay.chonGio(
      context: context,
      thoiGianHienTai: provider.ngayNhanPhong,
      tieuDeGio: 'CHỌN GIỜ NHẬN PHÒNG',
    );
    if (thoiGianMoi != null) {
      provider.datNgayNhan(thoiGianMoi);
    }
  }

  Future<void> _moHopThoaiChonNgayTra(DatPhongProvider provider) async {
    final mocToiThieu = DateTime(
      provider.ngayNhanPhong.year,
      provider.ngayNhanPhong.month,
      provider.ngayNhanPhong.day,
    );

    final thoiGianMoi = await XuLyNgay.chonNgayVaGio(
      context: context,
      thoiGianHienTai: provider.ngayTraPhong,
      mocToiThieu: mocToiThieu,
      tieuDeNgay: 'CHỌN NGÀY TRẢ PHÒNG',
      tieuDeGio: 'CHỌN GIỜ TRẢ PHÒNG',
    );

    if (thoiGianMoi != null) {
      if (thoiGianMoi.isAfter(provider.ngayNhanPhong)) {
        provider.datNgayTra(thoiGianMoi);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thời gian trả phòng phải sau thời gian nhận phòng!')),
          );
        }
      }
    }
  }

  Future<void> _moHopThoaiChonGioTra(DatPhongProvider provider) async {
    final thoiGianMoi = await XuLyNgay.chonGio(
      context: context,
      thoiGianHienTai: provider.ngayTraPhong,
      tieuDeGio: 'CHỌN GIỜ TRẢ PHÒNG',
    );
    if (thoiGianMoi != null) {
      if (thoiGianMoi.isAfter(provider.ngayNhanPhong)) {
        provider.datNgayTra(thoiGianMoi);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thời gian trả phòng phải sau thời gian nhận phòng!')),
          );
        }
      }
    }
  }

  Future<void> _xuLyXacNhanDatPhong() async {
    if (!_khoaBieuMau.currentState!.validate()) return;

    final datPhongProvider = Provider.of<DatPhongProvider>(context, listen: false);
    final xacThucProvider = Provider.of<XacThucProvider>(context, listen: false);

    setState(() {
      _dangXuLy = true;
      _thongBaoLoi = null;
    });

    try {
      final donMoi = await DatPhongDichVu.taoDonDatPhong(
        ngayNhanPhong: datPhongProvider.ngayNhanPhong,
        ngayTraPhong: datPhongProvider.ngayTraPhong,
        idLoaiPhong: widget.loaiPhong.id,
        soLuongPhong: datPhongProvider.soLuongPhong,
        tenKhachHang: _dieuKhienTen.text.trim(),
        sdtKhachHang: _dieuKhienSdt.text.trim(),
        daDangNhap: xacThucProvider.daDangNhap,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (nguoiCanhMoi) => ManHinhDatThanhCong(datPhong: donMoi),
          ),
        );
      }
    } catch (loi) {
      if (mounted) {
        setState(() {
          _thongBaoLoi = loi.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _dangXuLy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext nguoiCanh) {
    final datPhongProvider = Provider.of<DatPhongProvider>(nguoiCanh);
    final soDem = datPhongProvider.soDem;
    final tongTien = widget.loaiPhong.giaCoBan * soDem * datPhongProvider.soLuongPhong;

    return Scaffold(
      backgroundColor: MauSacApp.mauNen,
      appBar: AppBar(
        title: const Text('Thông Tin Đặt Phòng'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _khoaBieuMau,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thong tin phong tom tat
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MauSacApp.mauBeMat,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: MauSacApp.mauChinh.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.hotel, color: MauSacApp.mauChinh, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.loaiPhong.tenLoai,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: MauSacApp.mauChuChinh,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${DinhDang.dinhDangTien(widget.loaiPhong.giaCoBan)} / dem',
                            style: const TextStyle(
                              fontSize: 14,
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
              const SizedBox(height: 16),
              // Chon thoi gian luu tru
              const Text(
                'Thời Gian Lưu Trú',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: MauSacApp.mauChuChinh,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _moHopThoaiChonNgayNhan(datPhongProvider),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: MauSacApp.mauBeMat,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.calendar_today_rounded, size: 12, color: MauSacApp.mauChuPhu),
                                SizedBox(width: 4),
                                Text(
                                  'Nhận phòng',
                                  style: TextStyle(fontSize: 11, color: MauSacApp.mauChuPhu, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DinhDang.dinhDangNgay(datPhongProvider.ngayNhanPhong),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 3),
                            GestureDetector(
                              onTap: () => _moHopThoaiChonGioNhan(datPhongProvider),
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => _moHopThoaiChonNgayTra(datPhongProvider),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: MauSacApp.mauBeMat,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.event_available_rounded, size: 12, color: MauSacApp.mauChuPhu),
                                SizedBox(width: 4),
                                Text(
                                  'Trả phòng',
                                  style: TextStyle(fontSize: 11, color: MauSacApp.mauChuPhu, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DinhDang.dinhDangNgay(datPhongProvider.ngayTraPhong),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 3),
                            GestureDetector(
                              onTap: () => _moHopThoaiChonGioTra(datPhongProvider),
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
              // So luong phong
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: MauSacApp.mauBeMat,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Số lượng phòng cần đặt:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            if (datPhongProvider.soLuongPhong > 1) {
                              datPhongProvider.datSoLuongPhong(datPhongProvider.soLuongPhong - 1);
                            }
                          },
                        ),
                        Text(
                          '${datPhongProvider.soLuongPhong}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            datPhongProvider.datSoLuongPhong(datPhongProvider.soLuongPhong + 1);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Thong tin khach hang
              const Text(
                'Thông Tin Khách Hàng',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: MauSacApp.mauChuChinh,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _dieuKhienTen,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên khách hàng',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (giaTri) {
                  if (giaTri == null || giaTri.trim().isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dieuKhienSdt,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại liên hệ',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (giaTri) {
                  if (giaTri == null || giaTri.trim().isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  if (giaTri.trim().length < 8) {
                    return 'Số điện thoại không hợp lệ';
                  }
                  return null;
                },
              ),
              if (_thongBaoLoi != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MauSacApp.mauLoi.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: MauSacApp.mauLoi.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: MauSacApp.mauLoi, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _thongBaoLoi!,
                          style: const TextStyle(color: MauSacApp.mauLoi, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              // Chi tiet gia
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MauSacApp.mauBeMat,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đơn giá (${datPhongProvider.soLuongPhong} phòng x $soDem đêm):',
                          style: const TextStyle(fontSize: 13, color: MauSacApp.mauChuPhu),
                        ),
                        Text(
                          DinhDang.dinhDangTien(tongTien),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng cộng:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: MauSacApp.mauChuChinh,
                          ),
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
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Nut xac nhan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _dangXuLy ? null : _xuLyXacNhanDatPhong,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MauSacApp.mauChinh,
                  ),
                  child: _dangXuLy
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Xác Nhận Đặt Phòng',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
