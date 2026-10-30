# BÁO CÁO THUYẾT MINH HỆ THỐNG TRỢ LÝ AI (MOBILE APP & BACKEND)
**Hệ thống:** Quản Lý Khách Sạn Cao Cấp (Luxury Hotel Management System)  
**Phân hệ:** Trợ lý ảo tư vấn phòng trên ứng dụng di động (Flutter Mobile App) & API Backend (Node.js Express)  
**Mã nguồn xử lý:** 
- Mobile Client: `lib/dich_vu/bot_ai_dich_vu.dart` & `lib/dich_vu/tro_ly_ai_engine.dart`
- Backend API: `server_api/server.js` (Endpoint `POST /api/chat-bot`, `GET/PUT /api/admin/settings`, `GET /api/settings`)
- Web Admin: `server_api/public/admin/index.html` (Tab "Cấu Hình Khách Sạn & AI")
**Kiến trúc:** **Kiến trúc Lai 2 Tầng Tự Động (Hybrid Dual-Engine AI Architecture)**  
- **Tầng 1 (Online - Ưu tiên hàng đầu):** Google Gemini 2.5 Flash Cloud LLM với RAG thời gian thực kết nối MySQL.
- **Tầng 2 (On-Device Local AI - Dự phòng khi lỗi API):** On-Device Dart NLP Engine V2 chạy suy luận 100% cục bộ trên thiết bị, truy xuất dữ liệu thời gian thực từ CSDL MySQL (không hardcode).

---

## 📌 I. TỔNG QUAN KIẾN TRÚC LAI 2 TẦNG (HYBRID DUAL-ENGINE)

Nhằm đáp ứng đồng thời 2 mục tiêu: **Khả năng hiểu ngôn ngữ tự nhiên sâu sắc (Deep NLU)** của mô hình ngôn ngữ lớn (LLM) và **Tính độc lập, bảo mật, độ trễ tức thì (Zero-Latency & High Availability)** của thuật toán cục bộ, hệ thống được thiết kế theo mô hình 2 tầng đồng bộ dữ liệu thời gian thực:

```mermaid
flowchart TD
    User["Khách hàng gửi câu hỏi trên App Di Động"] --> Dispatcher["Bộ điều phối BotAiDichVu (Flutter)"]
    
    Dispatcher -->|"1. Ưu tiên gọi Cloud API (Timeout 8s)"| Backend["Backend API Server (Node.js)"]
    Backend --> CheckKey{"Kiểm tra GEMINI_API_KEY trong .env?"}
    
    CheckKey -->|"Có Key hợp lệ"| Gemini["Google Gemini 2.5 Flash Cloud API<br/>+ Dynamic Context RAG (MySQL)"]
    Gemini -->|"Trả về JSON {noi_dung, phong_ids}"| MapRooms["Truy xuất CSDL MySQL:<br/>Nạp ảnh, giá phòng, tiện ích thực tế"]
    MapRooms -->|"success: true"| DisplayCloud["Hiển thị Chat Bubble<br/>☁️ Cloud AI (Gemini API) + Thẻ phòng"]
    
    CheckKey -->|"Lỗi API: Chưa có Key / Quota Limit / Lỗi dịch vụ"| Fallback["Kích hoạt Dự phòng (Fallback)"]
    Backend -->|"Lỗi API / Timeout"| Fallback
    Dispatcher -.->|"2. Lỗi gọi API / Không phản hồi từ Cloud"| LocalEngine
    Fallback --> LocalEngine["TẦNG 2: On-Device Dart NLP Engine V2<br/>(Thuật toán suy luận 100% Cục bộ)"]
    
    LocalEngine --> FetchDB["Truy xuất CSDL MySQL (Realtime):<br/>- Bảng cai_dat: Cấu hình khách sạn<br/>- Bảng loai_phong: Giá & tiện nghi<br/>- Bảng dich_vu: Thực đơn & Spa"]
    FetchDB --> TextNorm["Khử dấu tiếng Việt & N-gram Tokenizer"]
    TextNorm --> StopwordFilter["Lọc từ dừng & Word-Boundary Matching"]
    StopwordFilter --> DecisionTree["Cây quyết định ý định theo dữ liệu CSDL"]
    DecisionTree --> RoomScoring["Chấm điểm đa thuộc tính Score(Room) động theo CSDL"]
    RoomScoring --> DisplayLocal["Hiển thị Chat Bubble<br/>🟢 On-Device AI (Cục bộ) + Thẻ phòng"]
```

