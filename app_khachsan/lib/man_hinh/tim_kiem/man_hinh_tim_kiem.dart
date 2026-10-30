import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../cau_hinh/mau_sac_app.dart';
import '../../dich_vu/phong_dich_vu.dart';
import '../../mo_hinh/loai_phong.dart';
import '../../quan_ly_trang_thai/dat_phong_provider.dart';
import '../../tien_ich/dinh_dang.dart';
import '../../tien_ich/xu_ly_ngay.dart';
import '../chi_tiet_phong/man_hinh_chi_tiet_phong.dart';
import '../dat_phong/man_hinh_dat_phong.dart';
import '../trang_chu/thanh_phan/the_phong.dart';

class ManHinhTimKiem extends StatefulWidget {
  const ManHinhTimKiem({super.key});

  @override
  State<ManHinhTimKiem> createState() => _ManHinhTimKiemTrangThai();
}

class _ManHinhTimKiemTrangThai extends State<ManHinhTimKiem> {
  List<LoaiPhong> _danhSachPhongTrong = [];
  bool _dangTai = false;
  String? _thongBaoLoi;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timKiemPhong();
    });
  }

  Future<void> _timKiemPhong() async {
    final datPhongProvider = Provider.of<DatPhongProvider>(context, listen: false);
    datPhongProvider.dongBoNgayNeuQuaHan(thongBao: true);

    setState(() {
      _dangTai = true;
      _thongBaoLoi = null;
    });

    try {
      final ketQua = await PhongDichVu.timKiemPhongTrong(
        ngayNhanPhong: datPhongProvider.ngayNhanPhong,
        ngayTraPhong: datPhongProvider.ngayTraPhong,
        soNguoi: datPhongProvider.soKhach,
      );
      setState(() {
        _danhSachPhongTrong = ketQua;
      });
    } catch (loi) {
      String thongBao = loi.toString().replaceAll('Exception: ', '');
      if (thongBao.toLowerCase().contains('after or equal to today') ||
          thongBao.toLowerCase().contains('ngay nhan phong')) {
        datPhongProvider.datLai();
        thongBao = 'Ngày nhận phòng trước đó đã qua. Hệ thống đã tự động cập nhật về hôm nay (${DinhDang.dinhDangNgay(datPhongProvider.ngayNhanPhong)}). Quý khách vui lòng bấm "Thử Lại" để tìm kiếm!';
      }
      setState(() {
        _thongBaoLoi = thongBao;
      });
    } finally {
      setState(() {
        _dangTai = false;
      });
    }
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
      _timKiemPhong();
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
      _timKiemPhong();
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
        _timKiemPhong();
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
        _timKiemPhong();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thời gian trả phòng phải sau thời gian nhận phòng!')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext nguoiCanh) {
    final datPhongProvider = Provider.of<DatPhongProvider>(nguoiCanh);

    return Scaffold(
      backgroundColor: MauSacApp.mauNen,
      appBar: AppBar(
        title: const Text('Tìm Phòng Trống'),
      ),
      body: Column(
        children: [
          // Thanh bo loc ngay & so khach
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: MauSacApp.mauBeMat,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Hop nhan phong
                    Expanded(
                      child: InkWell(
                        onTap: () => _moHopThoaiChonNgayNhan(datPhongProvider),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: MauSacApp.mauBeMatPhu,
                            borderRadius: BorderRadius.circular(10),
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
                              const SizedBox(height: 3),
                              Text(
                                DinhDang.dinhDangNgay(datPhongProvider.ngayNhanPhong),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              GestureDetector(
                                onTap: () => _moHopThoaiChonGioNhan(datPhongProvider),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 10, color: MauSacApp.mauChinh),
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
                    const Icon(Icons.arrow_forward, size: 16, color: MauSacApp.mauChuMo),
                    const SizedBox(width: 8),
                    // Hop tra phong
                    Expanded(
                      child: InkWell(
                        onTap: () => _moHopThoaiChonNgayTra(datPhongProvider),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: MauSacApp.mauBeMatPhu,
                            borderRadius: BorderRadius.circular(10),
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
                              const SizedBox(height: 3),
                              Text(
                                DinhDang.dinhDangNgay(datPhongProvider.ngayTraPhong),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              GestureDetector(
                                onTap: () => _moHopThoaiChonGioTra(datPhongProvider),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 10, color: MauSacApp.mauDiemNhan),
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: MauSacApp.mauBeMatPhu,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.people_alt_rounded, size: 16, color: MauSacApp.mauChinh),
                                SizedBox(width: 8),
                                Text(
                                  'Số người:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: MauSacApp.mauChuChinh,
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
                                      _timKiemPhong();
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: const Icon(Icons.remove, size: 14),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    '${datPhongProvider.soKhach} Người',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    datPhongProvider.datSoKhach(datPhongProvider.soKhach + 1);
                                    _timKiemPhong();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: const Icon(Icons.add, size: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: MauSacApp.mauChinh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                        onPressed: _timKiemPhong,
                        tooltip: 'Tìm lại',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Danh sach ket qua
          Expanded(
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
                                onPressed: () {
                                  final provider = Provider.of<DatPhongProvider>(context, listen: false);
                                  provider.dongBoNgayNeuQuaHan(thongBao: true);
                                  _timKiemPhong();
                                },
                                child: const Text('Thử Lại'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _danhSachPhongTrong.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.hotel_class_outlined,
                                    size: 64,
                                    color: MauSacApp.mauChuMo,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Không Có Phòng Phù Hợp',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: MauSacApp.mauChuChinh,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Trong khoảng thời gian và số lượng người đã chọn, không có phòng trống phù hợp. Vui lòng thử chọn mốc thời gian khác hoặc giảm số người.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: MauSacApp.mauChuPhu,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            itemCount: _danhSachPhongTrong.length,
                            itemBuilder: (nguoiCanhMoi, viTri) {
                              final loaiPhong = _danhSachPhongTrong[viTri];
                              return ThePhong(
                                loaiPhong: loaiPhong,
                                khiBamXemChiTiet: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (nguoiCanhXem) =>
                                          ManHinhChiTietPhong(loaiPhong: loaiPhong),
                                    ),
                                  );
                                },
                                khiBamDatPhong: () {
                                  datPhongProvider.chonLoaiPhong(loaiPhong);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (nguoiCanhDat) =>
                                          ManHinhDatPhong(loaiPhong: loaiPhong),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
