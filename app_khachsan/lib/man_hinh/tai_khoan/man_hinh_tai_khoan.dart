import '../../dich_vu/bao_mat_dich_vu.dart';
import '../xac_thuc/man_hinh_khoa_pin.dart';
import '../dich_vu/man_hinh_dich_vu.dart';
import '../dieu_huong_chinh.dart';
import '../../dich_vu/phong_dich_vu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../cau_hinh/mau_sac_app.dart';
import '../../quan_ly_trang_thai/xac_thuc_provider.dart';

import '../xac_thuc/man_hinh_dang_nhap.dart';
import 'man_hinh_lich_su_don.dart';

class ManHinhTaiKhoan extends StatelessWidget {
  final Function(int)? onChuyenTab;
  const ManHinhTaiKhoan({super.key, this.onChuyenTab});

  @override
  Widget build(BuildContext nguoiCanh) {
    final xacThucProvider = Provider.of<XacThucProvider>(nguoiCanh);
    final nguoiDung = xacThucProvider.nguoiDung;

    return Scaffold(
      backgroundColor: MauSacApp.mauNen,
      appBar: AppBar(
        title: const Text('Tài Khoản & Cài Đặt'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Thong tin ca nhan hoac the dang nhap
          if (xacThucProvider.daDangNhap && nguoiDung != null)
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: MauSacApp.mauChinh,
                    child: Text(
                      nguoiDung.hoTen.isNotEmpty ? nguoiDung.hoTen[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nguoiDung.hoTen,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: MauSacApp.mauChuChinh,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nguoiDung.email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: MauSacApp.mauChuPhu,
                          ),
                        ),
                        if (nguoiDung.soDienThoai != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            nguoiDung.soDienThoai!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: MauSacApp.mauChuMo,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: MauSacApp.mauBeMat,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.account_circle_outlined, size: 56, color: MauSacApp.mauChuMo),
                  const SizedBox(height: 10),
                  const Text(
                    'Chưa Đăng Nhập',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: MauSacApp.mauChuChinh,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Đăng nhập để tích điểm và dễ dàng quản lý các đơn đặt phòng',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: MauSacApp.mauChuPhu),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          nguoiCanh,
                          MaterialPageRoute(builder: (nguoiCanhMoi) => const ManHinhDangNhap()),
                        );
                      },
                      child: const Text('Đăng Nhập / Đăng Ký'),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Menu chuc nang
          _mucMenu(
            icon: Icons.receipt_long_rounded,
            tieuDe: 'Lịch Sử Đặt Phòng',
            moTa: 'Xem tất cả đơn đặt phòng của bạn',
            khiNhan: () {
              Navigator.push(
                nguoiCanh,
                MaterialPageRoute(builder: (nguoiCanhMoi) => const ManHinhLichSuDon()),
              );
            },
          ),
          _mucMenu(
            icon: Icons.auto_awesome,
            tieuDe: 'Trợ Lý AI Tư Vấn',
            moTa: 'Tư vấn tìm phòng nghỉ thông minh',
            khiNhan: () {
              if (onChuyenTab != null) {
                onChuyenTab!(2);
              } else {
                DieuHuongChinh.chuyenTab(nguoiCanh, 2);
              }
            },
          ),
          _mucMenu(
            icon: Icons.room_service_rounded,
            tieuDe: 'Dịch Vụ Tận Phòng',
            moTa: 'Gọi đồ ăn, đồ uống, spa thư giãn tới phòng',
            khiNhan: () {
              Navigator.push(
                nguoiCanh,
                MaterialPageRoute(builder: (nguoiCanhMoi) => const ManHinhDichVu()),
              );
            },
          ),
          _mucMenu(
            icon: Icons.pin_outlined,
            tieuDe: 'Bảo Mật Mã PIN',
            moTa: 'Khóa ứng dụng bằng mã PIN 4 số',
            khiNhan: () async {
              final daBat = await BaoMatDichVu.daBatKhoaPin();
              if (!nguoiCanh.mounted) return;

              showModalBottomSheet(
                context: nguoiCanh,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (ctx) => SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Row(
                          children: [
                            Icon(Icons.security_rounded, color: MauSacApp.mauChinh, size: 24),
                            SizedBox(width: 10),
                            Text(
                              'Khóa Ứng Dụng (Mã PIN)',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          daBat
                              ? 'Ứng dụng đang được bảo vệ bằng mã PIN 4 số. Bạn có thể đổi mã hoặc tắt bảo mật.'
                              : 'Kích hoạt mã PIN 4 số để bảo vệ thông tin đặt phòng khi mở ứng dụng.',
                          style: const TextStyle(fontSize: 13, color: MauSacApp.mauChuPhu),
                        ),
                        const SizedBox(height: 20),
                        if (!daBat) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add_moderator_rounded, size: 20),
                              label: const Text('Thiết Lập Mã PIN Mới'),
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.push(
                                  nguoiCanh,
                                  MaterialPageRoute(
                                    builder: (_) => const ManHinhKhoaPin(cheDo: CheDoPin.taoPinMoi),
                                  ),
                                );
                              },
                            ),
                          ),
                        ] else ...[
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.password_rounded, size: 20),
                              label: const Text('Đổi Mã PIN'),
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.push(
                                  nguoiCanh,
                                  MaterialPageRoute(
                                    builder: (_) => const ManHinhKhoaPin(cheDo: CheDoPin.taoPinMoi),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: MauSacApp.mauLoi),
                                foregroundColor: MauSacApp.mauLoi,
                              ),
                              icon: const Icon(Icons.lock_open_rounded, size: 20),
                              label: const Text('Tắt Khóa Mã PIN'),
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.push(
                                  nguoiCanh,
                                  MaterialPageRoute(
                                    builder: (_) => const ManHinhKhoaPin(cheDo: CheDoPin.tatPin),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          _mucMenu(
            icon: Icons.hotel_rounded,
            tieuDe: 'Về Khách Sạn',
            moTa: 'Thông tin liên hệ & Đặt phòng',
            khiNhan: () async {
              showDialog(
                context: nguoiCanh,
                builder: (nguoiCanhMoi) => FutureBuilder<Map<String, dynamic>>(
                  future: PhongDichVu.layThongTinKhachSan(),
                  builder: (nguoiCanhHopThoai, snapshot) {
                    final data = snapshot.data ?? {};
                    final diaChi = data['address'] ?? data['dia_chi'] ?? 'Đang tải...';
                    final hotline = data['hotline'] ?? data['so_dien_thoai'] ?? 'Đang tải...';
                    final email = data['email'] ?? 'Đang tải...';
                    final nganHang = data['bank_name'] != null ? '${data['bank_name']} - ${data['bank_account']}' : null;

                    return AlertDialog(
                      title: const Row(
                        children: [
                          Icon(Icons.hotel_rounded, color: MauSacApp.mauChinh),
                          SizedBox(width: 8),
                          Text('Thông Tin Khách Sạn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Khách Sạn Grand Luxury', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: MauSacApp.mauChinh)),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_outlined, size: 18, color: MauSacApp.mauDiemNhan),
                              const SizedBox(width: 8),
                              Expanded(child: Text('Địa chỉ: $diaChi', style: const TextStyle(fontSize: 13))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 18, color: MauSacApp.mauThanhCong),
                              const SizedBox(width: 8),
                              Expanded(child: Text('Hotline: $hotline', style: const TextStyle(fontSize: 13))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.email_outlined, size: 18, color: MauSacApp.mauChinhNhat),
                              const SizedBox(width: 8),
                              Expanded(child: Text('Email: $email', style: const TextStyle(fontSize: 13))),
                            ],
                          ),
                          if (nganHang != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.account_balance_outlined, size: 18, color: MauSacApp.mauDiemNhan),
                                const SizedBox(width: 8),
                                Expanded(child: Text('Ngân hàng: $nganHang', style: const TextStyle(fontSize: 13))),
                              ],
                            ),
                          ],
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(nguoiCanhMoi),
                          child: const Text('Đóng'),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),

          if (xacThucProvider.daDangNhap) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: MauSacApp.mauLoi),
                  foregroundColor: MauSacApp.mauLoi,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                onPressed: () async {
                  final dongY = await showDialog<bool>(
                    context: nguoiCanh,
                    builder: (nguoiCanhHoi) => AlertDialog(
                      title: const Text('Xác Nhận Đăng Xuất'),
                      content: const Text('Bạn có chắc chắn muốn đăng xuất tài khoản không?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(nguoiCanhHoi, false),
                          child: const Text('Hủy'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MauSacApp.mauLoi,
                          ),
                          onPressed: () => Navigator.pop(nguoiCanhHoi, true),
                          child: const Text('Đăng Xuất'),
                        ),
                      ],
                    ),
                  );

                  if (dongY == true) {
                    await xacThucProvider.dangXuat();
                  }
                },
                child: const Text('Đăng Xuất Tài Khoản'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _mucMenu({
    required IconData icon,
    required String tieuDe,
    required String moTa,
    required VoidCallback khiNhan,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: MauSacApp.mauBeMat,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
        onTap: khiNhan,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: MauSacApp.mauChinh.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: MauSacApp.mauChinh, size: 22),
        ),
        title: Text(
          tieuDe,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: MauSacApp.mauChuChinh,
          ),
        ),
        subtitle: Text(
          moTa,
          style: const TextStyle(fontSize: 12, color: MauSacApp.mauChuPhu),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: MauSacApp.mauChuMo),
        ),
      ),
    );
  }
}
