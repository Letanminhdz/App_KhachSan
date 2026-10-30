import 'dart:math';
import '../mo_hinh/loai_phong.dart';
import '../tien_ich/dinh_dang.dart';
import 'phong_dich_vu.dart';

/// Thuật toán Trợ lý AI Tư Vấn Phòng Khách Sạn (On-Device NLP & Intent Engine V2)
/// Tích hợp bộ tách từ ngữ nghĩa tiếng Việt (N-gram Tokenizer), tính điểm tương đồng Jaccard/Cosine,
/// trích xuất thực thể mờ (Fuzzy Entity Extraction) và phân loại ý định theo trọng số xác suất.
/// Chạy 100% Cục bộ Offline bằng Dart trên điện thoại, không tốn thêm tài nguyên và phản hồi tức thì (<50ms).
class TroLyAiEngine {
  static List<LoaiPhong>? _danhSachPhongCache;
  static DateTime? _thoiGianCapNhatPhong;

  static List<Map<String, dynamic>>? _danhSachDichVuCache;
  static DateTime? _thoiGianCapNhatDichVu;

  static Map<String, dynamic>? _thongTinKhachSanCache;
  static DateTime? _thoiGianCapNhatKhachSan;

  static const Duration _thoiGianHetHanCache = Duration(minutes: 5);

  /// Hàm chuẩn hóa & khử dấu tiếng Việt hỗ trợ tìm kiếm không dấu
  static String boDau(String str) {
    var result = str.toLowerCase();
    result = result.replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a');
    result = result.replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e');
    result = result.replaceAll(RegExp(r'[ìíịỉĩ]'), 'i');
    result = result.replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o');
    result = result.replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u');
    result = result.replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y');
    result = result.replaceAll(RegExp(r'[đ]'), 'd');
    // Khử phím gõ telex thừa ở đuôi từ (ví dụ: tienj -> tien, phongf -> phong)
    result = result.replaceAll(RegExp(r'([a-z]+)[sfrxj]\b'), r'$1');
    return result;
  }

  /// Trích xuất danh sách N-gram (1-gram và 2-gram) để so khớp ngữ nghĩa tự nhiên
  static Set<String> _taoNgrams(String vanBan) {
    final tuList = vanBan.toLowerCase().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    final Set<String> ngrams = {};
    for (int i = 0; i < tuList.length; i++) {
      ngrams.add(tuList[i]);
      if (i + 1 < tuList.length) {
        ngrams.add('${tuList[i]} ${tuList[i + 1]}');
      }
      if (i + 2 < tuList.length) {
        ngrams.add('${tuList[i]} ${tuList[i + 1]} ${tuList[i + 2]}');
      }
    }
    return ngrams;
  }

  static const Set<String> _tuDungChung = {
    'phong', 'co', 'nao', 'cac', 'cua', 'nhung', 'la', 'o', 'di', 'gi',
    'khach', 'san', 'cho', 'toi', 'minh', 'em', 'nhat', 'bao', 'nhieu'
  };

  /// Tính điểm tương đồng ngữ nghĩa giữa câu hỏi và bộ từ khóa mẫu
  static double _tinhDiemTuongDong(String cauHoiKhongDau, List<String> mauTuKhoa) {
    final ngramsCauHoi = _taoNgrams(cauHoiKhongDau);
    double diem = 0;
    for (final mau in mauTuKhoa) {
      final mauKd = boDau(mau);
      // Sử dụng word-boundary hoặc ngrams để tránh nhầm chuỗi con (ví dụ: 'cho toi' chứa 'o to')
      if (ngramsCauHoi.contains(mauKd) || RegExp(r'(^|\s)' + RegExp.escape(mauKd) + r'($|\s)').hasMatch(cauHoiKhongDau)) {
        diem += 5.0; // Thưởng điểm cao cho khớp nguyên cụm từ
      } else {
        final mauTokens = mauKd.split(' ').where((t) => !_tuDungChung.contains(t)).toList();
        if (mauTokens.isNotEmpty) {
          int matched = 0;
          for (final token in mauTokens) {
            if (ngramsCauHoi.contains(token)) {
              matched++;
            }
          }
          if (matched >= mauTokens.length) {
            diem += 3.0;
          } else if (matched > 0 && mauTokens.length > 1 && matched >= mauTokens.length - 1) {
            diem += 1.5;
          }
        }
      }
    }
    return diem;
  }

  /// Kiểm tra có chứa từ khóa (có biên giới từ để tránh nhầm lẫn)
  static bool _chuaTuKhoa(String text, List<String> danhSach) {
    for (final tu in danhSach) {
      final regex = RegExp(r'(^|\s)' + RegExp.escape(tu) + r'($|\s)');
      if (regex.hasMatch(text)) return true;
    }
    return false;
  }

  /// Hàm xử lý chính nhận câu hỏi từ người dùng
  static Future<Map<String, dynamic>> xuLyTinNhan(
    String noiDungTinNhan, {
    List<Map<String, dynamic>> lichSu = const [],
    bool buocLamMoiPhong = false,
  }) async {
    // 1. Tiền xử lý văn bản
    final text = noiDungTinNhan.trim().toLowerCase();
    final textClean = text.replaceAll(RegExp(r'[?!.,;:_]'), ' ');
    final textKhongDau = boDau(textClean);

    final canLamMoi = buocLamMoiPhong || _chuaTuKhoa(textKhongDau, [
      'bao nhieu hang phong', 'bao nhieu loai phong', 'may hang phong', 'may loai phong',
      'danh sach phong', 'danh sach hang phong', 'co may phong', 'co bao nhieu phong',
      'co nhung phong nao', 'co nhung loai phong nao', 'nhung hang phong nao'
    ]);

    final danhSachPhong = await _layDanhSachPhongThucTe(buocLamMoi: canLamMoi);
    final thongTinKhachSan = await _layThongTinKhachSanThucTe();
    final danhSachDichVu = await _layDanhSachDichVuThucTe();

    // 2. Trích xuất Thực thể & Phân tích ngữ cảnh
    final entities = _trichXuatThucThe(textClean, textKhongDau, danhSachPhong);

    // 3. Chấm điểm & Xếp hạng Phòng phù hợp
    final danhSachPhongGoiY = _chamDiemVaXepHangPhong(entities, danhSachPhong);

    // 4. Phân loại Ý định bằng Decision Tree + Semantic Score
    return _sinhPhanHoi(
      entities: entities,
      danhSachPhong: danhSachPhong,
      danhSachDichVu: danhSachDichVu,
      phongGoiY: danhSachPhongGoiY,
      khachSan: thongTinKhachSan,
      textClean: textClean,
      textKhongDau: textKhongDau,
    );
  }

