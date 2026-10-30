import 'package:flutter/material.dart';
import '../../cau_hinh/mau_sac_app.dart';
import '../../dich_vu/bot_ai_dich_vu.dart';
import '../../mo_hinh/tin_nhan_bot.dart';
import '../chi_tiet_phong/man_hinh_chi_tiet_phong.dart';
import '../dat_phong/man_hinh_dat_phong.dart';
import '../trang_chu/thanh_phan/the_phong.dart';

class ManHinhTroLyAi extends StatefulWidget {
  const ManHinhTroLyAi({super.key});

  @override
  State<ManHinhTroLyAi> createState() => _ManHinhTroLyAiTrangThai();
}

class _ManHinhTroLyAiTrangThai extends State<ManHinhTroLyAi> {
  final List<TinNhanBot> _danhSachTinNhan = [];
  final TextEditingController _dieuKhienTinNhan = TextEditingController();
  final ScrollController _dieuKhienCuon = ScrollController();
  bool _dangGuiTin = false;

  @override
  void initState() {
    super.initState();
    // Tin nhan chao mung mac dinh
    _danhSachTinNhan.add(
      TinNhanBot.tuBot(
        noiDung:
            'Xin chào quý khách! Em là trợ lý ảo AI của khách sạn. Em có thể hỗ trợ quý khách tìm phòng, tư vấn tiện ích và giá phòng. Quý khách cần em hỗ trợ gì hôm nay ạ?',
      ),
    );
  }

  @override
  void dispose() {
    _dieuKhienTinNhan.dispose();
    _dieuKhienCuon.dispose();
    super.dispose();
  }

  void _cuonXuongCuoi() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_dieuKhienCuon.hasClients) {
        _dieuKhienCuon.animateTo(
          _dieuKhienCuon.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _guiTinNhan([String? tinNhanMau]) async {
    final noiDung = (tinNhanMau ?? _dieuKhienTinNhan.text).trim();
    if (noiDung.isEmpty || _dangGuiTin) return;

    if (tinNhanMau == null) {
      _dieuKhienTinNhan.clear();
    }

    setState(() {
      _danhSachTinNhan.add(TinNhanBot.tuKhachHang(noiDung));
      _dangGuiTin = true;
    });
    _cuonXuongCuoi();

    try {
      final ketQua = await BotAiDichVu.guiTinNhan(noiDungTinNhan: noiDung);
      setState(() {
        _danhSachTinNhan.add(
          TinNhanBot.tuBot(
            noiDung: ketQua['noi_dung'] ?? 'Em đã ghi nhận thông tin của quý khách!',
            danhSachPhongGoiY: ketQua['danh_sach_phong'] ?? [],
            duLieuDatPhong: ketQua['thong_tin_dat_phong'],
            nguon: ketQua['nguon'],
          ),
        );
      });
    } catch (_) {
      setState(() {
        _danhSachTinNhan.add(
          TinNhanBot.tuBot(
            noiDung: 'Hệ thống đang bận hoặc mất kết nối, quý khách vui lòng thử lại sau nhé!',
          ),
        );
      });
    } finally {
      setState(() {
        _dangGuiTin = false;
      });
      _cuonXuongCuoi();
    }
  }

  @override
  Widget build(BuildContext nguoiCanh) {
    return Scaffold(
      backgroundColor: MauSacApp.mauNen,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: MauSacApp.mauDiemNhan, size: 20),
            SizedBox(width: 8),
            Text('Trợ Lý AI Tư Vấn Phòng'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Danh sach tin nhan
          Expanded(
            child: ListView.builder(
              controller: _dieuKhienCuon,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _danhSachTinNhan.length,
              itemBuilder: (nguoiCanhMoi, viTri) {
                final tinNhan = _danhSachTinNhan[viTri];
                final laKhachHang = tinNhan.nguoiGui == NguoiGuiTin.khachHang;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment:
                        laKhachHang ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            laKhachHang ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!laKhachHang) ...[
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: MauSacApp.mauChinh,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.support_agent_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: laKhachHang ? MauSacApp.mauChinh : MauSacApp.mauBeMat,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(laKhachHang ? 16 : 4),
                                  bottomRight: Radius.circular(laKhachHang ? 4 : 16),
                                ),
                                border: laKhachHang
                                    ? null
                                    : Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tinNhan.noiDung,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: laKhachHang ? Colors.white : MauSacApp.mauChuChinh,
                                      height: 1.4,
                                    ),
                                  ),
                                  if (!laKhachHang && tinNhan.nguon != null) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          tinNhan.nguon == 'API' ? Icons.cloud_done_rounded : Icons.offline_bolt_rounded,
                                          size: 11,
                                          color: tinNhan.nguon == 'API' ? Colors.indigo.shade600 : MauSacApp.mauThanhCong,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          tinNhan.nguon == 'API' ? 'Cloud AI (Gemini API)' : 'On-Device AI (Cục bộ)',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: tinNhan.nguon == 'API' ? Colors.indigo.shade600 : MauSacApp.mauThanhCong,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Hien thi phong goi y neu co
                      if (tinNhan.danhSachPhongGoiY.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        ...tinNhan.danhSachPhongGoiY.map((phong) {
                          return ThePhong(
                            loaiPhong: phong,
                            khiBamXemChiTiet: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (nguoiCanhXem) =>
                                      ManHinhChiTietPhong(loaiPhong: phong),
                                ),
                              );
                            },
                            khiBamDatPhong: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (nguoiCanhDat) =>
                                      ManHinhDatPhong(loaiPhong: phong),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Hieu ung dang xu ly
          if (_dangGuiTin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              alignment: Alignment.centerLeft,
              child: const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: MauSacApp.mauChinh),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Trợ lý AI đang trả lời...',
                    style: TextStyle(fontSize: 12, color: MauSacApp.mauChuPhu, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

          // Goi y cau hoi nhanh
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _nutGoiY('Tư vấn phòng cho 2 người'),
                _nutGoiY('Phòng view biển cao cấp'),
                _nutGoiY('Giá phòng Standard'),
                _nutGoiY('Các tiện nghi của khách sạn'),
              ],
            ),
          ),

          // Khung nhap tin nhan
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: MauSacApp.mauBeMat,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _dieuKhienTinNhan,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _guiTinNhan(),
                      decoration: const InputDecoration(
                        hintText: 'Hỏi trợ lý AI về phòng nghỉ...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _dangGuiTin ? null : () => _guiTinNhan(),
                    icon: const Icon(Icons.send_rounded),
                    color: MauSacApp.mauChinh,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nutGoiY(String noiDung) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(noiDung, style: const TextStyle(fontSize: 12)),
        backgroundColor: MauSacApp.mauBeMatPhu,
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        onPressed: () => _guiTinNhan(noiDung),
      ),
    );
  }
}
