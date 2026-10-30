import 'package:flutter/material.dart';
import '../../cau_hinh/mau_sac_app.dart';
import '../../dich_vu/bao_mat_dich_vu.dart';

enum CheDoPin { moKhoaApp, taoPinMoi, tatPin }

class ManHinhKhoaPin extends StatefulWidget {
  final CheDoPin cheDo;
  final VoidCallback? onMoKhoaThanhCong;

  const ManHinhKhoaPin({
    super.key,
    required this.cheDo,
    this.onMoKhoaThanhCong,
  });

  @override
  State<ManHinhKhoaPin> createState() => _ManHinhKhoaPinState();
}

class _ManHinhKhoaPinState extends State<ManHinhKhoaPin> {
  String _pinHienTai = '';
  String? _pinTamXacNhan;
  String _thongBaoHuongDan = '';
  String? _thongBaoLoi;

  @override
  void initState() {
    super.initState();
    _khoiTaoHuongDan();
  }

  void _khoiTaoHuongDan() {
    switch (widget.cheDo) {
      case CheDoPin.moKhoaApp:
        _thongBaoHuongDan = 'Nhập mã PIN để mở ứng dụng';
        break;
      case CheDoPin.taoPinMoi:
        _thongBaoHuongDan = 'Nhập 4 số làm mã PIN mới';
        break;
      case CheDoPin.tatPin:
        _thongBaoHuongDan = 'Nhập mã PIN hiện tại để tắt';
        break;
    }
  }

  void _bamSo(String so) {
    if (_pinHienTai.length < 4) {
      setState(() {
        _pinHienTai += so;
        _thongBaoLoi = null;
      });

      if (_pinHienTai.length == 4) {
        _xuLyKiemTraPin();
      }
    }
  }

  void _xoaMotSo() {
    if (_pinHienTai.isNotEmpty) {
      setState(() {
        _pinHienTai = _pinHienTai.substring(0, _pinHienTai.length - 1);
        _thongBaoLoi = null;
      });
    }
  }

  Future<void> _xuLyKiemTraPin() async {
    final pinNhap = _pinHienTai;

    if (widget.cheDo == CheDoPin.moKhoaApp) {
      final dung = await BaoMatDichVu.kiemTraPin(pinNhap);
      if (dung) {
        if (widget.onMoKhoaThanhCong != null) {
          widget.onMoKhoaThanhCong!();
        } else {
          if (mounted) Navigator.pop(context, true);
        }
      } else {
        setState(() {
          _pinHienTai = '';
          _thongBaoLoi = 'Mã PIN không đúng, vui lòng thử lại!';
        });
      }
    } else if (widget.cheDo == CheDoPin.taoPinMoi) {
      if (_pinTamXacNhan == null) {
        setState(() {
          _pinTamXacNhan = pinNhap;
          _pinHienTai = '';
          _thongBaoHuongDan = 'Nhập lại mã PIN để xác nhận';
        });
      } else {
        if (_pinTamXacNhan == pinNhap) {
          await BaoMatDichVu.datMaPin(pinNhap);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã thiết lập mã PIN bảo mật thành công!'),
                backgroundColor: MauSacApp.mauThanhCong,
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          setState(() {
            _pinTamXacNhan = null;
            _pinHienTai = '';
            _thongBaoHuongDan = 'Nhập 4 số làm mã PIN mới';
            _thongBaoLoi = 'Mã PIN xác nhận không trùng khớp, vui lòng làm lại!';
          });
        }
      }
    } else if (widget.cheDo == CheDoPin.tatPin) {
      final dung = await BaoMatDichVu.kiemTraPin(pinNhap);
      if (dung) {
        await BaoMatDichVu.tatKhoaPin();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã tắt khóa mã PIN!'),
              backgroundColor: MauSacApp.mauThanhCong,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        setState(() {
          _pinHienTai = '';
          _thongBaoLoi = 'Mã PIN không đúng!';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MauSacApp.mauNen,
      appBar: widget.cheDo != CheDoPin.moKhoaApp
          ? AppBar(
              title: const Text('Bảo Mật Mã PIN'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Icon chìa khóa bảo mật
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: MauSacApp.mauChinh.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 42,
                    color: MauSacApp.mauChinh,
                  ),
                ),
                const SizedBox(height: 20),

                // Tiêu đề
                Text(
                  widget.cheDo == CheDoPin.moKhoaApp
                      ? 'Khách Sạn Grand Luxury'
                      : 'Cài Đặt Khóa PIN',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: MauSacApp.mauChuChinh,
                  ),
                ),
                const SizedBox(height: 8),

                // Hướng dẫn
                Text(
                  _thongBaoHuongDan,
                  style: const TextStyle(
                    fontSize: 14,
                    color: MauSacApp.mauChuPhu,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),

                // 4 Chấm tròn biểu thị 4 chữ số PIN
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final daNhap = index < _pinHienTai.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: daNhap ? MauSacApp.mauChinh : Colors.transparent,
                        border: Border.all(
                          color: daNhap ? MauSacApp.mauChinh : MauSacApp.mauChuMo,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),

                // Báo lỗi (nếu có)
                if (_thongBaoLoi != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _thongBaoLoi!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: MauSacApp.mauLoi,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                const Spacer(flex: 2),

                // Bàn phím số Luxury Keypad (1 - 9, 0, Backspace)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: ['1', '2', '3'].map(_nutSo).toList(),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: ['4', '5', '6'].map(_nutSo).toList(),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: ['7', '8', '9'].map(_nutSo).toList(),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(width: 70, height: 70), // Khoảng trống cân bằng
                          _nutSo('0'),
                          _nutXoa(),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _nutSo(String so) {
    return InkWell(
      onTap: () => _bamSo(so),
      borderRadius: BorderRadius.circular(35),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: MauSacApp.mauBeMat,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          so,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: MauSacApp.mauChuChinh,
          ),
        ),
      ),
    );
  }

  Widget _nutXoa() {
    return InkWell(
      onTap: _xoaMotSo,
      borderRadius: BorderRadius.circular(35),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: MauSacApp.mauBeMat,
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.backspace_outlined,
          color: MauSacApp.mauChuChinh,
          size: 24,
        ),
      ),
    );
  }
}