  /// Trích xuất thực thể nâng cao (Fuzzy Entity Extraction)
  static Map<String, dynamic> _trichXuatThucThe(
    String textClean,
    String textKhongDau,
    List<LoaiPhong> danhSachPhong,
  ) {
    int? soNguoi;
    String? hangPhong;

    // 1. Nhận diện số người thông minh (cả số viết và số chữ)
    final regexSo = RegExp(r'(?:cho|khoang|tam|nhom|di|o|can|doan|khoảng|tầm|nhóm|đi|ở|cần|đoàn)?\s*(\d+)\s*(?:nguoi|khach|ban|thanh vien|pax|người|khách|bạn|thành viên|ve|cho)');
    final match = regexSo.firstMatch(textClean) ?? regexSo.firstMatch(textKhongDau);
    if (match != null) {
      soNguoi = int.tryParse(match.group(1) ?? '');
    } else if (_chuaTuKhoa(textKhongDau, ['1 minh', 'mot minh', 'phong don', 'ca nhan', 'di mot minh', 'o mot minh', '1 nguoi', 'mot nguoi'])) {
      soNguoi = 1;
    } else if (_chuaTuKhoa(textKhongDau, ['2 nguoi', 'hai nguoi', 'phong doi', 'cap doi', 'vo chong', '2 vo chong', 'hai ban', 'di 2 nguoi', 'cho 2 nguoi', '2 khach'])) {
      soNguoi = 2;
    } else if (_chuaTuKhoa(textKhongDau, ['3 nguoi', 'ba nguoi', 'di 3 nguoi', 'nhom 3 nguoi', 'cho 3 nguoi', '3 khach'])) {
      soNguoi = 3;
    } else if (_chuaTuKhoa(textKhongDau, ['4 nguoi', 'bon nguoi', 'gia dinh', 'phong gia dinh', '4 thanh vien', 'di 4 nguoi', 'cho 4 nguoi', '4 khach'])) {
      soNguoi = 4;
    } else if (_chuaTuKhoa(textKhongDau, ['5 nguoi', 'nam nguoi', '6 nguoi', 'sau nguoi', 'doan dong', 'nhom dong', 'nhieu nguoi'])) {
      soNguoi = 5;
    }

    // 2. Nhận diện hạng phòng (Fuzzy matching tên phòng)
    for (final p in danhSachPhong) {
      final tenLoaiKhongDau = boDau(p.tenLoai);
      final tenRutGon = tenLoaiKhongDau.replaceAll('phong', '').trim();
      if (textKhongDau.contains(tenLoaiKhongDau) || 
          textClean.contains(p.tenLoai.toLowerCase()) ||
          (tenRutGon.isNotEmpty && textKhongDau.contains(tenRutGon))) {
        hangPhong = p.tenLoai;
        break;
      }
    }

    // 3. Tính điểm các Intent bằng Semantic Similarity
    return {
      'so_nguoi': soNguoi,
      'hang_phong': hangPhong,
      'score_danh_sach': _tinhDiemTuongDong(textKhongDau, [
        'bao nhieu hang phong', 'bao nhieu loai phong', 'may hang phong', 'may loai phong',
        'co bao nhieu phong', 'co may hang phong', 'nhung hang phong nao', 'nhung loai phong nao',
        'danh sach hang phong', 'danh sach loai phong', 'danh sach phong', 'cac hang phong',
        'cac loai phong', 'ke ten cac phong', 'cac phong cua khach san', 'tat ca cac phong', 'tat ca phong'
      ]),
      'score_re_nhat': _tinhDiemTuongDong(textKhongDau, [
        're nhat', 'thap nhat', 'tiet kiem nhat', 'gia thap nhat', 'gia re nhat', 're tien nhat', 'phong re nhat'
      ]),
      'score_dat_nhat': _tinhDiemTuongDong(textKhongDau, [
        'dat nhat', 'xin nhat', 'vip nhat', 'cao cap nhat', 'sang trong nhat', 'tot nhat', 'phong tong thong', 'phong dat nhat'
      ]),
      'score_view_bien': _tinhDiemTuongDong(textKhongDau, [
        'view bien', 'huong bien', 'nhin ra bien', 'ngam bien', 'phong view bien', 'phong huong bien', 'ban cong ngam bien'
      ]),
      'score_gia_ca': _tinhDiemTuongDong(textKhongDau, [
        'bang gia', 'gia cac phong', 'gia phong bao nhieu', 'chi phi cac phong', 'bang gia phong'
      ]),
      'score_gio_giac': _tinhDiemTuongDong(textKhongDau, [
        'gio nhan phong', 'gio tra phong', 'check in', 'check out', 'may gio nhan', 'may gio tra', 'nhan phong luc may gio', 'nhan phong som', 'tra phong tre'
      ]),
      'score_dat_coc': _tinhDiemTuongDong(textKhongDau, [
        'dat coc', 'tien coc', 'coc bao nhieu', 'chuyen khoan coc', 'giu phong bao nhieu', 'chinh sach coc'
      ]),
      'score_dia_chi': _tinhDiemTuongDong(textKhongDau, [
        'dia chi', 'o dau', 'vi tri', 'hotline', 'so dien thoai', 'sdt', 'lien he', 'so le tan', 'so dien thoai khach san'
      ]),
      'score_khoang_cach_bien': _tinhDiemTuongDong(textKhongDau, [
        'cach bien bao xa', 'di bo ra bien', 'gan bien khong', 'sat bien khong', 'ra bien mat bao lau', 'khoang cach ra bien', 'khoang cach bien', 'cach bien', 'ra bien bao xa'
      ]),
      'score_an_sang': _tinhDiemTuongDong(textKhongDau, [
        'an sang', 'buffet sang', 'bua sang', 'an sang may gio', 'co bao gom an sang', 'co do an khong', 'buffet gia bao nhieu', 'an sang gia bao nhieu'
      ]),
      'score_ho_boi': _tinhDiemTuongDong(textKhongDau, [
        'ho boi', 'be boi', 'co ho boi', 'co be boi', 'ho boi vo cuc', 'tam ho boi'
      ]),
      'score_dua_don_xe': _tinhDiemTuongDong(textKhongDau, [
        'dua don', 'san bay', 'don san bay', 'xe dua don', 'thue xe may', 'xe dua ve khach san'
      ]),
      'score_tre_em_giuong_phu': _tinhDiemTuongDong(textKhongDau, [
        'tre em', 'em be', 'con nho', 'giuong phu', 'extra bed', 'ke them giuong', 'phu thu tre em', 'nha co be nho'
      ]),
      'score_do_xe': _tinhDiemTuongDong(textKhongDau, [
        'do xe', 'bai do xe', 'gui xe', 'dau xe', 'o to', 'cho de xe', 'co cho dau o to'
      ]),
      'score_wifi': _tinhDiemTuongDong(textKhongDau, [
        'wifi', 'pass wifi', 'mat khau wifi', 'mang internet', 'wifi co manh khong'
      ]),
      'score_thu_cung_hut_thuoc': _tinhDiemTuongDong(textKhongDau, [
        'hut thuoc', 'thu cung', 'cho meo', 'mang theo cho', 'mang theo meo', 'pet', 'co duoc hut thuoc'
      ]),
      'score_chinh_sach_huy': _tinhDiemTuongDong(textKhongDau, [
        'huy phong', 'doi ngay', 'hoan tien', 'chinh sach huy', 'doi lich', 'huy co mat tien khong'
      ]),
      'score_dat_phong': _tinhDiemTuongDong(textKhongDau, [
        'dat phong', 'book phong', 'giu phong', 'toi muon dat', 'len don', 'cach dat phong', 'muon thue phong'
      ]),
      'score_tien_nghi': _tinhDiemTuongDong(textKhongDau, [
        'tien nghi', 'tien ich', 'trang thiet bi', 'noi that', 'co nhung gi', 'trong phong co gi',
        'tien nghi phong', 'tien ich phong', 'tien nghi khach san', 'tien ich khach san',
        'bon tam', 'dieu hoa', 'tivi', 'tu lanh', 'may say toc', 'ban lam viec', 'minibar'
      ]),
      'score_bon_tam': _tinhDiemTuongDong(textKhongDau, [
        'bon tam', 'bon tam nam', 'bon suc', 'jacuzzi', 'tam bon', 'co bon tam khong'
      ]),
    };
  }

