# Ứng Dụng Khách Sạn Luxury (Mobile App)

Ứng dụng di động đặt phòng và quản lý kỳ nghỉ khách sạn 5 sao cao cấp, được xây dựng bằng **Flutter (Dart)** kết nối trực tiếp với hệ thống Backend **Laravel / MySQL** (kết hợp Trợ lý AI On-Device cục bộ).

---

## 📱 Tính Năng Chính

1. **Trang Chủ (Khám Phá & Ưu Đãi):**
   * Banner quảng cáo ưu đãi nghỉ dưỡng sang trọng (`banner_quang_cao.dart`).
   * Hộp tìm kiếm nhanh ngày nhận, ngày trả và số lượng người (`khung_tim_kiem_nhanh.dart`).
   * Danh sách các hạng phòng nổi bật (`the_phong.dart`) với hình ảnh thực tế từ CSDL, tiện nghi và giá niêm yết theo đêm.

2. **Tìm Kiếm & Lọc Phòng Động:**
   * Lọc phòng theo ngày nhận phòng, ngày trả phòng (hỗ trợ chọn cả giờ & ngày) và số lượng người.
   * Kiểm tra tình trạng phòng còn trống theo thời gian thực từ API backend.
   * Tự động tính số đêm lưu trú và tổng tiền dự kiến.

3. **Chi Tiết Hạng Phòng:**
   * Thư viện hình ảnh thực tế sắc nét từ máy chủ.
   * Danh sách tiện nghi đầy đủ: WiFi tốc độ cao, Smart TV 55 inch, Điều hòa hai chiều, Bồn tắm nước nóng, Minibar...
   * Quy chuẩn sức chứa số người tối đa và chính sách lưu trú.

4. **Tạo Đơn Đặt Phòng & Lịch Sử:**
   * Đặt phòng nhanh chóng với đầy đủ thông tin khách hàng, số người và ghi chú đặc biệt.
   * Màn hình đặt phòng thành công kèm mã đơn và hướng dẫn thanh toán.
   * Theo dõi danh sách và trạng thái các đơn đặt phòng trong mục **Lịch Sử Đặt Phòng**.

5. **Trợ Lý AI Tư Vấn Thông Minh (On-Device Client-Side NLP Engine):**
   * Trợ lý ảo tư vấn phòng thông minh chạy **100% bằng thuật toán mã nguồn Dart nội bộ**, không dùng API bên thứ ba (OpenAI / Gemini).
   * Tự động nhận diện ý định, số lượng người, sở thích view biển, phân khúc cao cấp/tiết kiệm, chính sách check-in/out, đặt cọc và dịch vụ.
   * Đề xuất thẻ phòng trực quan (Carousel Card) cho phép bấm **Xem Chi Tiết** hoặc **Đặt Phòng** ngay.
   * 📄 **Báo cáo thuyết minh thuật toán dành cho Giảng viên:** Xem chi tiết tại [README_AI.md](./README_AI.md).

6. **Tài Khoản & Thông Tin Khách Sạn:**
   * Quản lý thông tin cá nhân khách hàng (đăng nhập / đăng ký qua JWT Token).
   * Tra cứu thông tin liên hệ, hotline 24/7, địa chỉ sát biển và tài khoản ngân hàng của khách sạn.

---

## 📁 Cấu Trúc Dự Án Thực Tế (`lib/`)

Toàn bộ mã nguồn được tổ chức theo kiến trúc phân tầng sạch sẽ, chuẩn hóa tên gọi file, class và biến theo quy tắc **tiếng Việt không dấu**:

