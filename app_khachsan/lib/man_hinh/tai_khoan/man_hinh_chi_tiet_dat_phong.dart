import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../cau_hinh/cau_hinh_api.dart';
import '../../cau_hinh/mau_sac_app.dart';
import '../../dich_vu/dat_phong_dich_vu.dart';
import '../../mo_hinh/dat_phong.dart';
import '../../tien_ich/dinh_dang.dart';
import '../dich_vu/man_hinh_dich_vu.dart';

class ManHinhChiTietDatPhong extends StatefulWidget {
  final int idDon;
  final DatPhong? donBanDau;

  const ManHinhChiTietDatPhong({
    super.key,
    required this.idDon,
    this.donBanDau,
  });

  @override
  State<ManHinhChiTietDatPhong> createState() => _ManHinhChiTietDatPhongTrangThai();
}

class _ManHinhChiTietDatPhongTrangThai extends State<ManHinhChiTietDatPhong> {
  Map<String, dynamic>? _duLieu;
  bool _dangTai = true;
  String? _thongBaoLoi;

  @override
  void initState() {
    super.initState();
    _taiChiTiet();
  }

  Future<void> _taiChiTiet() async {
    setState(() {
      _dangTai = true;
      _thongBaoLoi = null;
    });

    try {
      final res = await DatPhongDichVu.layChiTietDatPhong(widget.idDon);
      setState(() {
        _duLieu = res;
      });
    } catch (e) {
      setState(() {
        _thongBaoLoi = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _dangTai = false;
      });
    }
  }

  String _layTenTrangThai(String? trangThai) {
    switch (trangThai) {
      case 'Moi_Dat':
        return 'Chờ xác nhận';
      case 'Da_Xac_Nhan':
        return 'Đã xác nhận';
      case 'Da_Nhan_Phong':
        return 'Đang lưu trú';
      case 'Da_Thanh_Toan':
        return 'Hoàn thành';
      case 'Da_Huy':
        return 'Đã hủy';
      default:
        return trangThai ?? 'Không rõ';
    }
  }

  Color _layMauTrangThai(String? trangThai) {
    switch (trangThai) {
      case 'Moi_Dat':
        return MauSacApp.mauCanhBao;
      case 'Da_Xac_Nhan':
        return MauSacApp.mauChinh;
      case 'Da_Nhan_Phong':
        return MauSacApp.mauThanhCong;
      case 'Da_Thanh_Toan':
        return Colors.blue.shade700;
      case 'Da_Huy':
        return MauSacApp.mauLoi;
      default:
        return MauSacApp.mauChuPhu;
    }
  }

  String _layTenTrangThaiDichVu(String? tt) {
    switch (tt) {
      case 'Cho_Phuc_Vu':
        return 'Chờ phục vụ';
      case 'Dang_Phuc_Vu':
        return 'Đang chuẩn bị';
      case 'Hoan_Thanh':
        return 'Đã phục vụ';
      case 'Da_Huy':
        return 'Đã hủy';
      default:
        return tt ?? 'Đang xử lý';
    }
  }