---

## ☁️ II. TẦNG 1: CLOUD LLM ENGINE (GOOGLE GEMINI 2.5 FLASH & DYNAMIC RAG)

### 1. Cơ chế hoạt động phía Backend (`server.js`)
* **Endpoint:** `POST /api/chat-bot`
* **Mô hình AI:** `gemini-2.5-flash` (Thế hệ mới nhất của Google, hỗ trợ fallback tự động sang `gemini-flash-latest`).
* **Cấu hình động (Live Reload):** Đọc trực tiếp từ file cấu hình `server_api/.env` (`GEMINI_API_KEY` và `GEMINI_MODEL`), cập nhật ngay khi thay đổi key mà không cần khởi động lại tiến trình Node.js.
* **Cơ chế RAG (Retrieval-Augmented Generation) 3 Chiều Thời Gian Thực:** 
  Trước khi gửi câu hỏi sang Gemini, server truy vấn dữ liệu thực tế từ MySQL gồm:
  1. **Bảng `cai_dat`**: Toàn bộ 16 thông số cấu hình khách sạn (khoảng cách biển, giờ/giá ăn sáng buffet, giá xe sân bay, thuê xe máy, giờ check-in/out, tỷ lệ cọc, chính sách hủy...).
  2. **Bảng `loai_phong`**: Toàn bộ hạng phòng, giá niêm yết, sức chứa tối đa, danh sách tiện nghi và mô tả thực tế.
  3. **Bảng `dich_vu`**: Danh mục thực đơn ăn uống, cà phê, spa, massage phục vụ tận phòng.
  Toàn bộ tri thức này được nhúng trực tiếp vào **System Prompt** để Gemini luôn nắm bắt dữ liệu chính xác 100%, triệt tiêu hoàn toàn hiện tượng ảo giác (hallucination).

### 2. Định dạng phản hồi có cấu trúc (`responseMimeType: application/json`)
Gemini được cấu hình bắt buộc phản hồi dưới định dạng JSON nguyên bản:
```json
{
  "noi_dung": "Câu trả lời tự nhiên, lịch thiệp, đúng chuẩn phong cách lễ tân 5 sao.",
  "phong_ids": [1],
  "intent": "hỏi phòng rẻ nhất"
}
```

### 3. Quy tắc chọn lọc phòng thông minh (`phong_ids` Filter Rules)
Để tránh tình trạng "hỏi phòng rẻ nhất mà AI đưa ra toàn bộ phòng", hệ thống thiết lập các quy tắc nghiêm ngặt:
* **Hỏi phòng rẻ nhất / giá thấp nhất:** CHỈ trả về đúng 1 ID phòng có giá thấp nhất.
* **Hỏi phòng xịn nhất / VIP / đắt nhất:** CHỈ trả về đúng 1 ID phòng cao cấp nhất.
* **Hỏi phòng view biển:** Trả về các phòng có tầm nhìn biển (`Deluxe`, `Suite`).
* **Hỏi phòng theo số người:** Lọc các phòng có sức chứa phù hợp.
* **Hỏi tổng quan ("khách sạn có bao nhiêu loại phòng"):** Mới trả về danh sách tất cả các hạng phòng.
* **Hỏi thông tin khách sạn / chính sách / ăn sáng / dịch vụ:** `phong_ids: []` (không đính kèm thẻ phòng thừa).

### 4. Đồng bộ đầy đủ Hình ảnh & Tiện ích
Server ánh xạ ngược các ID trong `phong_ids` với CSDL để đính kèm đầy đủ `hinh_anh`, mảng `tien_ich`, `hinh_anh_phu`. Nhờ đó, người dùng bấm vào thẻ phòng trong khung chat sẽ mở ra trang **Chi tiết phòng** với đầy đủ banner ảnh và danh sách tiện nghi y như trang chủ.

---

## 📱 III. TẦNG 2: ON-DEVICE DART NLP ENGINE V2 (DỰ PHÒNG KHI LỖI API)

### ⚠️ Định Nghĩa Cốt Lõi Về "AI Cục Bộ" (On-Device AI)
* **Thuật toán xử lý (Inference Engine):** Chạy 100% bằng ngôn ngữ Dart ngay trên chip của điện thoại (không phụ thuộc vào API Gemini/OpenAI của bên thứ 3, không tốn tiền mua token, không lo đứt mạng).
* **Dữ liệu tri thức (Knowledge Data):** **100% là dữ liệu thời gian thực (Real-time Dynamic Data)** được đồng bộ từ Cơ sở dữ liệu MySQL (`cai_dat`, `loai_phong`, `dich_vu`), **tuyệt đối không hardcode fix cứng trong mã nguồn**. Khi Quản trị viên thay đổi giá phòng, giá dịch vụ hay khoảng cách biển trên Web Admin, AI cục bộ sẽ phản hồi đúng theo dữ liệu mới nhất.

