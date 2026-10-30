import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Dịch vụ quản lý thông báo nội bộ (Local Notifications - Mục 5.d Báo cáo đồ án)
class ThongBaoDichVu {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _daKhoiTao = false;

  /// Khởi tạo cấu hình thông báo cho ứng dụng
  static Future<void> khoiTao() async {
    if (_daKhoiTao) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Có thể điều hướng đến màn hình chi tiết khi bấm vào thông báo
      },
    );

    // Yêu cầu cấp quyền trên Android 13+
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    _daKhoiTao = true;
  }

  /// Hiển thị thông báo tức thì lên thanh trạng thái điện thoại
  static Future<void> hienThiThongBao({
    required String tieuDe,
    required String noiDung,
    int id = 1,
    String? payload,
  }) async {
    if (!_daKhoiTao) await khoiTao();

    const androidDetails = AndroidNotificationDetails(
      'hotel_booking_channel',
      'Thông Báo Khách Sạn',
      channelDescription: 'Thông báo đặt phòng và dịch vụ phòng khách sạn',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id: id,
      title: tieuDe,
      body: noiDung,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  /// 1. Thông báo đặt phòng thành công
  static Future<void> thongBaoDatPhongThanhCong({
    required int idDon,
    required String tenPhong,
    required String ngayNhan,
  }) async {
    await hienThiThongBao(
      id: idDon,
      tieuDe: '🎉 Đặt Phòng Thành Công! (Mã #$idDon)',
      noiDung: 'Quý khách đã đặt $tenPhong thành công. Khách sạn hẹn đón quý khách vào $ngayNhan!',
      payload: 'dat_phong_$idDon',
    );
  }

  /// 2. Thông báo yêu cầu dịch vụ thành công
  static Future<void> thongBaoGoiDichVuThanhCong({
    required String tenDichVu,
    String? soPhong,
  }) async {
    final phongStr = (soPhong != null && soPhong.isNotEmpty) ? ' tới phòng $soPhong' : '';
    await hienThiThongBao(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      tieuDe: '🛎️ Đã Nhận Yêu Cầu Dịch Vụ',
      noiDung: 'Nhân viên đang chuẩn bị $tenDichVu và sẽ phục vụ$phongStr trong ít phút!',
      payload: 'dich_vu',
    );
  }

  /// 3. Thông báo hủy đặt phòng
  static Future<void> thongBaoHuyPhong({required int idDon}) async {
    await hienThiThongBao(
      id: idDon + 10000,
      tieuDe: 'ℹ️ Đã Hủy Đơn Đặt Phòng #$idDon',
      noiDung: 'Đơn đặt phòng #$idDon của quý khách đã được hủy thành công trên hệ thống.',
      payload: 'huy_don_$idDon',
    );
  }
}