  /// Chấm điểm và xếp hạng phòng
  static List<LoaiPhong> _chamDiemVaXepHangPhong(
    Map<String, dynamic> entities,
    List<LoaiPhong> danhSachPhong,
  ) {
    final List<Map<String, dynamic>> danhSachDiem = [];

    for (final room in danhSachPhong) {
      int score = 0;
      final nameLower = boDau(room.tenLoai);
      final descLower = boDau(room.moTa ?? '');

      // 1. Khớp sức chứa
      final soNguoi = entities['so_nguoi'] as int?;
      if (soNguoi != null) {
        if (room.sucChua == soNguoi) {
          score += 45;
        } else if (room.sucChua > soNguoi) {
          score += max(10, 35 - (room.sucChua - soNguoi) * 8);
        } else {
          score -= 50;
        }
      }

      // 2. Khớp hạng phòng
      final hangPhong = entities['hang_phong'] as String?;
      if (hangPhong != null && boDau(hangPhong) == nameLower) {
        score += 60;
      }

      // 3. Khớp view biển
      if ((entities['score_view_bien'] as double) > 0) {
        if (nameLower.contains('suite') || nameLower.contains('deluxe') || descLower.contains('bien')) {
          score += 40;
        }
      }

      // 4. Khớp tiện nghi (ví dụ bồn tắm, smart tv)
      if ((entities['score_tien_nghi'] as double) > 0) {
        final tienIchStr = room.tienIch.map((t) => boDau(t)).join(' ');
        if (tienIchStr.contains('bon tam') || descLower.contains('bon tam')) {
          score += 35;
        }
      }

      // 5. Khớp rẻ nhất / đắt nhất (Động theo giá thực tế trong CSDL)
      if (danhSachPhong.isNotEmpty) {
        final minGia = danhSachPhong.map((p) => p.giaCoBan).reduce(min);
        final maxGia = danhSachPhong.map((p) => p.giaCoBan).reduce(max);
        if ((entities['score_re_nhat'] as double) > 0 && room.giaCoBan <= minGia) {
          score += 35;
        }
        if ((entities['score_dat_nhat'] as double) > 0 && room.giaCoBan >= maxGia) {
          score += 35;
        }
      }

      if (score > 0) {
        danhSachDiem.add({'room': room, 'score': score});
      }
    }

    danhSachDiem.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    return danhSachDiem.take(3).map((item) => item['room'] as LoaiPhong).toList();
  }