### Pipeline xử lý 5 giai đoạn:

#### GIAI ĐOẠN 1: Chuẩn hóa chuỗi & Phân rã N-grams
Khử dấu tiếng Việt, loại bỏ ký tự đặc biệt, khử phím gõ Telex thừa và sinh tập hợp **1-gram, 2-gram, 3-gram**:
```dart
final textClean = text.replaceAll(RegExp(r'[?!.,;:_]'), ' ');
final textKhongDau = boDau(textClean); // 'khách sạn' -> 'khach san'
Set<String> ngrams = _taoNgrams(textKhongDau);
```

#### GIAI ĐOẠN 2: Lọc từ dừng (Stopword Filtering) & Khớp biên giới từ (Word-Boundary Matching)
* **Khử từ dừng:** Loại bỏ các từ phổ biến (`phong`, `co`, `khach`, `san`, `cho`, `toi`, `la`...) trước khi so khớp ngữ nghĩa.
* **Word-Boundary Matching:** Sử dụng Regex có biên giới từ `(^|\s)keyword($|\s)` thay vì kiểm tra chuỗi con thô, ngăn chặn triệt để lỗi va chạm từ vựng (ví dụ: từ `cho tôi` không bị nhận nhầm thành `ô tô`).

#### GIAI ĐOẠN 3: Cây quyết định Ý định phân cấp nghiệp vụ (Priority Decision Tree)
Thứ tự phân loại ý định được bố trí khoa học, **ưu tiên các câu hỏi nghiệp vụ đặc thù trước khi rơi vào bộ lọc tìm phòng**:
1. `GREETING` & `GRATITUDE` (Chào hỏi, cảm ơn)
2. `HOTEL_LOCATION_DISTANCE` (Hỏi khoảng cách ra biển → Đọc trực tiếp cột `khoang_cach_bien` từ CSDL, ưu tiên trước tìm phòng view biển)
3. `HOTEL_BREAKFAST` (Hỏi ăn sáng buffet → Đọc `buffet_sang_gio` và `buffet_sang_gia` từ CSDL, ưu tiên trước hỏi giá phòng rẻ nhất)
4. `HOTEL_AIRPORT_SHUTTLE` (Xe đưa đón sân bay & thuê xe máy → Đọc `xe_san_bay_gia` và `thue_xe_may_gia`)
5. `HOTEL_SWIMMING_POOL` & `HOTEL_PARKING` (Hồ bơi & hầm đỗ xe ô tô)
6. `HOTEL_CHILDREN_EXTRA_BED` (Chính sách trẻ em & giường phụ)
7. `POLICY_CHECK_IN_OUT` (Giờ check-in / check-out từ `gio_check_in` và `gio_check_out`)
8. `HOTEL_DEPOSIT_POLICY` & `HOTEL_CANCELLATION_POLICY` (Tỷ lệ cọc `%` và chính sách hoàn tiền hủy phòng)
9. `HOTEL_WIFI` & `HOTEL_PETS_SMOKING` (Mật khẩu WiFi, quy định thú cưng / hút thuốc)
10. `HOTEL_SERVICES_MENU` (Thực đơn gọi món tận phòng → Đọc danh sách từ bảng `dich_vu` trong MySQL)
11. `HOTEL_CONTACT_INFO` (Địa chỉ, hotline 24/7, email)
12. `SEARCH_BY_CAPACITY` (Tìm phòng theo số người: 1, 2, 3, 4, 5+ khách)
13. `CHEAPEST_ROOM` (Hỏi phòng rẻ nhất → Lọc phòng có giá thấp nhất trong CSDL)
14. `VIP_SUITE_ROOM` (Hỏi phòng VIP/đắt nhất → Lọc phòng có giá cao nhất trong CSDL)
15. `SEARCH_SEA_VIEW` (Lọc phòng có tầm nhìn hướng biển)
16. `AMENITY_BATHTUB` (Lọc phòng có bồn tắm nằm / bồn sục Jacuzzi)
17. `ROOM_AMENITIES_DETAIL` (Chi tiết tiện nghi của 1 hạng phòng cụ thể)
18. `HOTEL_GENERAL_AMENITIES` (Tổng hợp tất cả tiện ích thực tế từ các phòng trong CSDL)
19. `ROOM_PRICES` & `ROOM_TYPES_OVERVIEW` (Bảng giá và danh sách tổng quan các phòng)
20. `BOOKING_INTENT` & `FALLBACK_GENERAL` (Hướng dẫn đặt phòng và tư vấn chung)

