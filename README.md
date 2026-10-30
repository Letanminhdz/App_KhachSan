# 🏨 Ứng Dụng Di Động Đặt Phòng Khách Sạn (Flutter App & Backend API)

Dự án ứng dụng di động đặt phòng khách sạn hoàn chỉnh gồm **Mobile App (Flutter)** và **Backend API Server (Node.js Express & MySQL)**.

---

## 📁 Cấu trúc thư mục dự án

```text
QL_KhachSanAPP/
├── app_khachsan/          # Mã nguồn ứng dụng di động Flutter (Luxury UI, Provider, Local AI)
│   ├── README.md          # Tài liệu chi tiết tính năng, thư viện & câu hỏi bảo vệ đồ án
│   └── README_AI.md       # Báo cáo thuyết minh chuyên sâu thuật toán AI On-Device
├── server_api/            # Máy chủ Backend API (Node.js + Express)
│   ├── Dockerfile         # Image Docker cho API Server
│   ├── server.js          # Điểm khởi động server & xử lý API
│   ├── db.js              # Kết nối MySQL Connection Pool
│   └── package.json       # Thư viện Node.js
├── docker-compose.yml     # Khởi chạy MySQL + API cùng lúc bằng 1 lệnh
├── database.sql           # File CSDL MySQL (tự động import khi dùng Docker)
└── README.md              # Tài liệu hướng dẫn cài đặt & vận hành hệ sinh thái
```

---

## 🛠 Yêu cầu môi trường

- **Flutter SDK**: >= 3.13.x
- **Docker** & **Docker Compose**: (để chạy API + CSDL tự động)
  - Nếu không dùng Docker: cần **Node.js >= 18.x** và **MySQL 8.0**

---

## 🐳 Cách 1: Khởi chạy bằng Docker (Khuyên dùng — Nhanh nhất, 1 lệnh)

> Không cần cài Node.js hay MySQL thủ công. Docker sẽ tự động tải về và cấu hình toàn bộ.

### Bước 1: Khởi động MySQL + API Server

Mở Terminal tại thư mục gốc của dự án (`QL_KhachSanAPP/`) và chạy:

```bash
docker compose up -d
```

Docker sẽ tự động:
- Tải image **MySQL 8.0** và **Node.js 20 Alpine**
- Tạo database `ql_khachsan` và **import toàn bộ dữ liệu mẫu** từ `database.sql`
- Chờ MySQL sẵn sàng xong mới khởi động API Server (health check tự động)
- Expose **API tại `http://localhost:8000`**
- Trang **Quản trị Web Admin:** Mở trình duyệt truy cập: **`http://localhost:8000/admin`**
  - Xác nhận đơn đặt phòng (1-click: Xác nhận, Nhận phòng, Hoàn thành, Hủy)
  - Quản lý & thêm hạng phòng mới (kèm giá, sức chứa, ảnh)
  - Quản lý & thêm dịch vụ mới
  - Tiếp nhận & xử lý yêu cầu gọi dịch vụ tới phòng của khách từ Mobile App

Kiểm tra trạng thái các container:

```bash
docker compose ps
```

Xem log nếu cần theo dõi quá trình import:

```bash
docker compose logs -f
```

### Bước 2: Chạy ứng dụng Flutter

```bash
cd app_khachsan
flutter pub get
flutter run
```

### ⏹ Dừng toàn bộ hệ thống

```bash
docker compose down
```

> **Lưu ý:** Dữ liệu MySQL được lưu trong Docker named volume `khachsan_db_data`, sẽ không bị mất khi chạy lại `docker compose up`.

> **Xóa toàn bộ dữ liệu (reset từ đầu):**  
> ```bash
> docker compose down -v
> ```

---

## 🔧 Cách 2: Khởi chạy thủ công (không dùng Docker)

### Bước 1: Thiết lập Cơ sở dữ liệu (MySQL)

1. Tạo mới CSDL:
   ```sql
   CREATE DATABASE ql_khachsan CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```
2. Import file `database.sql` vào database `ql_khachsan` vừa tạo.

### Bước 2: Khởi động API Server

```bash
cd server_api
npm install
npm start
```

Kiểm tra file `.env` nếu thông tin kết nối MySQL khác mặc định:
```env
PORT=8000
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASSWORD=root
DB_NAME=ql_khachsan
JWT_SECRET=khachsan_jwt_secret_key_2026
```

### Bước 3: Chạy ứng dụng Flutter

```bash
cd app_khachsan
flutter pub get
flutter run
```

---

## 📡 Danh sách API Endpoints

| Method | Endpoint | Yêu cầu Token | Mô tả |
|:---:|:---|:---:|:---|
| `GET` | `/api/settings` | ❌ | Thông tin khách sạn |
| `GET` | `/api/loai-phong` | ❌ | Danh sách hạng phòng |
| `GET` | `/api/loai-phong/:id` | ❌ | Chi tiết hạng phòng |
| `POST` | `/api/phong/tim-kiem` | ❌ | Tìm phòng trống theo ngày & số người |
| `POST` | `/api/register` | ❌ | Đăng ký tài khoản |
| `POST` | `/api/login` | ❌ | Đăng nhập |
| `GET` | `/api/user` | ✅ | Thông tin tài khoản hiện tại |
| `POST` | `/api/logout` | ✅ | Đăng xuất |
| `POST` | `/api/dat-phong/khach-vang-lai` | ❌ | Đặt phòng (khách vãng lai) |
| `POST` | `/api/dat-phong` | ✅ | Đặt phòng (thành viên) |
| `GET` | `/api/lich-su-dat-phong` | ✅ | Lịch sử đặt phòng cá nhân |
| `PUT` | `/api/dat-phong/:id/huy` | ✅ | Hủy đơn đặt phòng & giải phóng phòng |
| `POST` | `/api/dat-phong/:id/dat-dich-vu` | ✅ | Gọi thêm dịch vụ vào phòng |

---

## 📱 Tài Liệu Chi Tiết Ứng Dụng Di Động

Toàn bộ chi tiết về các tính năng, thư viện sử dụng, luồng logic nghiệp vụ và bộ câu hỏi vấn đáp bảo vệ đồ án được trình bày đầy đủ tại:
* 📖 **[Tài liệu chi tiết Mobile App (app_khachsan/README.md)](./app_khachsan/README.md)**: Ma trận thư viện, phân tích logic chi tiết, cấu trúc thư mục, câu hỏi bảo vệ đồ án.
* 🤖 **[Báo cáo thuyết minh Thuật toán AI On-Device (app_khachsan/README_AI.md)](./app_khachsan/README_AI.md)**: Thuyết minh chuyên sâu thuật toán NLP On-Device 5 bước chạy nội bộ trên Dart.
