import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../cau_hinh/mau_sac_app.dart';
import '../../quan_ly_trang_thai/xac_thuc_provider.dart';
import 'man_hinh_dang_nhap.dart';

class ManHinhDangKy extends StatefulWidget {
  const ManHinhDangKy({super.key});

  @override
  State<ManHinhDangKy> createState() => _ManHinhDangKyTrangThai();
}

class _ManHinhDangKyTrangThai extends State<ManHinhDangKy> {
  final _khoaBieuMau = GlobalKey<FormState>();
  final _dieuKhienHoTen = TextEditingController();
  final _dieuKhienEmail = TextEditingController();
  final _dieuKhienMatKhau = TextEditingController();
  final _dieuKhienSoDienThoai = TextEditingController();
  bool _anMatKhau = true;

  @override
  void dispose() {
    _dieuKhienHoTen.dispose();
    _dieuKhienEmail.dispose();
    _dieuKhienMatKhau.dispose();
    _dieuKhienSoDienThoai.dispose();
    super.dispose();
  }

  Future<void> _xuLyDangKy() async {
    if (!_khoaBieuMau.currentState!.validate()) return;

    final xacThucProvider = Provider.of<XacThucProvider>(context, listen: false);
    final thanhCong = await xacThucProvider.dangKy(
      hoTen: _dieuKhienHoTen.text.trim(),
      email: _dieuKhienEmail.text.trim(),
      matKhau: _dieuKhienMatKhau.text,
      soDienThoai: _dieuKhienSoDienThoai.text.trim(),
    );

    if (thanhCong && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký tài khoản thành công!'),
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
        title: const Text('Đăng Ký Tài Khoản'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _khoaBieuMau,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Tạo Tài Khoản Mới',
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
                  'Gia nhập thành viên để nhận nhiều ưu đãi đặt phòng',
                  style: TextStyle(fontSize: 13, color: MauSacApp.mauChuPhu),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _dieuKhienHoTen,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (giaTri) {
                  if (giaTri == null || giaTri.trim().isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _dieuKhienEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (giaTri) {
                  if (giaTri == null || giaTri.trim().isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!giaTri.contains('@')) {
                    return 'Email không đúng định dạng';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _dieuKhienSoDienThoai,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (giaTri) {
                  if (giaTri == null || giaTri.trim().isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  if (giaTri.trim().length < 8) {
                    return 'Số điện thoại quá ngắn';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _dieuKhienMatKhau,
                obscureText: _anMatKhau,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu (tối thiểu 8 ký tự)',
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
                  if (giaTri.length < 8) {
                    return 'Mật khẩu phải có ít nhất 8 ký tự';
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
                  onPressed: xacThucProvider.dangXuLy ? null : _xuLyDangKy,
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
                          'Đăng Ký Ngay',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đã có tài khoản? ', style: TextStyle(color: MauSacApp.mauChuPhu)),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        nguoiCanh,
                        MaterialPageRoute(builder: (nguoiCanhMoi) => const ManHinhDangNhap()),
                      );
                    },
                    child: const Text(
                      'Đăng nhập',
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