```text
app_khachsan/
├── README.md                    # Hướng dẫn tổng quan ứng dụng
├── README_AI.md                 # BÁO CÁO THUYẾT MINH THUẬT TOÁN AI DÀNH CHO GIẢNG VIÊN
├── pubspec.yaml                 # Khai báo dependencies Flutter & tài nguyên
├── lib/
│   ├── main.dart                # Điểm khởi chạy ứng dụng (Entry point)
│   │
│   ├── cau_hinh/                # Cấu hình hệ thống & giao diện
│   │   ├── cau_hinh_api.dart    # Cấu hình máy chủ API (Online Production URL)
│   │   └── mau_sac_app.dart     # Bảng màu sắc thiết kế thương hiệu (Brand Colors)
│   │
│   ├── dich_vu/                 # Tầng giao tiếp API & Xử lý nghiệp vụ
│   │   ├── api_dich_vu.dart     # HTTP Client xử lý Header, Token, GET, POST, PUT, DELETE
│   │   ├── phong_dich_vu.dart   # API danh sách phòng, chi tiết phòng, tìm kiếm, thông tin KS
│   │   ├── xac_thuc_dich_vu.dart# API đăng nhập, đăng ký, đăng xuất, thông tin người dùng
│   │   ├── dat_phong_dich_vu.dart # API tạo đơn đặt phòng, lấy lịch sử đặt phòng
│   │   ├── bot_ai_dich_vu.dart  # Cầu nối gọi Trợ lý AI tư vấn
│   │   └── tro_ly_ai_engine.dart# THUẬT TOÁN AI ON-DEVICE (5 Bước: NLP + Chấm điểm phòng)
│   │
│   ├── mo_hinh/                 # Data Models (JSON Serialization)
│   │   ├── loai_phong.dart      # Model Hạng phòng, giá niêm yết, sức chứa, tiện nghi
│   │   ├── nguoi_dung.dart      # Model Tài khoản người dùng (User Profile)
│   │   ├── dat_phong.dart       # Model Đơn đặt phòng & trạng thái thanh toán
│   │   └── tin_nhan_bot.dart    # Model Tin nhắn hội thoại & thẻ phòng gợi ý của AI
│   │
│   ├── quan_ly_trang_thai/      # State Management (Provider)
│   │   ├── xac_thuc_provider.dart  # Quản lý phiên đăng nhập, thông tin User & Token
│   │   └── dat_phong_provider.dart # Quản lý dữ liệu đặt phòng, ngày nhận/trả, số người
│   │
│   ├── man_hinh/                # Giao diện người dùng (Screens & Widgets)
│   │   ├── dieu_huong_chinh.dart# Bottom Navigation Bar (4 Tab điều hướng chính)
│   │   ├── trang_chu/           # Màn hình Trang chủ
│   │   │   ├── man_hinh_trang_chu.dart
│   │   │   └── thanh_phan/
│   │   │       ├── banner_quang_cao.dart     # Banner quảng cáo ưu đãi
│   │   │       ├── khung_tim_kiem_nhanh.dart # Widget tìm phòng nhanh
│   │   │       └── the_phong.dart            # Card hiển thị phòng nghỉ
│   │   ├── tim_kiem/            # Màn hình Tra cứu & lọc phòng trống
│   │   │   └── man_hinh_tim_kiem.dart
│   │   ├── chi_tiet_phong/      # Màn hình Xem chi tiết hạng phòng
│   │   │   └── man_hinh_chi_tiet_phong.dart
│   │   ├── dat_phong/           # Màn hình Đặt phòng & Xác nhận
│   │   │   ├── man_hinh_dat_phong.dart       # Form nhập thông tin đặt phòng
│   │   │   └── man_hinh_dat_thanh_cong.dart  # Màn hình thông báo thành công
│   │   ├── tro_ly_ai/           # Màn hình Chatbot Trợ lý AI
│   │   │   └── man_hinh_tro_ly_ai.dart       # UI Chat + Carousel Cards gợi ý
│   │   ├── tai_khoan/           # Màn hình Tài khoản & Lịch sử
│   │   │   ├── man_hinh_tai_khoan.dart
│   │   │   └── man_hinh_lich_su_don.dart
│   │   └── xac_thuc/            # Màn hình Đăng nhập & Đăng ký
│   │       ├── man_hinh_dang_nhap.dart
│   │       └── man_hinh_dang_ky.dart
│   │
│   └── tien_ich/                # Các hàm tiện ích dùng chung
│       ├── dinh_dang.dart       # Định dạng tiền tệ VNĐ (₫), định dạng ngày giờ
│       └── xu_ly_ngay.dart      # Tính số đêm lưu trú, chuẩn hóa DateTime
```

---

## 🌐 CẤU HÌNH MÁY CHỦ API (ONLINE PRODUCTION)

Ứng dụng đã được cấu hình mặc định kết nối trực tiếp đến máy chủ Online tại:

👉 **File cấu hình:** `lib/cau_hinh/cau_hinh_api.dart`

```dart
class CauHinhApi {
  ...
  /// Đường dẫn máy chủ mặc định online production
  static String get duongDanGocMacDinh => 'https://vovandat.id.vn/KhachSan';
  ...
}
```

### Chuyển đổi linh hoạt môi trường:
* **Môi trường Online (Mặc định):** `https://vovandat.id.vn/KhachSan`
* **Môi trường Local (Nếu chạy backend máy cá nhân):**
  * Android Emulator: `http://10.0.2.2:8000`
  * Máy ảo iOS / Web / Thiết bị thật cùng mạng WiFi: `http://<IP_LAN_MAY_TINH>:8000`

> **Lưu ý:** Toàn bộ các API endpoint (`/api/...`) và đường dẫn hình ảnh phòng (`/storage/...`) trong toàn bộ ứng dụng đều được sinh tự động từ `duongDanGoc`, nên chỉ cần đổi 1 dòng duy nhất là ứng dụng tự động chuyển đổi toàn bộ kết nối.

---

## 🚀 Hướng Dẫn Chạy & Đóng Gói Ứng Dụng

### Yêu cầu môi trường:
* **Flutter SDK:** Phiên bản `>= 3.29.0`
* **Dart SDK:** Phiên bản `>= 3.7.0`
* **Android SDK:** API 21+ đến API 37

### 1. Cài đặt các gói thư viện (Dependencies):
```bash
flutter pub get
```

### 2. Kiểm tra chất lượng mã nguồn:
```bash
flutter analyze
```
*(Hiện tại hệ thống đạt chuẩn: **0 errors, 0 warnings**)*

### 3. Chạy ứng dụng trên thiết bị / máy ảo:
```bash
flutter run
```

### 4. Đóng gói file APK cài đặt (Release):
```bash
flutter build apk --release
```
File APK phát hành sẽ nằm tại:
`build/app/outputs/flutter-apk/app-release.apk`
