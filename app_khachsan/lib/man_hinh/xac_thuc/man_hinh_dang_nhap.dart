import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../cau_hinh/mau_sac_app.dart';
import '../../quan_ly_trang_thai/xac_thuc_provider.dart';
import 'man_hinh_dang_ky.dart';

class ManHinhDangNhap extends StatefulWidget {
  const ManHinhDangNhap({super.key});

  @override
  State<ManHinhDangNhap> createState() => _ManHinhDangNhapTrangThai();
}

class _ManHinhDangNhapTrangThai extends State<ManHinhDangNhap> {
  final _khoaBieuMau = GlobalKey<FormState>();
  final _dieuKhienEmail = TextEditingController();
  final _dieuKhienMatKhau = TextEditingController();
  bool _anMatKhau = true;

  @override
  void dispose() {
    _dieuKhienEmail.dispose();
    _dieuKhienMatKhau.dispose();
    super.dispose();
  }

  Future<void> _xuLyDangNhap() async {
    if (!_khoaBieuMau.currentState!.validate()) return;

    final xacThucProvider = Provider.of<XacThucProvider>(context, listen: false);
    final thanhCong = await xacThucProvider.dangNhap(
      email: _dieuKhienEmail.text.trim(),
      matKhau: _dieuKhienMatKhau.text,
    );

    if (thanhCong && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng nhập thành công!'),
          backgroundColor: MauSacApp.mauThanhCong,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext nguoiCanh) {
    final xacThucProvider = Provider.of<XacThucProvider>(nguoiCanh);

    return Scaffold(
      backgroundColor: MauSacApp.mauNen,
      appBar: AppBar(
        title: const Text('Đăng Nhập'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _khoaBieuMau,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MauSacApp.mauChinh.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline_rounded, size: 48, color: MauSacApp.mauChinh),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Chào Mừng Trở Lại',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: MauSacApp.mauChuChinh,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Đăng nhập để quản lý đơn đặt phòng và ưu đãi',
                  style: TextStyle(fontSize: 13, color: MauSacApp.mauChuPhu),
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _dieuKhienEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email đăng ký',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (giaTri) {
                  if (giaTri == null || giaTri.trim().isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!giaTri.contains('@')) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dieuKhienMatKhau,
                obscureText: _anMatKhau,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_anMatKhau ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _anMatKhau = !_anMatKhau;
                      });
                    },
                  ),
                ),
                validator: (giaTri) {
                  if (giaTri == null || giaTri.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
              ),
              if (xacThucProvider.thongBaoLoi != null) ...[
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
                          xacThucProvider.thongBaoLoi!,
                          style: const TextStyle(color: MauSacApp.mauLoi, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: xacThucProvider.dangXuLy ? null : _xuLyDangNhap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MauSacApp.mauChinh,
                  ),
                  child: xacThucProvider.dangXuLy
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Đăng Nhập',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Chưa có tài khoản? ', style: TextStyle(color: MauSacApp.mauChuPhu)),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        nguoiCanh,
                        MaterialPageRoute(builder: (nguoiCanhMoi) => const ManHinhDangKy()),
                      );
                    },
                    child: const Text(
                      'Đăng ký ngay',
                      style: TextStyle(
                        color: MauSacApp.mauChinh,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