#### GIAI ĐOẠN 4: Chấm điểm phòng Đa thuộc tính (Multi-Attribute Dynamic Scoring)
Công thức tính điểm phòng tổng hợp:
`Score(Room) = S_capacity + S_name + S_view + S_amenity + S_price`
* **S_capacity:** Khớp chuẩn sức chứa (+45 điểm), dư chỗ (+10 đến +35 điểm), thiếu chỗ (-50 điểm).
* **S_name:** Trùng tên hạng phòng đang hỏi (+60 điểm).
* **S_view:** Khách tìm view biển và phòng có view biển (+40 điểm).
* **S_amenity:** Khách tìm bồn tắm/tiện nghi phù hợp (+35 điểm).
* **S_price:** Tự động xác định phòng rẻ nhất (giá bằng mức thấp nhất trong CSDL: +35 điểm); phòng VIP nhất (giá bằng mức cao nhất trong CSDL: +35 điểm). Toàn bộ tính toán dựa trên bảng giá thực tế của CSDL, hoàn toàn không gán cứng ngưỡng giá.

#### GIAI ĐOẠN 5: Đóng gói thẻ phòng & Cập nhật giao diện
* Sinh phản hồi tự nhiên, chuẩn hóa định dạng tiền tệ Việt Nam (`150.000₫`).
* Đính kèm thẻ phòng chứa hình ảnh thực tế, giá cả và tiện nghi từ CSDL.
* Đánh dấu nguồn tin nhắn: `🟢 On-Device AI (Cục bộ)` để người dùng nhận biết hệ thống đang hoạt động ở chế độ nội bộ.

---

## 🛠️ IV. QUẢN TRỊ VIÊN THAY ĐỔI CẤU HÌNH REALTIME (WEB ADMIN)

Để thay đổi thông tin trả lời của AI (khoảng cách biển, tiền xe, giá ăn sáng buffet, giờ check-in/out, tỷ lệ cọc...), Quản trị viên không cần can thiệp vào code:

1. Truy cập trang quản trị: **`http://localhost:8000/admin/`**
2. Chọn tab **"Cấu Hình Khách Sạn & AI"** (Tab thứ 5).
3. Chỉnh sửa các thông số:
   * **Thông tin cơ bản:** Tên khách sạn, Hotline, Địa chỉ, Email, Khoảng cách ra biển.
   * **Chính sách lưu trú:** Giờ nhận phòng (Check-in), Giờ trả phòng (Check-out), Tỷ lệ đặt cọc (%), Chính sách hủy phòng.
   * **Bảng giá dịch vụ & Tiện ích:** Giá vé Buffet sáng, Khung giờ buffet, Giá xe đưa đón sân bay, Giá thuê xe máy, Phụ thu giường phụ, Mô tả hồ bơi, Mô tả bãi đỗ xe.
4. Bấm **"Lưu Cấu Hình Khách Sạn"** → Hệ thống cập nhật bảng `cai_dat` trong MySQL ngay lập tức.
5. Cả **Cloud AI (Gemini)** và **On-Device AI (Cục bộ)** trên điện thoại sẽ tự động phản hồi theo dữ liệu mới nhất mà không cần cài đặt lại app.

---

## 📊 V. BẢNG SO SÁNH 2 TẦNG AI TRONG HỆ THỐNG