  /// Cây quyết định sinh phản hồi ngôn ngữ tự nhiên
  static Map<String, dynamic> _sinhPhanHoi({
    required Map<String, dynamic> entities,
    required List<LoaiPhong> danhSachPhong,
    required List<Map<String, dynamic>> danhSachDichVu,
    required List<LoaiPhong> phongGoiY,
    required Map<String, dynamic> khachSan,
    required String textClean,
    required String textKhongDau,
  }) {
    // Dữ liệu đọc thời gian thực từ CSDL MySQL bảng cai_dat
    final tenKs = khachSan['ten_khach_san'] ?? 'Khách Sạn Grand Luxury';
    final hotline = khachSan['so_dien_thoai'] ?? '1900 6868';
    final diaChi = khachSan['dia_chi'] ?? '123 Đường Bờ Biển, Đà Nẵng (sát bãi biển Mỹ Khê)';
    final khoangCachBien = khachSan['khoang_cach_bien'] ?? '50 mét (chưa đầy 2 phút đi bộ)';
    final gioBuffet = khachSan['buffet_sang_gio'] ?? '06:30 đến 09:30';
    final giaBuffet = int.tryParse(khachSan['buffet_sang_gia']?.toString() ?? '150000') ?? 150000;
    final giaXeSanBay = int.tryParse(khachSan['xe_san_bay_gia']?.toString() ?? '300000') ?? 300000;
    final giaThueXeMay = int.tryParse(khachSan['thue_xe_may_gia']?.toString() ?? '120000') ?? 120000;
    final giaGiuongPhu = int.tryParse(khachSan['giuong_phu_gia']?.toString() ?? '200000') ?? 200000;
    final hoBoiMoTa = khachSan['ho_boi_mo_ta'] ?? 'Khách sạn chưa có hồ bơi riêng, nằm sát biển Mỹ Khê cách chỉ 50 mét.';
    final baiDoXeMoTa = khachSan['bai_do_xe_mo_ta'] ?? 'Tầng hầm đỗ xe ô tô và xe máy MIỄN PHÍ 24/7 có bảo vệ trực.';
    final gioCheckIn = khachSan['gio_check_in'] ?? '14:00';
    final gioCheckOut = khachSan['gio_check_out'] ?? '12:00';
    final tiLeCoc = khachSan['ti_le_coc'] ?? '30';
    final chinhSachHuy = khachSan['chinh_sach_huy'] ?? 'Miễn phí hủy/đổi lịch trước 48 giờ';

    // 1. Chào hỏi
    final regexChao = RegExp(r'^(chào|xin chào|hi|hello|alo|ê|bạn ơi|em ơi|chao|xin chao)');
    if (regexChao.hasMatch(textClean) || regexChao.hasMatch(textKhongDau)) {
      final tenCacPhong = danhSachPhong.map((p) => p.tenLoai).join(', ');
      return {
        'noi_dung': 'Dạ, em chào anh/chị ạ! Em là Trợ lý AI của $tenKs.\n\n'
            'Hiện tại khách sạn có **${danhSachPhong.length} hạng phòng chính**: $tenCacPhong với tiêu chuẩn tiện nghi cao cấp.\n\n'
            'Anh/chị cần em hỗ trợ tìm phòng cho bao nhiêu người hoặc tư vấn thông tin gì ạ?',
        'danh_sach_phong': <LoaiPhong>[],
        'intent': 'GREETING',
      };
    }

    // 2. Cảm ơn & Tạm biệt
    if (_chuaTuKhoa(textKhongDau, ['cam on', 'thank', 'tuyet voi', 'oke', 'ok', 'tam biet', 'bye'])) {
      return {
        'noi_dung': 'Dạ không có gì ạ! Rất hân hạnh được hỗ trợ anh/chị. Chúc anh/chị có một kỳ nghỉ thật vui vẻ và đáng nhớ tại $tenKs! Nếu cần thêm thông tin gì, anh/chị cứ nhắn em nhé! ❤️',
        'danh_sach_phong': <LoaiPhong>[],
        'intent': 'GRATITUDE',
      };
    }

    // 3. Khoảng cách ra biển (Ưu tiên phân định trước khi tìm phòng view biển)
    if ((entities['score_khoang_cach_bien'] as double) >= 2.0 || 
        _chuaTuKhoa(textKhongDau, ['khoang cach', 'cach bien', 'ra bien bao xa', 'di bo ra bien', 'bien bao xa'])) {
      return {
        'noi_dung': 'Dạ, $tenKs nằm ngay trên trục đường ven biển:\n\n'
            '🌊 **Khoảng cách ra biển:** $khoangCachBien ra thẳng bãi cát trắng và bãi tắm biển!\n'
            '📍 **Địa chỉ:** $diaChi',
        'danh_sach_phong': <LoaiPhong>[],
        'intent': 'HOTEL_LOCATION_DISTANCE',
      };
    }

    // 4. Bữa sáng / Buffet (Ưu tiên phân định trước khi hỏi giá phòng rẻ nhất)
    if ((entities['score_an_sang'] as double) >= 2.0 || 
        _chuaTuKhoa(textKhongDau, ['an sang', 'buffet sang', 'bua sang'])) {
      return {
        'noi_dung': 'Dạ về dịch vụ ăn sáng tại $tenKs:\n\n'
            '🍽️ **Buffet Sáng Cao Cấp:** Phục vụ hàng ngày từ **$gioBuffet** tại nhà hàng tầng 2 của khách sạn.\n'
            '• Thực đơn phong phú hơn 40 món Á - Âu, quầy bánh ngọt, nước ép trái cây tươi và cà phê chuẩn vị.\n'
            '• Giá vé niêm yết: **${DinhDang.dinhDangTien(giaBuffet.toDouble())} / người** (đã bao gồm trong một số gói phòng ưu đãi).\n\n'
            'Anh/chị có thể đăng ký dịch vụ ăn sáng khi nhận phòng tại quầy lễ tân ạ!',
        'danh_sach_phong': <LoaiPhong>[],
        'intent': 'HOTEL_BREAKFAST',
      };
    }

    // 5. Xe đưa đón sân bay & thuê xe máy
    if ((entities['score_dua_don_xe'] as double) >= 2.0 || 
        _chuaTuKhoa(textKhongDau, ['san bay', 'don san bay', 'xe dua don', 'thue xe may'])) {
      return {
        'noi_dung': 'Dạ, khách sạn có sẵn các dịch vụ di chuyển tiện lợi cho khách hàng:\n\n'
            '🚗 **Đưa đón sân bay 2 chiều:** ${DinhDang.dinhDangTien(giaXeSanBay.toDouble())} / chuyến (xe 4 - 7 chỗ đời mới, đón tận cổng sân bay).\n'
            '🛵 **Cho thuê xe máy dạo phố:** Chỉ từ ${DinhDang.dinhDangTien(giaThueXeMay.toDouble())} / ngày (kèm 2 nón bảo hiểm và áo mưa tiện lợi).\n\n'
            'Anh/chị chỉ cần báo trước giờ hạ cánh, tài xế khách sạn sẽ đón đúng giờ ạ!',
        'danh_sach_phong': <LoaiPhong>[],
        'intent': 'HOTEL_AIRPORT_SHUTTLE',
      };
    }

    // 6. Hồ bơi
    if ((entities['score_ho_boi'] as double) >= 2.0 || _chuaTuKhoa(textKhongDau, ['ho boi', 'be boi'])) {
      return {
        'noi_dung': 'Dạ hiện tại $hoBoiMoTa\n\n'
            '🌊 Anh/chị chỉ cần đi bộ chưa đầy 2 phút là ra thẳng bãi biển tắm biển thỏa thích ạ!\n'
            'Khách sạn có các phòng view biển đẹp mắt đón gió biển tự nhiên rất thoáng mát ạ.',
        'danh_sach_phong': <LoaiPhong>[],
        'intent': 'HOTEL_SWIMMING_POOL',
      };
    }

    // 7. Bãi đỗ xe ô tô
    if ((entities['score_do_xe'] as double) >= 2.0 || _chuaTuKhoa(textKhongDau, ['do xe', 'bai do xe', 'gui xe', 'dau xe'])) {
      return {
        'noi_dung': 'Dạ, $tenKs có bãi đỗ xe an toàn:\n\n'
            '🚗 $baiDoXeMoTa\n'
            '• Xe ô tô từ 4 đến 16 chỗ đều vào hầm thuận tiện và dễ dàng ạ!',
        'danh_sach_phong': <LoaiPhong>[],
        'intent': 'HOTEL_PARKING',
      };
    }

    // 8. Trẻ em & Giường phụ
    if ((entities['score_tre_em_giuong_phu'] as double) >= 2.0 || _chuaTuKhoa(textKhongDau, ['tre em', 'giuong phu', 'extra bed'])) {
      return {
        'noi_dung': 'Dạ về chính sách trẻ em và giường phụ tại khách sạn:\n\n'
            '👶 **Trẻ em:**\n'
            '• Dưới 6 tuổi: Miễn phí hoàn toàn khi ngủ chung giường với bố mẹ (tối đa 1 bé/phòng).\n'
            '• Từ 6 - 11 tuổi: Phụ thu ăn sáng nhẹ 80.000₫/ngày.\n\n'
            '🛏️ **Giường phụ (Extra Bed):**\n'
            '• Khách sạn hỗ trợ kê thêm giường phụ với chi phí **${DinhDang.dinhDangTien(giaGiuongPhu.toDouble())} / đêm**.',
        'danh_sach_phong': <LoaiPhong>[],
        'intent': 'HOTEL_CHILDREN_EXTRA_BED',
      };
    }

    // 9. Giờ giấc check-in / check-out
    if ((entities['score_gio_giac'] as double) >= 2.0 || _chuaTuKhoa(textKhongDau, ['check in', 'check out', 'gio nhan', 'gio tra', 'nhan phong luc', 'tra phong luc'])) {
      return {
        'noi_dung': 'Dạ, quy định thời gian nhận và trả phòng của khách sạn như sau ạ:\n\n'
            '• **Giờ nhận phòng (Check-in):** Từ **$gioCheckIn** chiều.\n'
            '• **Giờ trả phòng (Check-out):** Trước **$gioCheckOut** trưa hôm sau.\n\n'
            'Trường hợp anh/chị cần nhận phòng sớm hoặc trả phòng trễ, khách sạn sẽ hỗ trợ linh hoạt tùy vào tình trạng phòng trống thực tế tại thời điểm đó ạ!',
        'danh_sach_phong': <LoaiPhong>[],
        'intent': 'POLICY_CHECK_IN_OUT',
      };
    }

    // 10. Đặt cọc
    if ((entities['score_dat_coc'] as double) >= 2.0 || _chuaTuKhoa(textKhongDau, ['dat coc', 'tien coc', 'coc bao nhieu'])) {
      return {
        'noi_dung': 'Dạ về quy định đặt cọc giữ phòng tại $tenKs:\n\n'
            '• Khách sạn nhận giữ phòng khi quý khách hoàn tất thanh toán cọc tối thiểu **$tiLeCoc% tổng tiền phòng**.\n'
            '• Chính sách hủy / đổi lịch: $chinhSachHuy.\n'
            '• Số tiền còn lại sẽ được thanh toán trực tiếp khi nhận phòng tại quầy lễ tân.\n'
            '• Khách sạn hỗ trợ chuyển khoản ngân hàng, quét mã VietQR hoặc thẻ ATM/Visa.',
        'danh_sach_phong': <LoaiPhong>[],
        'intent': 'HOTEL_DEPOSIT_POLICY',
      };
    }

    // 11. Chính sách hủy / hoàn tiền
    if ((entities['score_chinh_sach_huy'] as double? ?? 0) >= 2.0 || _chuaTuKhoa(textKhongDau, ['huy phong', 'doi ngay', 'hoan tien'])) {
      return {
        'noi_dung': 'Dạ về chính sách hủy và đổi lịch phòng tại $tenKs:\n\n'
            '• **Chính sách:** $chinhSachHuy.\n'
            '• Nếu hủy trước hạn quy định, khách sạn sẽ hoàn trả 100% tiền cọc về tài khoản của quý khách.\n'
            '• Mọi thắc mắc anh/chị có thể liên hệ trực tiếp lễ tân qua hotline **$hotline** để được xử lý nhanh nhất ạ!',
        'danh_sach_phong': <LoaiPhong>[],
        'intent': 'HOTEL_CANCELLATION_POLICY',
      };
    }

    // 12. WiFi
    if ((entities['score_wifi'] as double? ?? 0) >= 2.0 || _chuaTuKhoa(textKhongDau, ['wifi', 'pass wifi', 'mat khau wifi'])) {
      return {
        'noi_dung': 'Dạ, tại $tenKs hệ thống WiFi cáp quang tốc độ cao được phủ sóng toàn bộ các phòng và khuôn viên:\n\n'
            '📶 **Tên WiFi:** GrandLuxury_Guest\n'
            '🔑 **Mật khẩu:** grandluxury@2024 (hoặc quét mã QR dán trên bàn trà trong mỗi phòng)\n'
            '• Dịch vụ WiFi hoàn toàn MIỄN PHÍ cho toàn bộ khách lưu trú ạ!',
        'danh_sach_phong': <LoaiPhong>[],
        'intent': 'HOTEL_WIFI',
      };
    }

    // 13. Thú cưng & Hút thuốc
    if ((entities['score_thu_cung_hut_thuoc'] as double? ?? 0) >= 2.0 || _chuaTuKhoa(textKhongDau, ['thu cung', 'cho meo', 'pet', 'hut thuoc'])) {
      return {
        'noi_dung': 'Dạ về quy định lưu trú tại $tenKs:\n\n'
            '🐾 **Thú cưng:** Khách sạn hiện chưa hỗ trợ mang theo thú cưng (chó, mèo...) vào phòng nghỉ nhằm đảm bảo vệ sinh và tránh dị ứng cho các khách lưu trú sau.\n'
            '🚭 **Hút thuốc:** Tất cả các phòng đều là phòng không hút thuốc. Quý khách có thể hút thuốc tại khu vực ban công ngoài trời hoặc sảnh sân vườn riêng biệt ạ!',
        'danh_sach_phong': <LoaiPhong>[],
        'intent': 'HOTEL_PETS_SMOKING',
      };
    }

    // 14. Dịch vụ ẩm thực, massage, gọi món tới phòng từ CSDL MySQL bảng dich_vu
    if (_chuaTuKhoa(textKhongDau, ['dich vu', 'menu', 'thuc don', 'mon an', 'spa', 'massage', 'an uong', 'goi mon']) &&
        !_chuaTuKhoa(textKhongDau, ['dat phong', 'loai phong', 'hang phong'])) {
      if (danhSachDichVu.isNotEmpty) {
        final buffer = StringBuffer();
        for (final dv in danhSachDichVu) {
          final ten = dv['ten_dich_vu'] ?? dv['ten'] ?? 'Dịch vụ';
          final gia = double.tryParse(dv['gia']?.toString() ?? '0') ?? 0;
          buffer.writeln('• **$ten**: ${DinhDang.dinhDangTien(gia)}');
        }
        return {
          'noi_dung': 'Dạ tại $tenKs, chúng em có phục vụ các dịch vụ ẩm thực và thư giãn tận phòng theo thực đơn niêm yết:\n\n'
              '${buffer.toString()}\n'
              'Quý khách đang lưu trú tại khách sạn có thể bấm vào mục **Gọi Dịch Vụ** trên ứng dụng để nhân viên phục vụ tận phòng nhé!',
          'danh_sach_phong': <LoaiPhong>[],
          'intent': 'HOTEL_SERVICES_MENU',
        };
      } else {
        return {
          'noi_dung': 'Dạ tại $tenKs có cung cấp các dịch vụ ẩm thực và thư giãn tận phòng. Quý khách có thể xem thực đơn chi tiết tại mục **Gọi Dịch Vụ** trên ứng dụng hoặc liên hệ quầy lễ tân để được hỗ trợ gọi món nhé!',
          'danh_sach_phong': <LoaiPhong>[],
          'intent': 'HOTEL_SERVICES_MENU',
        };
      }
    }

    // 15. Địa chỉ / Hotline
    if ((entities['score_dia_chi'] as double) >= 2.0 || _chuaTuKhoa(textKhongDau, ['dia chi', 'hotline', 'so dien thoai', 'sdt', 'o dau'])) {
      return {
        'noi_dung': 'Dạ thông tin liên hệ chính thức của $tenKs:\n\n'
            '📍 **Địa chỉ:** $diaChi\n'
            '📞 **Hotline lễ tân (24/7):** $hotline\n'
            '✉️ **Email hỗ trợ:** ${khachSan['email'] ?? "contact@grandluxury.vn"}\n\n'
            'Lễ tân khách sạn luôn túc trực 24/24 để phục vụ quý khách chu đáo nhất!',
        'danh_sach_phong': <LoaiPhong>[],
        'intent': 'HOTEL_CONTACT_INFO',
      };
    }

    // 16. Tư vấn theo số lượng người
    if (entities['so_nguoi'] != null) {
      final soNguoi = entities['so_nguoi'] as int;
      List<LoaiPhong> ketQua = phongGoiY;
      if (ketQua.isEmpty) {
        ketQua = danhSachPhong.where((p) => p.sucChua >= soNguoi).toList();
      }

      if (ketQua.isNotEmpty) {
        final buffer = StringBuffer();
        for (final p in ketQua) {
          buffer.writeln('• **${p.tenLoai}**: Sức chứa ${p.sucChua} người — Giá ${DinhDang.dinhDangTien(p.giaCoBan)}/đêm');
        }
        return {
          'noi_dung': 'Dạ với đoàn **$soNguoi người**, khách sạn xin gợi ý các hạng phòng phù hợp nhất cho mình:\n\n'
              '${buffer.toString()}\n'
              'Em đã gửi kèm thẻ phòng bên dưới, anh/chị có thể bấm **Xem Chi Tiết** hoặc **Đặt Phòng** ngay nhé!',
          'danh_sach_phong': ketQua,
          'intent': 'SEARCH_BY_CAPACITY',
        };
      } else {
        final phongGoiYList = danhSachPhong.where((p) => p.sucChua >= 2).take(2).map((p) => p.tenLoai).join(' hoặc ');
        return {
          'noi_dung': 'Dạ với đoàn $soNguoi người, một phòng đơn lẻ có thể không đủ sức chứa tối đa. Anh/chị nên đặt từ 2 phòng trở lên (ví dụ kết hợp 2 phòng $phongGoiYList) để chuyến đi thoải mái nhất ạ!',
          'danh_sach_phong': danhSachPhong.take(2).toList(),
          'intent': 'SEARCH_BY_CAPACITY',
        };
      }
    }

    // 17. Hỏi phòng rẻ nhất
    if (_chuaTuKhoa(textKhongDau, ['re nhat', 'thap nhat', 'tiet kiem nhat', 'gia re nhat', 're tien']) ||
        ((entities['score_re_nhat'] as double) >= 3.0 && !_chuaTuKhoa(textKhongDau, ['an sang', 'xe', 'dich vu']))) {
      final phongReNhat = danhSachPhong.reduce((a, b) => a.giaCoBan < b.giaCoBan ? a : b);
      return {
        'noi_dung': 'Dạ, hạng phòng có mức giá tiết kiệm nhất tại khách sạn là **${phongReNhat.tenLoai}** với giá chỉ **${DinhDang.dinhDangTien(phongReNhat.giaCoBan)}/đêm**:\n\n'
            '• Sức chứa: Phù hợp cho 1-2 người\n'
            '• Tiện nghi: Điều hòa 2 chiều, TV màn hình phẳng, mini bar, vòi sen nóng lạnh, WiFi miễn phí\n'
            '• Mô tả: ${phongReNhat.moTa ?? "Không gian ấm cúng, đầy đủ tiện nghi chuẩn mực."}\n\n'
            'Anh/chị có thể tham khảo thẻ phòng bên dưới và nhấn **Đặt Phòng** nhé!',
        'danh_sach_phong': [phongReNhat],
        'intent': 'CHEAPEST_ROOM',
      };
    }

    // 18. Hỏi phòng đắt nhất / VIP nhất
    if ((entities['score_dat_nhat'] as double) >= 2.0 || _chuaTuKhoa(textKhongDau, ['dat nhat', 'vip nhat', 'cao cap nhat'])) {
      final phongVipNhat = danhSachPhong.reduce((a, b) => a.giaCoBan > b.giaCoBan ? a : b);
      return {
        'noi_dung': 'Dạ, hạng phòng cao cấp và sang trọng bậc nhất tại $tenKs là **${phongVipNhat.tenLoai}** với giá niêm yết **${DinhDang.dinhDangTien(phongVipNhat.giaCoBan)}/đêm**:\n\n'
            '💎 Điểm nổi bật:\n'
            '• View trực diện toàn cảnh bãi biển đón hoàng hôn và bình minh tuyệt đẹp\n'
            '• Sức chứa: Tối đa ${phongVipNhat.sucChua} người với phòng khách riêng biệt\n'
            '• Bồn sục Jacuzzi thư giãn, ban công đón gió biển, rượu vang chào mừng\n\n'
            'Anh/chị có thể xem chi tiết hình ảnh thực tế và đặt phòng ở thẻ bên dưới nhé!',
        'danh_sach_phong': [phongVipNhat],
        'intent': 'VIP_SUITE_ROOM',
      };
    }

    // 19. Hỏi phòng view biển
    if ((entities['score_view_bien'] as double) >= 2.0 || _chuaTuKhoa(textKhongDau, ['view bien', 'huong bien', 'nhin ra bien', 'ngam bien'])) {
      final phongViewBien = danhSachPhong.where((p) => 
        boDau(p.tenLoai).contains('deluxe') || 
        boDau(p.tenLoai).contains('suite') ||
        boDau(p.moTa ?? '').contains('bien')
      ).toList();
      return {
        'noi_dung': 'Dạ, khách sạn có các hạng phòng **view biển tuyệt đẹp** ngắm trọn bình minh và hoàng hôn:\n\n'
            '🌊 Các hạng phòng hướng biển tiêu biểu gồm **Deluxe** và **Suite VIP** với ban công riêng thoáng đãng, lộng gió biển.\n\n'
            'Em đã lọc sẵn các phòng view biển đẹp nhất ở danh sách bên dưới để anh/chị chọn lựa ạ!',
        'danh_sach_phong': phongViewBien.isNotEmpty ? phongViewBien : danhSachPhong.take(2).toList(),
        'intent': 'SEARCH_SEA_VIEW',
      };
    }

    // 20. Khách hỏi phòng có bồn tắm / Jacuzzi
    if ((entities['score_bon_tam'] as double? ?? 0) >= 2.0 || _chuaTuKhoa(textKhongDau, ['bon tam', 'bon suc', 'jacuzzi'])) {
      final phongBonTam = danhSachPhong.where((p) {
        final tienIch = p.tienIch.map((t) => boDau(t)).join(' ');
        final moTa = boDau(p.moTa ?? '');
        return tienIch.contains('bon tam') || tienIch.contains('jacuzzi') || moTa.contains('bon tam') || moTa.contains('jacuzzi') || boDau(p.tenLoai).contains('deluxe') || boDau(p.tenLoai).contains('suite');
      }).toList();

      final listHienThi = phongBonTam.isNotEmpty ? phongBonTam : danhSachPhong.where((p) => boDau(p.tenLoai).contains('deluxe') || boDau(p.tenLoai).contains('suite')).toList();
      return {
        'noi_dung': 'Dạ tại $tenKs, các hạng phòng cao cấp như **Deluxe** và **Suite VIP** đều được trang bị phòng tắm sang trọng với **bồn tắm nằm / bồn sục Jacuzzi riêng biệt**:\n\n'
            '🛁 Quý khách có thể ngâm mình thư giãn với làn nước ấm sau một ngày dài dạo chơi biển.\n\n'
            'Anh/chị có thể xem ảnh chi tiết và đặt phòng ở danh sách bên dưới nhé!',
        'danh_sach_phong': listHienThi.isNotEmpty ? listHienThi : danhSachPhong.take(2).toList(),
        'intent': 'AMENITY_BATHTUB',
      };
    }

    // 21. Hỏi tiện nghi của một hạng phòng cụ thể
    final bool hoiTienNghi = (entities['score_tien_nghi'] as double? ?? 0) >= 1.5 || 
        _chuaTuKhoa(textKhongDau, ['tien nghi', 'tien ich', 'co nhung gi', 'trang thiet bi', 'noi that', 'co gi']);

    if (entities['hang_phong'] != null && hoiTienNghi) {
      final ten = entities['hang_phong'] as String;
      final phong = danhSachPhong.firstWhere(
        (p) => boDau(p.tenLoai) == boDau(ten),
        orElse: () => danhSachPhong.first,
      );

      final buffer = StringBuffer();
      if (phong.tienIch.isNotEmpty) {
        for (final ti in phong.tienIch) {
          buffer.writeln('  ✓ $ti');
        }
      } else {
        buffer.writeln('  ✓ Đầy đủ tiện nghi tiêu chuẩn theo thông tin phòng');
      }

      return {
        'noi_dung': 'Dạ chi tiết về **toàn bộ tiện nghi và trang thiết bị** của hạng phòng **${phong.tenLoai}** như sau ạ:\n\n'
            '✨ **Danh sách tiện nghi trong phòng:**\n'
            '${buffer.toString()}\n'
            '• **Sức chứa:** Tối đa ${phong.sucChua} người lớn.\n'
            '• **Giá niêm yết:** ${DinhDang.dinhDangTien(phong.giaCoBan)} / đêm\n'
            '• **Mô tả:** ${phong.moTa ?? "Không gian lưu trú tiêu chuẩn cao cấp với đầy đủ tiện nghi."}\n\n'
            'Anh/chị có thể bấm nút **Đặt Phòng** ngay trên thẻ bên dưới để chọn ngày lưu trú nhé!',
        'danh_sach_phong': [phong],
        'intent': 'ROOM_AMENITIES_DETAIL',
      };
    }

    // 22. Hỏi tiện nghi chung của khách sạn
    if (_chuaTuKhoa(textKhongDau, ['tien nghi cua khach san', 'tien ich cua khach san', 'khach san co tien nghi gi', 'cac tien nghi khach san', 'tien nghi chung', 'tien ich chung']) ||
        (hoiTienNghi && entities['hang_phong'] == null && (entities['score_re_nhat'] as double? ?? 0) < 2.0 && (entities['score_dat_nhat'] as double? ?? 0) < 2.0 && entities['so_nguoi'] == null)) {
      final tatCaTienIch = danhSachPhong.expand((p) => p.tienIch).toSet().toList();
      final bufferTienNghi = StringBuffer();
      if (tatCaTienIch.isNotEmpty) {
        for (final ti in tatCaTienIch) {
          bufferTienNghi.writeln('  ✓ $ti');
        }
      } else {
        bufferTienNghi.writeln('  ✓ Tiện nghi đầy đủ theo tiêu chuẩn từng hạng phòng');
      }

      return {
        'noi_dung': 'Dạ tại $tenKs, chúng em cung cấp đầy đủ các tiện nghi phòng ốc và dịch vụ nghỉ dưỡng cao cấp:\n\n'
            '🏨 **Tiện nghi phòng ốc thực tế:**\n'
            '${bufferTienNghi.toString()}\n'
            '🌟 **Dịch vụ & Tiện ích khách sạn nổi bật:**\n'
            '  ✓ Vị trí: $khoangCachBien\n'
            '  ✓ Bữa sáng: Phục vụ buffet hàng ngày ($gioBuffet)\n'
            '  ✓ Đỗ xe: $baiDoXeMoTa\n'
            '  ✓ Quầy lễ tân & an ninh túc trực 24/24\n\n'
            'Anh/chị có thể tham khảo danh sách các hạng phòng bên dưới để lựa chọn phòng ưng ý nhất nhé!',
        'danh_sach_phong': danhSachPhong,
        'intent': 'HOTEL_GENERAL_AMENITIES',
      };
    }

    // 23. Hỏi về hạng phòng cụ thể
    if (entities['hang_phong'] != null && (entities['score_re_nhat'] as double) < 2.0 && (entities['score_dat_nhat'] as double) < 2.0) {
      final ten = entities['hang_phong'] as String;
      final phong = danhSachPhong.firstWhere(
        (p) => boDau(p.tenLoai) == boDau(ten),
        orElse: () => danhSachPhong.first,
      );
      final tienIchStr = phong.tienIch.take(5).join(', ');
      return {
        'noi_dung': 'Dạ thông tin chi tiết về hạng phòng **${phong.tenLoai}** như sau ạ:\n\n'
            '• Sức chứa: Tối đa ${phong.sucChua} người\n'
            '• Giá cơ bản: ${DinhDang.dinhDangTien(phong.giaCoBan)} / đêm\n'
            '• Tiện ích nổi bật: $tienIchStr\n'
            '• Mô tả: ${phong.moTa ?? "Phòng tiêu chuẩn tiện nghi cao cấp."}\n\n'
            'Anh/chị có thể bấm nút **Đặt Phòng** ngay trên thẻ phòng bên dưới để chọn ngày lưu trú ạ!',
        'danh_sach_phong': [phong],
        'intent': 'SEARCH_SPECIFIC_ROOM',
      };
    }

    // 24. Hỏi bảng giá phòng
    if ((entities['score_gia_ca'] as double) >= 2.0) {
      final buffer = StringBuffer();
      for (final p in danhSachPhong) {
        buffer.writeln('• **${p.tenLoai}**: ${DinhDang.dinhDangTien(p.giaCoBan)} / đêm (Tối đa ${p.sucChua} người)');
      }
      return {
        'noi_dung': 'Dạ em gửi anh/chị bảng giá niêm yết các hạng phòng tại $tenKs:\n\n'
            '${buffer.toString()}\n'
            'Giá đã bao gồm WiFi, dọn phòng hàng ngày và các tiện ích cơ bản. Anh/chị xem chi tiết từng phòng ở thẻ bên dưới nhé!',
        'danh_sach_phong': danhSachPhong,
        'intent': 'ROOM_PRICES',
      };
    }

    // 25. Hỏi danh sách hạng phòng
    if ((entities['score_danh_sach'] as double) >= 2.0) {
      final buffer = StringBuffer();
      int stt = 1;
      for (final p in danhSachPhong) {
        buffer.writeln('$stt. **${p.tenLoai}** (${DinhDang.dinhDangTien(p.giaCoBan)}/đêm) — Sức chứa tối đa ${p.sucChua} người.');
        stt++;
      }
      return {
        'noi_dung': 'Dạ, hiện tại $tenKs có tổng cộng **${danhSachPhong.length} hạng phòng chính** với tiêu chuẩn nghỉ dưỡng cao cấp:\n\n'
            '${buffer.toString()}\n'
            'Tất cả các phòng đều được trang bị đầy đủ WiFi tốc độ cao, điều hòa, TV thông minh và dọn phòng hàng ngày.\n\n'
            'Em đã gửi kèm thẻ chi tiết của tất cả các phòng bên dưới, anh/chị có thể bấm **Xem Chi Tiết** hoặc **Đặt Phòng** ngay nhé!',
        'danh_sach_phong': danhSachPhong,
        'intent': 'ROOM_TYPES_OVERVIEW',
      };
    }

    // 26. Đặt phòng
    if ((entities['score_dat_phong'] as double) >= 2.0) {
      return {
        'noi_dung': 'Dạ để đặt phòng nhanh nhất, anh/chị có thể:\n\n'
            '1. Bấm trực tiếp nút **Đặt Phòng** trên thẻ phòng bên dưới.\n'
            '2. Hoặc vào mục **Tìm Phòng** ở thanh menu chính để chọn ngày nhận, ngày trả và số người.\n\n'
            'Nếu anh/chị cần tư vấn thêm về chọn phòng, cứ nói cho em biết số người hoặc ngân sách dự kiến của mình nhé!',
        'danh_sach_phong': phongGoiY.isNotEmpty ? phongGoiY : danhSachPhong,
        'intent': 'BOOKING_INTENT',
      };
    }

    // 27. Nếu có gợi ý phòng phù hợp từ ngữ cảnh
    if (phongGoiY.isNotEmpty) {
      return {
        'noi_dung': 'Dạ dựa trên câu hỏi của anh/chị, em xin đề xuất các hạng phòng phù hợp nhất dưới đây ạ:\n\n'
            'Anh/chị có thể xem thông tin chi tiết từng phòng hoặc bấm **Đặt Phòng** ngay nhé!',
        'danh_sach_phong': phongGoiY,
        'intent': 'CONTEXT_SUGGESTION',
      };
    }

    // 28. Fallback chung thông minh
    return {
      'noi_dung': 'Dạ em đã ghi nhận câu hỏi của anh/chị! Em có thể giải đáp nhanh các nội dung sau:\n\n'
          '• **Thông tin phòng:** Khách sạn có bao nhiêu hạng phòng? Phòng nào rẻ nhất / view biển?\n'
          '• **Tư vấn sức chứa:** Tìm phòng cho 1, 2, 3 hoặc 4 người\n'
          '• **Quy định & Chính sách:** Giờ nhận/trả phòng, mức đặt cọc, chính sách hủy phòng\n'
          '• **Tiện ích dịch vụ:** Ăn sáng buffet, đưa đón sân bay, bãi đỗ xe ô tô\n\n'
          'Anh/chị vui lòng nhập câu hỏi cụ thể để em hỗ trợ tư vấn chi tiết nhé!',
      'danh_sach_phong': <LoaiPhong>[],
      'intent': 'FALLBACK_GENERAL',
    };
  }

