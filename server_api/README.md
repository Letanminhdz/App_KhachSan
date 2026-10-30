# 🏨 Mini Backend API Server cho Flutter App Khách Sạn

Máy chủ API siêu gọn nhẹ được xây dựng bằng **Node.js + Express + MySQL** dùng để phục vụ toàn bộ các tính năng của ứng dụng di động Flutter `app_khachsan`.

---

## 🚀 Tính năng hỗ trợ cho Mobile App
- **Xác thực**: Đăng ký, Đăng nhập, Lấy thông tin user hiện tại (`/api/register`, `/api/login`, `/api/user`).
- **Phòng & Khách sạn**:
  - Thông tin khách sạn (`/api/settings`).
  - Danh sách loại phòng & chi tiết (`/api/loai-phong`, `/api/loai-phong/:id`).
  - Tìm kiếm phòng trống theo ngày & số lượng khách (`/api/phong/tim-kiem`).
- **Đặt phòng**:
  - Đặt phòng khách vãng lai & thành viên (`/api/dat-phong/khach-vang-lai`, `/api/dat-phong`).
  - Lịch sử đặt phòng cá nhân (`/api/lich-su-dat-phong`).

---

## 🛠 Hướng dẫn cài đặt & Khởi chạy

### 1. Cấu hình CSDL (`.env`)
Chỉnh sửa file `.env` nếu cần thay đổi thông tin kết nối MySQL:
```env
PORT=8000
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASSWORD=root
DB_NAME=ql_khachsan
JWT_SECRET=khachsan_jwt_secret_key_2026
```

### 2. Cài đặt thư viện
```bash
npm install
```

### 3. Chạy Server
```bash
npm start
```
Server sẽ chạy tại cổng `http://localhost:8000` (hoặc `http://10.0.2.2:8000` trên máy ảo Android).
