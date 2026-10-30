import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../cau_hinh/cau_hinh_api.dart';

class ApiDichVu {
  static const String khoaLuuTruToken = 'ma_xac_thuc_nguoi_dung';

  static Future<String?> layToken() async {
    final boNho = await SharedPreferences.getInstance();
    return boNho.getString(khoaLuuTruToken);
  }

  static Future<void> luuToken(String maXacThuc) async {
    final boNho = await SharedPreferences.getInstance();
    await boNho.setString(khoaLuuTruToken, maXacThuc);
  }

  static Future<void> xoaToken() async {
    final boNho = await SharedPreferences.getInstance();
    await boNho.remove(khoaLuuTruToken);
  }

  static Future<Map<String, String>> layTieuDe({bool canToken = false}) async {
    final tieuDe = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (canToken) {
      final maToken = await layToken();
      if (maToken != null && maToken.isNotEmpty) {
        tieuDe['Authorization'] = 'Bearer $maToken';
      }
    }
    return tieuDe;
  }

  static Future<dynamic> layDuLieu(
    String duongDan, {
    Map<String, dynamic>? thamSo,
    bool canToken = false,
  }) async {
    var uri = Uri.parse('${CauHinhApi.duongDanApi}/$duongDan');
    if (thamSo != null && thamSo.isNotEmpty) {
      final thamSoChuoi = thamSo.map((khoa, giaTri) => MapEntry(khoa, giaTri.toString()));
      uri = uri.replace(queryParameters: thamSoChuoi);
    }

    final tieuDe = await layTieuDe(canToken: canToken);
    final phanHoi = await http.get(uri, headers: tieuDe);
    return _xuLyPhanHoi(phanHoi);
  }

  static Future<dynamic> guiDuLieu(
    String duongDan,
    dynamic duLieu, {
    bool canToken = false,
  }) async {
    final uri = Uri.parse('${CauHinhApi.duongDanApi}/$duongDan');
    final tieuDe = await layTieuDe(canToken: canToken);
    final phanHoi = await http.post(
      uri,
      headers: tieuDe,
      body: jsonEncode(duLieu),
    );
    return _xuLyPhanHoi(phanHoi);
  }

  static Future<dynamic> putDuLieu(
    String duongDan,
    dynamic duLieu, {
    bool canToken = false,
  }) async {
    final uri = Uri.parse('${CauHinhApi.duongDanApi}/$duongDan');
    final tieuDe = await layTieuDe(canToken: canToken);
    final phanHoi = await http.put(
      uri,
      headers: tieuDe,
      body: jsonEncode(duLieu),
    );
    return _xuLyPhanHoi(phanHoi);
  }

  static Future<dynamic> xoaDuLieu(
    String duongDan, {
    bool canToken = false,
  }) async {
    final uri = Uri.parse('${CauHinhApi.duongDanApi}/$duongDan');
    final tieuDe = await layTieuDe(canToken: canToken);
    final phanHoi = await http.delete(uri, headers: tieuDe);
    return _xuLyPhanHoi(phanHoi);
  }

  static dynamic _xuLyPhanHoi(http.Response phanHoi) {
    final maTrangThai = phanHoi.statusCode;
    dynamic ketQuaGiaiMa;

    try {
      ketQuaGiaiMa = jsonDecode(utf8.decode(phanHoi.bodyBytes));
    } catch (_) {
      ketQuaGiaiMa = null;
    }

    if (maTrangThai >= 200 && maTrangThai < 300) {
      return ketQuaGiaiMa;
    } else {
      String thongBaoLoi = 'Co loi xay ra ($maTrangThai)';
      if (ketQuaGiaiMa is Map) {
        if (ketQuaGiaiMa['message'] != null) {
          thongBaoLoi = ketQuaGiaiMa['message'].toString();
        } else if (ketQuaGiaiMa['thong_bao'] != null) {
          thongBaoLoi = ketQuaGiaiMa['thong_bao'].toString();
        } else if (ketQuaGiaiMa['error'] != null) {
          thongBaoLoi = ketQuaGiaiMa['error'].toString();
        }
      }
      throw Exception(thongBaoLoi);
    }
  }
}