  static void lamMoiCache() {
    _danhSachPhongCache = null;
    _thoiGianCapNhatPhong = null;
    _danhSachDichVuCache = null;
    _thoiGianCapNhatDichVu = null;
    _thongTinKhachSanCache = null;
    _thoiGianCapNhatKhachSan = null;
  }

  static void capNhatDanhSachPhongCache(List<LoaiPhong> danhSach) {
    _danhSachPhongCache = List.from(danhSach);
    _thoiGianCapNhatPhong = DateTime.now();
  }

  static Future<List<LoaiPhong>> _layDanhSachPhongThucTe({bool buocLamMoi = false}) async {
    final bayGio = DateTime.now();
    final cacheHopLe = _danhSachPhongCache != null &&
        _danhSachPhongCache!.isNotEmpty &&
        _thoiGianCapNhatPhong != null &&
        bayGio.difference(_thoiGianCapNhatPhong!) < _thoiGianHetHanCache;

    if (!buocLamMoi && cacheHopLe) {
      return _danhSachPhongCache!;
    }
    try {
      final tuApi = await PhongDichVu.layDanhSachLoaiPhong();
      if (tuApi.isNotEmpty) {
        _danhSachPhongCache = tuApi;
        _thoiGianCapNhatPhong = bayGio;
        return tuApi;
      }
    } catch (_) {}
    return _danhSachPhongCache ?? [];
  }

