import '../mo_hinh/loai_phong.dart';
import 'api_dich_vu.dart';
import 'tro_ly_ai_engine.dart';

/// Dịch vụ Trợ lý AI Đa Chế Độ (Hybrid Dual-Engine AI Architecture)
/// - Ưu tiên 1 (Online): Gửi tin nhắn lên API Cloud (Google Gemini / LLM Backend) để phân tích ngôn ngữ tự nhiên sâu.
///   (API Key được cấu hình trực tiếp trên máy chủ qua file .env)
/// - Dự phòng 2 (Offline / Fallback): Khi không có API, mất mạng hoặc lỗi server, tự động kích hoạt On-Device Local Engine nội bộ chạy 100% bằng Dart.
class BotAiDichVu {
  /// Gửi tin nhắn với cơ chế Hybrid Dual-Engine
  static Future<Map<String, dynamic>> guiTinNhan({
    required String noiDungTinNhan,
    List<Map<String, dynamic>> lichSuTroChuyen = const [],
  }) async {
    // =================================================================
    // LOGIC 1: ƯU TIÊN GỌI API BACKEND (GEMINI CLOUD LLM)
    // =================================================================
    try {
      final body = <String, dynamic>{
        'tin_nhan': noiDungTinNhan,
        'lich_su': lichSuTroChuyen,
      };

      final phanHoiApi = await ApiDichVu.guiDuLieu('chat-bot', body)
          .timeout(const Duration(seconds: 8));

      if (phanHoiApi != null &&
          phanHoiApi is Map<String, dynamic> &&
          phanHoiApi['success'] == true &&
          phanHoiApi['noi_dung'] != null) {
        
        List<LoaiPhong> danhSachPhong = [];
        if (phanHoiApi['danh_sach_phong'] is List) {
          danhSachPhong = (phanHoiApi['danh_sach_phong'] as List)
              .map((e) => e is LoaiPhong ? e : LoaiPhong.tuJson(e as Map<String, dynamic>))
              .toList();
        }

        return {
          'noi_dung': phanHoiApi['noi_dung'].toString(),
          'danh_sach_phong': danhSachPhong,
          'thong_tin_dat_phong': phanHoiApi['thong_tin_dat_phong'],
          'intent': phanHoiApi['intent'] ?? 'API_GEMINI',
          'nguon': 'API',
        };
      }
    } catch (_) {
      // Khi không có kết nối API, hết quota, timeout hoặc chưa cấu hình API -> Tự động chuyển sang Logic 2
    }

    // =================================================================
    // LOGIC 2: SỬ DỤNG ON-DEVICE LOCAL ENGINE (DỰ PHÒNG KHI KHÔNG CÓ API)
    // =================================================================
    try {
      final ketQua = await TroLyAiEngine.xuLyTinNhan(
        noiDungTinNhan,
        lichSu: lichSuTroChuyen,
      );

      final List<LoaiPhong> danhSachPhong = (ketQua['danh_sach_phong'] is List)
          ? (ketQua['danh_sach_phong'] as List<LoaiPhong>)
          : <LoaiPhong>[];

      return {
        'noi_dung': ketQua['noi_dung'] ?? 'Dạ em đã nhận được yêu cầu của anh/chị!',
        'danh_sach_phong': danhSachPhong,
        'thong_tin_dat_phong': ketQua['thong_tin_dat_phong'],
        'intent': ketQua['intent'],
        'nguon': 'LOCAL',
      };
    } catch (e) {
      return {
        'noi_dung': 'Dạ em chào anh/chị! Hiện tại em có thể hỗ trợ tư vấn số người, bảng giá, phòng view biển và chính sách nhận/trả phòng của khách sạn ạ!',
        'danh_sach_phong': <LoaiPhong>[],
        'thong_tin_dat_phong': null,
        'nguon': 'LOCAL',
      };
    }
  }
}