  Color _layMauTrangThaiDichVu(String? tt) {
    switch (tt) {
      case 'Cho_Phuc_Vu':
        return Colors.orange.shade700;
      case 'Dang_Phuc_Vu':
        return Colors.blue.shade700;
      case 'Hoan_Thanh':
        return MauSacApp.mauThanhCong;
      case 'Da_Huy':
        return MauSacApp.mauLoi;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MauSacApp.mauNen,
      appBar: AppBar(
        title: Text(
          'Đơn Đặt Phòng #${widget.idDon}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
            onPressed: _taiChiTiet,
          ),
        ],
      ),
      body: _dangTai && _duLieu == null
          ? const Center(child: CircularProgressIndicator(color: MauSacApp.mauChinh))
          : _thongBaoLoi != null && _duLieu == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: MauSacApp.mauLoi),
                        const SizedBox(height: 12),
                        Text(_thongBaoLoi!, textAlign: TextAlign.center, style: const TextStyle(color: MauSacApp.mauLoi)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _taiChiTiet, child: const Text('Thử Lại')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _taiChiTiet,
                  color: MauSacApp.mauChinh,
                  child: _noiDungChiTiet(),
                ),
    );
  }

  Widget _noiDungChiTiet() {
    final don = _duLieu?['don'] as Map<String, dynamic>?;
    final dichVuList = (_duLieu?['dich_vu_da_goi'] as List<dynamic>?) ?? [];
    final chiPhi = _duLieu?['tong_ket_chi_phi'] as Map<String, dynamic>?;

    final trangThai = don?['trang_thai']?.toString() ?? widget.donBanDau?.trangThai ?? 'Moi_Dat';
    final tenTrangThai = _layTenTrangThai(trangThai);
    final mauTrangThai = _layMauTrangThai(trangThai);

    final tenLoaiPhong = don?['ten_loai_phong_khi_dat'] ?? don?['ten_loai'] ?? widget.donBanDau?.tenLoaiPhong ?? 'Phòng Khách Sạn';
    final soLuongPhong = don?['so_luong_phong'] ?? widget.donBanDau?.soLuongPhong ?? 1;
    final hinhAnh = don?['hinh_anh']?.toString();

    final danhSachSoPhong = (don?['danh_sach_so_phong'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        widget.donBanDau?.danhSachSoPhong ??
        [];

    final ngayNhanStr = don?['ngay_nhan_phong'];
    final ngayTraStr = don?['ngay_tra_phong'];
    DateTime? ngayNhan;
    DateTime? ngayTra;
    try {
      if (ngayNhanStr != null) ngayNhan = DateTime.parse(ngayNhanStr.toString()).toLocal();
      if (ngayTraStr != null) ngayTra = DateTime.parse(ngayTraStr.toString()).toLocal();
    } catch (_) {}

    final tienPhong = (chiPhi?['tien_phong'] as num?)?.toDouble() ??
        (don?['tong_tien'] is num ? (don?['tong_tien'] as num).toDouble() : 0.0);
    final tienDichVu = (chiPhi?['tong_tien_dich_vu'] as num?)?.toDouble() ?? 0.0;
    final tongUocTinh = (chiPhi?['tong_uoc_tinh'] as num?)?.toDouble() ?? (tienPhong + tienDichVu);
    final daThanhToan = (chiPhi?['da_thanh_toan'] as num?)?.toDouble() ?? 0.0;
    final conLai = (chiPhi?['con_lai_phai_tra'] as num?)?.toDouble() ?? tongUocTinh;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
      children: [
        // 1. Banner Trạng Thái Đơn
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mauTrangThai.withValues(alpha: 0.15), mauTrangThai.withValues(alpha: 0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: mauTrangThai.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: mauTrangThai.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  trangThai == 'Da_Nhan_Phong'
                      ? Icons.key_rounded
                      : trangThai == 'Da_Xac_Nhan'
                          ? Icons.verified_rounded
                          : trangThai == 'Da_Thanh_Toan'
                              ? Icons.task_alt_rounded
                              : Icons.info_outline_rounded,
                  color: mauTrangThai,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trạng Thái: $tenTrangThai',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: mauTrangThai,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trangThai == 'Da_Nhan_Phong'
                          ? 'Bạn đang trong thời gian lưu trú tại khách sạn'
                          : trangThai == 'Da_Xac_Nhan'
                              ? 'Đơn đã xác nhận, sẵn sàng đón bạn đến check-in'
                              : trangThai == 'Da_Thanh_Toan'
                                  ? 'Đã hoàn tất thanh toán và trả phòng'
                                  : 'Đơn đang chờ khách sạn duyệt',
                      style: const TextStyle(fontSize: 12, color: MauSacApp.mauChuPhu),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Thẻ Thông Tin Phòng & Lưu Trú
        _theThongTinPhong(
          tenLoaiPhong: tenLoaiPhong,
          soLuongPhong: soLuongPhong,
          hinhAnh: hinhAnh,
          danhSachSoPhong: danhSachSoPhong,
          ngayNhan: ngayNhan,
          ngayTra: ngayTra,
          tienPhong: tienPhong,
          tenKhach: don?['ten_khach_hang']?.toString() ?? '',
          sdtKhach: don?['sdt_khach_hang']?.toString() ?? '',
        ),
        const SizedBox(height: 16),

        // 3. Thẻ Dịch Vụ Đã Gọi
        _theDichVuDaGoi(
          dichVuList: dichVuList,
          dangLuuTru: trangThai == 'Da_Nhan_Phong',
          danhSachSoPhong: danhSachSoPhong,
        ),
        const SizedBox(height: 16),

        // 4. Bảng Tổng Kết Chi Phí (Ước Tính Phải Trả)
        _theTongKetChiPhi(
          tienPhong: tienPhong,
          tienDichVu: tienDichVu,
          tongUocTinh: tongUocTinh,
          daThanhToan: daThanhToan,
          conLai: conLai,
          trangThai: trangThai,
        ),
      ],
    );
  }

  /// Card thông tin phòng và thời gian lưu trú
  Widget _theThongTinPhong({
    required String tenLoaiPhong,
    required int soLuongPhong,
    required String? hinhAnh,
    required List<String> danhSachSoPhong,
    required DateTime? ngayNhan,
    required DateTime? ngayTra,
    required double tienPhong,
    required String tenKhach,
    required String sdtKhach,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: MauSacApp.mauBeMat,
        borderRadius: BorderRadius.circular(20),
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
          // Tiêu đề card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                const Icon(Icons.hotel_rounded, color: MauSacApp.mauChinh, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Thông Tin Phòng & Đặt Chỗ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: MauSacApp.mauChuChinh,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Nội dung phòng
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ảnh phòng nhỏ nếu có
                    if (hinhAnh != null && hinhAnh.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: CauHinhApi.layDuongDanAnh(hinhAnh),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.bed_rounded, color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: MauSacApp.mauChinh.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.meeting_room_rounded, color: MauSacApp.mauChinh, size: 36),
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tenLoaiPhong,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: MauSacApp.mauChuChinh,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Số lượng đặt: $soLuongPhong phòng',
                            style: const TextStyle(fontSize: 13, color: MauSacApp.mauChuPhu),
                          ),
                          const SizedBox(height: 8),

                          // SỐ PHÒNG ĐƯỢC GÁN
                          if (danhSachSoPhong.isNotEmpty)
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: danhSachSoPhong.map((sp) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: MauSacApp.mauThanhCong.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: MauSacApp.mauThanhCong.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.door_front_door_rounded, size: 14, color: MauSacApp.mauThanhCong),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Phòng $sp',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: MauSacApp.mauThanhCong,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Chưa gán số phòng (sẽ cấp khi nhận phòng)',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.amber),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Chi tiết thời gian & khách
                _dongThongTin(
                  icon: Icons.calendar_today_rounded,
                  tieuDe: 'Thời gian:',
                  noiDung: ngayNhan != null && ngayTra != null
                      ? '${DinhDang.dinhDangNgay(ngayNhan)} - ${DinhDang.dinhDangNgay(ngayTra)}'
                      : 'Chưa cập nhật',
                ),
                const SizedBox(height: 8),
                _dongThongTin(
                  icon: Icons.person_outline_rounded,
                  tieuDe: 'Khách hàng:',
                  noiDung: '$tenKhach ($sdtKhach)',
                ),
                const SizedBox(height: 8),
                _dongThongTin(
                  icon: Icons.payments_outlined,
                  tieuDe: 'Tiền thuê phòng:',
                  noiDung: DinhDang.dinhDangTien(tienPhong),
                  noiDungMau: MauSacApp.mauChinh,
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card danh sách dịch vụ đã gọi
  Widget _theDichVuDaGoi({
    required List<dynamic> dichVuList,
    required bool dangLuuTru,
    required List<String> danhSachSoPhong,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: MauSacApp.mauBeMat,
        borderRadius: BorderRadius.circular(20),
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
          // Tiêu đề card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.room_service_rounded, color: MauSacApp.mauDiemNhan, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Dịch Vụ Đã Gọi (${dichVuList.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: MauSacApp.mauChuChinh,
                      ),
                    ),
                  ],
                ),
                if (dangLuuTru)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.add_circle_outline, size: 16, color: MauSacApp.mauChinh),
                    label: const Text('Gọi thêm', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ManHinhDichVu()),
                      ).then((_) => _taiChiTiet());
                    },
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Danh sách các dịch vụ
          if (dichVuList.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.room_service_outlined, size: 40, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    const Text(
                      'Chưa gọi dịch vụ nào cho đơn này',
                      style: TextStyle(fontSize: 13, color: MauSacApp.mauChuPhu),
                    ),
                    if (dangLuuTru) ...[
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                        label: const Text('Gọi Dịch Vụ Ngay', style: TextStyle(fontSize: 13)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ManHinhDichVu()),
                          ).then((_) => _taiChiTiet());
                        },
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(14),
              itemCount: dichVuList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final item = dichVuList[idx] as Map<String, dynamic>;
                final tenDv = item['ten_dich_vu']?.toString() ?? 'Dịch vụ';
                final soLuong = item['so_luong'] ?? 1;
                final donGia = (item['don_gia'] as num?)?.toDouble() ?? 0.0;
                final tongTien = (item['tong_tien'] as num?)?.toDouble() ?? (donGia * soLuong);
                final soPhongGiao = item['so_phong']?.toString();
                final ttDv = item['trang_thai']?.toString();
                final mauTt = _layMauTrangThaiDichVu(ttDv);
                final tenTt = _layTenTrangThaiDichVu(ttDv);

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MauSacApp.mauNen,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: MauSacApp.mauDiemNhan.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.restaurant_rounded, color: MauSacApp.mauDiemNhan, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    tenDv,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: MauSacApp.mauChuChinh,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: mauTt.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tenTt,
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: mauTt),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$soLuong suất x ${DinhDang.dinhDangTien(donGia)}',
                              style: const TextStyle(fontSize: 12, color: MauSacApp.mauChuPhu),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (soPhongGiao != null && soPhongGiao.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: MauSacApp.mauThanhCong.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Tới phòng: $soPhongGiao',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: MauSacApp.mauThanhCong,
                                      ),
                                    ),
                                  )
                                else
                                  const SizedBox.shrink(),
                                Text(
                                  DinhDang.dinhDangTien(tongTien),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: MauSacApp.mauDiemNhan,
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
              },
            ),
        ],
      ),
    );
  }

  /// Card tổng kết hóa đơn và số tiền ước tính phải trả
  Widget _theTongKetChiPhi({
    required double tienPhong,
    required double tienDichVu,
    required double tongUocTinh,
    required double daThanhToan,
    required double conLai,
    required String trangThai,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MauSacApp.mauBeMat,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: MauSacApp.mauChinh.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: MauSacApp.mauChinh.withValues(alpha: 0.05),
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
              const Icon(Icons.receipt_long_rounded, color: MauSacApp.mauChinh, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Tổng Kết Chi Phí Ước Tính',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: MauSacApp.mauChuChinh,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Từng mục tiền
          _dongChiPhi(
            nhan: 'Tiền thuê phòng:',
            giaTri: DinhDang.dinhDangTien(tienPhong),
          ),
          const SizedBox(height: 8),
          _dongChiPhi(
            nhan: 'Tiền dịch vụ gọi thêm:',
            giaTri: DinhDang.dinhDangTien(tienDichVu),
            mauGiaTri: tienDichVu > 0 ? MauSacApp.mauDiemNhan : MauSacApp.mauChuPhu,
          ),
          if (daThanhToan > 0) ...[
            const SizedBox(height: 8),
            _dongChiPhi(
              nhan: 'Đã thanh toán trước:',
              giaTri: '- ${DinhDang.dinhDangTien(daThanhToan)}',
              mauGiaTri: MauSacApp.mauThanhCong,
            ),
          ],
          const SizedBox(height: 12),
          const Divider(thickness: 1.2),
          const SizedBox(height: 12),

          // TỔNG CỘNG ƯỚC TÍNH
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TỔNG TIỀN PHẢI TRẢ:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: MauSacApp.mauChuChinh,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    trangThai == 'Da_Thanh_Toan' ? 'Đã hoàn tất thanh toán' : 'Ước tính khi trả phòng',
                    style: TextStyle(
                      fontSize: 11,
                      color: trangThai == 'Da_Thanh_Toan' ? MauSacApp.mauThanhCong : MauSacApp.mauChuPhu,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                DinhDang.dinhDangTien(conLai),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: MauSacApp.mauDiemNhan,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MauSacApp.mauNen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: MauSacApp.mauChuPhu),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trangThai == 'Da_Thanh_Toan'
                        ? 'Đơn đặt phòng này đã được quyết toán và thanh toán hoàn tất.'
                        : 'Tổng tiền ước tính bao gồm tiền phòng và toàn bộ dịch vụ bạn gọi trong suốt kỳ nghỉ. Bạn sẽ thanh toán khoản này khi làm thủ tục trả phòng tại lễ tân.',
                    style: const TextStyle(fontSize: 11, color: MauSacApp.mauChuPhu, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dongThongTin({
    required IconData icon,
    required String tieuDe,
    required String noiDung,
    Color? noiDungMau,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: MauSacApp.mauChuPhu),
        const SizedBox(width: 6),
        Text(tieuDe, style: const TextStyle(fontSize: 13, color: MauSacApp.mauChuPhu)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            noiDung,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: noiDungMau ?? MauSacApp.mauChuChinh,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dongChiPhi({
    required String nhan,
    required String giaTri,
    Color? mauGiaTri,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(nhan, style: const TextStyle(fontSize: 14, color: MauSacApp.mauChuPhu)),
        Text(
          giaTri,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: mauGiaTri ?? MauSacApp.mauChuChinh,
          ),
        ),
      ],
    );
  }
}