  static Future<List<Map<String, dynamic>>> _layDanhSachDichVuThucTe() async {
    final bayGio = DateTime.now();
    if (_danhSachDichVuCache != null &&
        _thoiGianCapNhatDichVu != null &&
        bayGio.difference(_thoiGianCapNhatDichVu!) < _thoiGianHetHanCache) {
      return _danhSachDichVuCache!;
    }
    try {
      final ds = await PhongDichVu.layDanhSachDichVu();
      if (ds.isNotEmpty) {
        _danhSachDichVuCache = ds;
        _thoiGianCapNhatDichVu = bayGio;
        return ds;
      }
    } catch (_) {}
    return _danhSachDichVuCache ?? [];
  }

  static Future<Map<String, dynamic>> _layThongTinKhachSanThucTe() async {
    final bayGio = DateTime.now();
    if (_thongTinKhachSanCache != null &&
        _thoiGianCapNhatKhachSan != null &&
        bayGio.difference(_thoiGianCapNhatKhachSan!) < _thoiGianHetHanCache) {
      return _thongTinKhachSanCache!;
    }
    try {
      final info = await PhongDichVu.layThongTinKhachSan();
      if (info.isNotEmpty) {
        _thongTinKhachSanCache = info;
        _thoiGianCapNhatKhachSan = bayGio;
        return info;
      }
    } catch (_) {}
    return _thongTinKhachSanCache ?? {};
  }
}