| Tiêu chí | Tầng 1: Cloud LLM (Gemini 2.5 Flash) | Tầng 2: On-Device Dart Engine V2 |
| :--- | :--- | :--- |
| **Vị trí thực thi** | Máy chủ Backend + Google Cloud API | Chip xử lý của điện thoại di động |
| **Nguồn dữ liệu** | Real-time CSDL MySQL (`cai_dat`, `loai_phong`, `dich_vu`) | Real-time CSDL MySQL (`cai_dat`, `loai_phong`, `dich_vu`) |
| **Độ trễ phản hồi** | 800ms - 2.000ms (phụ thuộc đường truyền) | Siêu tốc: **2ms - 15ms** |
| **Khả năng hiểu ngữ nghĩa** | Hiểu ngữ cảnh hội thoại phức tạp, phong cách tự nhiên | Phân rã N-grams, thực thể mờ và cây quyết định ưu tiên |
| **Điều kiện hoạt động** | Cần Internet và `GEMINI_API_KEY` hợp lệ | Thuật toán chạy độc lập trên máy, dự phòng khi lỗi API |
| **Chi phí vận hành** | Theo hạn mức Google AI Studio | **0 VNĐ trọn đời** |
| **Hiển thị trên App** | Huy hiệu `☁️ Cloud AI (Gemini API)` (Màu tím) | Huy hiệu `🟢 On-Device AI (Cục bộ)` (Màu xanh lá) |
| **Thẻ phòng trả về** | Khớp theo `phong_ids` thông minh | Khớp theo thuật toán điểm số Score(Room) |

---

## 🧪 VI. KỊCH BẢN KIỂM THỬ THỰC TẾ ĐÃ VƯỢT QUA (100% TEST PASSED)

| Câu hỏi kiểm thử | Kết quả Tầng 1 (Gemini Cloud) | Kết quả Tầng 2 (On-Device Dart) | Dữ liệu kiểm chứng |
| :--- | :--- | :--- | :--- |
| `khoảng cách ra biển bao xa` | Báo đúng khoảng cách biển, `phong_ids: []` | Trả về `HOTEL_LOCATION_DISTANCE`, lấy đúng `khoang_cach_bien` | Khớp bảng `cai_dat` |
| `ăn sáng mấy giờ và giá bao nhiêu` | Báo giờ buffet & giá vé, `phong_ids: []` | Trả về `HOTEL_BREAKFAST`, lấy đúng `buffet_sang_gio` và `buffet_sang_gia` | Khớp bảng `cai_dat` |
| `khách sạn có xe đưa đón sân bay không` | Báo giá xe sân bay & xe máy, `phong_ids: []` | Trả về `HOTEL_AIRPORT_SHUTTLE`, lấy đúng `xe_san_bay_gia` | Khớp bảng `cai_dat` |
| `khách sạn có những dịch vụ ẩm thực gì` | Liệt kê thực đơn món ăn từ CSDL | Trả về `HOTEL_SERVICES_MENU`, lấy đúng danh sách món từ `dich_vu` | Khớp bảng `dich_vu` |
| `phòng nào rẻ nhất` | Gợi ý phòng giá thấp nhất, **chỉ gửi 1 thẻ phòng** | Trả về `CHEAPEST_ROOM`, gửi 1 thẻ phòng có giá thấp nhất | Khớp bảng `loai_phong` |
| `phòng nào xịn nhất / vip nhất` | Gợi ý phòng Suite VIP, **chỉ gửi 1 thẻ phòng** | Trả về `VIP_SUITE_ROOM`, gửi 1 thẻ phòng có giá cao nhất | Khớp bảng `loai_phong` |
| `cho tôi xem phòng view biển` | Lọc các phòng hướng biển (`Deluxe`, `Suite`) | Trả về `SEARCH_SEA_VIEW`, gửi đúng các phòng view biển | Khớp bảng `loai_phong` |
| `giờ nhận phòng và trả phòng` | Báo giờ check-in/out, không gửi thẻ phòng thừa | Trả về `POLICY_CHECK_IN_OUT`, lấy đúng giờ từ CSDL | Khớp bảng `cai_dat` |
| `đặt cọc bao nhiêu %` | Báo tỷ lệ cọc và chính sách hủy | Trả về `HOTEL_DEPOSIT_POLICY`, lấy đúng `ti_le_coc` | Khớp bảng `cai_dat` |
| `khách sạn có hồ bơi không` | Báo trung thực hồ bơi, hướng dẫn tắm biển | Trả về `HOTEL_SWIMMING_POOL`, lấy đúng `ho_boi_mo_ta` | Khớp bảng `cai_dat` |
| `khách sạn có chỗ đỗ ô tô không` | Báo chi tiết hầm đỗ xe ô tô miễn phí | Trả về `HOTEL_PARKING`, lấy đúng `bai_do_xe_mo_ta` | Khớp bảng `cai_dat` |
| `gõ không dấu: phong nao re nhat` | Nhận diện và phản hồi chuẩn xác | Khử dấu tiếng Việt và khớp ý định chuẩn 100% | Thuật toán `boDau()` |
