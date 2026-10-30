const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const path = require('path');
require('dotenv').config();

const db = require('./db');

const app = express();
const PORT = process.env.PORT || 8000;
const JWT_SECRET = process.env.JWT_SECRET || 'secret_jwt_key_2026';

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Phục vụ ảnh upload tĩnh nếu có
app.use('/storage', express.static(path.join(__dirname, 'storage')));
app.use('/uploads', express.static(path.join(__dirname, 'storage')));
app.use('/admin', express.static(path.join(__dirname, 'public/admin')));

// Middleware xác thực JWT
const xacThucToken = async (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Chưa cung cấp token xác thực' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const [users] = await db.execute('SELECT * FROM tai_khoan WHERE id = ?', [decoded.id]);
    if (users.length === 0) {
      return res.status(401).json({ message: 'Tài khoản không tồn tại' });
    }
    req.user = users[0];
    next();
  } catch (err) {
    return res.status(403).json({ message: 'Token không hợp lệ hoặc đã hết hạn' });
  }
};

// ======================== API CÔNG KHAI ========================

// 1. Cấu hình thông tin khách sạn (đọc thời gian thực từ CSDL MySQL bảng cai_dat)
app.get('/api/settings', async (req, res) => {
  try {
    const [rows] = await db.execute("SELECT khoa, gia_tri FROM cai_dat");
    const settings = {};
    for (const r of rows) {
      settings[r.khoa] = r.gia_tri;
    }
    settings.ten_khach_san = settings.ten_khach_san || 'Khách Sạn Grand Luxury';
    settings.dia_chi = settings.dia_chi || '123 Đường Bờ Biển, Đà Nẵng (sát bãi biển Mỹ Khê)';
    settings.so_dien_thoai = settings.so_dien_thoai || '1900 6868';
    settings.email = settings.email || 'contact@grandluxury.vn';
    res.json(settings);
  } catch (err) {
    res.json({
      ten_khach_san: 'Khách Sạn Grand Luxury',
      dia_chi: '123 Đường Bờ Biển, Đà Nẵng (sát bãi biển Mỹ Khê)',
      so_dien_thoai: '1900 6868',
      email: 'contact@grandluxury.vn',
    });
  }
});

// 1.1 Quản trị cấu hình hệ thống (Admin)
app.get('/api/admin/settings', async (req, res) => {
  try {
    const [rows] = await db.execute("SELECT * FROM cai_dat ORDER BY khoa ASC");
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: "Lỗi tải cài đặt", error: err.message });
  }
});

app.put('/api/admin/settings', async (req, res) => {
  try {
    const updates = req.body;
    for (const [khoa, gia_tri] of Object.entries(updates)) {
      await db.execute(
        "INSERT INTO cai_dat (khoa, gia_tri) VALUES (?, ?) ON DUPLICATE KEY UPDATE gia_tri = VALUES(gia_tri)",
        [khoa, String(gia_tri)]
      );
    }
    res.json({ success: true, message: "Cập nhật cài đặt thành công!" });
  } catch (err) {
    res.status(500).json({ message: "Lỗi cập nhật cài đặt", error: err.message });
  }
});

// 2. Danh sách loại phòng
app.get('/api/loai-phong', async (req, res) => {
  try {
    const [rows] = await db.execute('SELECT * FROM loai_phong');
    const ketQua = rows.map((lp) => ({
      ...lp,
      tien_ich: lp.tien_ich ? (typeof lp.tien_ich === 'string' && lp.tien_ich.startsWith('[') ? JSON.parse(lp.tien_ich) : lp.tien_ich) : [],
      hinh_anh_phu: lp.hinh_anh_phu ? (typeof lp.hinh_anh_phu === 'string' && lp.hinh_anh_phu.startsWith('[') ? JSON.parse(lp.hinh_anh_phu) : lp.hinh_anh_phu) : [],
    }));
    res.json(ketQua);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi máy chủ', error: err.message });
  }
});

// 3. Chi tiết loại phòng
app.get('/api/loai-phong/:id', async (req, res) => {
  try {
    const [rows] = await db.execute('SELECT * FROM loai_phong WHERE id = ?', [req.params.id]);
    if (rows.length === 0) {
      return res.status(404).json({ message: 'Không tìm thấy loại phòng' });
    }
    const lp = rows[0];
    res.json({
      ...lp,
      tien_ich: lp.tien_ich ? (typeof lp.tien_ich === 'string' && lp.tien_ich.startsWith('[') ? JSON.parse(lp.tien_ich) : lp.tien_ich) : [],
      hinh_anh_phu: lp.hinh_anh_phu ? (typeof lp.hinh_anh_phu === 'string' && lp.hinh_anh_phu.startsWith('[') ? JSON.parse(lp.hinh_anh_phu) : lp.hinh_anh_phu) : [],
    });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi máy chủ', error: err.message });
  }
});

// 4. Tìm kiếm phòng trống theo ngày và số người
app.post('/api/phong/tim-kiem', async (req, res) => {
  try {
    const { ngay_nhan_phong, ngay_tra_phong, so_nguoi } = req.body;
    if (!ngay_nhan_phong || !ngay_tra_phong) {
      return res.status(422).json({ message: 'Vui lòng cung cấp ngày nhận và trả phòng' });
    }

    // Lấy id phòng đã được phân bổ trong khoảng thời gian này
    const queryPhongDaDat = `
      SELECT DISTINCT pb.id_phong
      FROM phan_bo_phong pb
      JOIN dat_phong dp ON pb.id_dat_phong = dp.id
      WHERE dp.ngay_nhan_phong < ? AND dp.ngay_tra_phong > ?
        AND dp.trang_thai IN ('Moi_Dat', 'Da_Nhan_Phong', 'Da_Thanh_Toan')
    `;
    const [phongDaDatRows] = await db.execute(queryPhongDaDat, [ngay_tra_phong, ngay_nhan_phong]);
    const idsDaDat = phongDaDatRows.map((r) => r.id_phong);

    let queryPhong = `
      SELECT p.*, lp.ten_loai, lp.suc_chua, lp.gia_co_ban, lp.hinh_anh, lp.mo_ta, lp.tien_ich, lp.hinh_anh_phu
      FROM phong p
      JOIN loai_phong lp ON p.id_loai_phong = lp.id
      WHERE p.trang_thai != 'Bao_Tri'
    `;
    const params = [];

    if (idsDaDat.length > 0) {
      queryPhong += ` AND p.id NOT IN (${idsDaDat.map(() => '?').join(',')})`;
      params.push(...idsDaDat);
    }
    if (so_nguoi && parseInt(so_nguoi) > 0) {
      queryPhong += ` AND lp.suc_chua >= ?`;
      params.push(parseInt(so_nguoi));
    }

    const [phongRows] = await db.execute(queryPhong, params);

    // Gom nhóm theo loại phòng tương thích định dạng Laravel API
    const loaiPhongMap = {};
    for (const r of phongRows) {
      const lid = r.id_loai_phong;
      if (!loaiPhongMap[lid]) {
        loaiPhongMap[lid] = {
          id: lid,
          ten_loai: r.ten_loai,
          suc_chua: r.suc_chua,
          gia_co_ban: parseFloat(r.gia_co_ban),
          hinh_anh: r.hinh_anh,
          mo_ta: r.mo_ta,
          tien_ich: r.tien_ich ? (typeof r.tien_ich === 'string' && r.tien_ich.startsWith('[') ? JSON.parse(r.tien_ich) : r.tien_ich) : [],
          hinh_anh_phu: r.hinh_anh_phu ? (typeof r.hinh_anh_phu === 'string' && r.hinh_anh_phu.startsWith('[') ? JSON.parse(r.hinh_anh_phu) : r.hinh_anh_phu) : [],
          so_luong_trong: 0,
          danh_sach_phong: [],
        };
      }
      loaiPhongMap[lid].so_luong_trong += 1;
      loaiPhongMap[lid].danh_sach_phong.push({
        id: r.id,
        ma_phong: r.ma_phong,
        id_tang: r.id_tang,
        id_loai_phong: r.id_loai_phong,
      });
    }

    res.json(Object.values(loaiPhongMap));
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi tìm kiếm phòng', error: err.message });
  }
});

// 5. Đăng ký tài khoản
app.post('/api/register', async (req, res) => {
  try {
    const { ho_ten, email, mat_khau, so_dien_thoai } = req.body;
    if (!ho_ten || !email || !mat_khau || !so_dien_thoai) {
      return res.status(422).json({ message: 'Vui lòng điền đầy đủ thông tin' });
    }

    const [existing] = await db.execute('SELECT id FROM tai_khoan WHERE email = ?', [email.trim()]);
    if (existing.length > 0) {
      return res.status(422).json({ message: 'Email này đã được sử dụng' });
    }

    const hashedPassword = await bcrypt.hash(mat_khau, 10);
    const [result] = await db.execute(
      `INSERT INTO tai_khoan (ho_ten, email, mat_khau, so_dien_thoai, vai_tro, dang_hoat_dong, created_at, updated_at)
       VALUES (?, ?, ?, ?, 'Khach_Hang', 1, NOW(), NOW())`,
      [ho_ten.trim(), email.trim(), hashedPassword, so_dien_thoai.trim()]
    );

    const userId = result.insertId;
    const token = jwt.sign({ id: userId, email: email.trim() }, JWT_SECRET, { expiresIn: '30d' });

    res.status(201).json({
      message: 'Đăng ký thành công',
      access_token: token,
      token_type: 'Bearer',
      user: {
        id: userId,
        ho_ten: ho_ten.trim(),
        email: email.trim(),
        so_dien_thoai: so_dien_thoai.trim(),
        vai_tro: 'Khach_Hang',
      },
    });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi đăng ký', error: err.message });
  }
});

// 6. Đăng nhập
app.post('/api/login', async (req, res) => {
  try {
    const { email, mat_khau } = req.body;
    if (!email || !mat_khau) {
      return res.status(422).json({ message: 'Vui lòng nhập email và mật khẩu' });
    }

    const [rows] = await db.execute('SELECT * FROM tai_khoan WHERE email = ?', [email.trim()]);
    if (rows.length === 0) {
      return res.status(401).json({ message: 'Thông tin đăng nhập không chính xác' });
    }

    const user = rows[0];
    const match = await bcrypt.compare(mat_khau, user.mat_khau);
    if (!match) {
      return res.status(401).json({ message: 'Thông tin đăng nhập không chính xác' });
    }

    if (!user.dang_hoat_dong) {
      return res.status(403).json({ message: 'Tài khoản của bạn đã bị khóa' });
    }

    const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: '30d' });

    res.json({
      message: 'Đăng nhập thành công',
      access_token: token,
      token_type: 'Bearer',
      user: {
        id: user.id,
        ho_ten: user.ho_ten,
        email: user.email,
        so_dien_thoai: user.so_dien_thoai,
        vai_tro: user.vai_tro,
      },
    });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi đăng nhập', error: err.message });
  }
});

// 7. Đặt phòng khách vãng lai (không đăng nhập)
app.post('/api/dat-phong/khach-vang-lai', async (req, res) => {
  return handleDatPhong(req, res, null);
});

// ======================== API CẦN ĐĂNG NHẬP (TOKEN) ========================

// 8. Lấy thông tin user hiện tại
app.get('/api/user', xacThucToken, async (req, res) => {
  const { mat_khau, ...userInfo } = req.user;
  res.json(userInfo);
});

// 9. Đăng xuất
app.post('/api/logout', xacThucToken, async (req, res) => {
  res.json({ message: 'Đăng xuất thành công' });
});

// 10. Đặt phòng thành viên
app.post('/api/dat-phong', xacThucToken, async (req, res) => {
  return handleDatPhong(req, res, req.user.id);
});

// Hàm xử lý đặt phòng chung
async function handleDatPhong(req, res, userId) {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const { ngay_nhan_phong, ngay_tra_phong, id_loai_phong, so_luong_phong, ten_khach_hang, sdt_khach_hang } = req.body;
    if (!ngay_nhan_phong || !ngay_tra_phong || !id_loai_phong || !so_luong_phong) {
      await connection.rollback();
      return res.status(422).json({ message: 'Vui lòng cung cấp đầy đủ thông tin đặt phòng' });
    }

    const [loaiPhongRows] = await connection.execute('SELECT * FROM loai_phong WHERE id = ?', [id_loai_phong]);
    if (loaiPhongRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ message: 'Không tìm thấy loại phòng' });
    }
    const loaiPhong = loaiPhongRows[0];

    // Tính số ngày
    const dCheckIn = new Date(ngay_nhan_phong);
    const dCheckOut = new Date(ngay_tra_phong);
    const diffTime = Math.abs(dCheckOut - dCheckIn);
    const diffDays = Math.max(1, Math.ceil(diffTime / (1000 * 60 * 60 * 24)));
    const tongTien = diffDays * parseFloat(loaiPhong.gia_co_ban) * parseInt(so_luong_phong);

    const [insertResult] = await connection.execute(
      `INSERT INTO dat_phong (
        id_tai_khoan, ten_khach_hang, sdt_khach_hang, id_loai_phong,
        ten_loai_phong_khi_dat, so_luong_phong, gia_phong_khi_dat,
        ngay_nhan_phong, ngay_tra_phong, tong_tien, so_tien_da_thanh_toan,
        trang_thai, trang_thai_thanh_toan, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0.00, 'Moi_Dat', 'Chưa thanh toán', NOW(), NOW())`,
      [
        userId || null,
        (ten_khach_hang || '').trim(),
        (sdt_khach_hang || '').trim(),
        id_loai_phong,
        loaiPhong.ten_loai,
        parseInt(so_luong_phong),
        parseFloat(loaiPhong.gia_co_ban),
        ngay_nhan_phong,
        ngay_tra_phong,
        tongTien,
      ]
    );

    const datPhongId = insertResult.insertId;
    await connection.commit();

    const [datPhongMoi] = await db.execute(
      `SELECT dp.*, lp.ten_loai as ten_loai_phong, lp.gia_co_ban
       FROM dat_phong dp
       JOIN loai_phong lp ON dp.id_loai_phong = lp.id
       WHERE dp.id = ?`,
      [datPhongId]
    );

    res.status(201).json({
      message: 'Đặt phòng thành công',
      dat_phong: datPhongMoi[0],
    });
  } catch (err) {
    await connection.rollback();
    console.error(err);
    res.status(500).json({ message: 'Lỗi đặt phòng', error: err.message });
  } finally {
    connection.release();
  }
}

// 11. Lịch sử đặt phòng
app.get('/api/lich-su-dat-phong', xacThucToken, async (req, res) => {
  try {
    const [rows] = await db.execute(
      `SELECT dp.*, lp.ten_loai, lp.gia_co_ban, lp.hinh_anh
       FROM dat_phong dp
       JOIN loai_phong lp ON dp.id_loai_phong = lp.id
       WHERE dp.id_tai_khoan = ?
       ORDER BY dp.id DESC`,
      [req.user.id]
    );

    const datPhongIds = rows.map((r) => r.id);
    const phanBoMap = {};
    if (datPhongIds.length > 0) {
      const placeholders = datPhongIds.map(() => '?').join(',');
      const [pbRows] = await db.execute(
        `SELECT pbp.id_dat_phong, p.id as id_phong, p.so_phong
         FROM phan_bo_phong pbp
         JOIN phong p ON pbp.id_phong = p.id
         WHERE pbp.id_dat_phong IN (${placeholders})`,
        datPhongIds
      );
      for (const pb of pbRows) {
        if (!phanBoMap[pb.id_dat_phong]) {
          phanBoMap[pb.id_dat_phong] = [];
        }
        phanBoMap[pb.id_dat_phong].push({
          id_phong: pb.id_phong,
          phong: {
            id: pb.id_phong,
            so_phong: pb.so_phong,
          },
        });
      }
    }

    const ketQua = rows.map((dp) => ({
      ...dp,
      loai_phong: {
        id: dp.id_loai_phong,
        ten_loai: dp.ten_loai,
        gia_co_ban: dp.gia_co_ban,
        hinh_anh: dp.hinh_anh,
      },
      phan_bo_phongs: phanBoMap[dp.id] || [],
    }));

    res.json(ketQua);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi lấy lịch sử', error: err.message });
  }
});

// 11.2 Chi tiết đơn đặt phòng (gồm danh sách phòng và các dịch vụ đã gọi)
app.get('/api/dat-phong/:id/chi-tiet', async (req, res) => {
  try {
    const id = req.params.id;

    // 1. Lấy thông tin đơn đặt phòng
    const [dpRows] = await db.execute(`
      SELECT dp.*, lp.ten_loai, lp.gia_co_ban, lp.hinh_anh, lp.mo_ta, lp.suc_chua
      FROM dat_phong dp
      JOIN loai_phong lp ON dp.id_loai_phong = lp.id
      WHERE dp.id = ?
    `, [id]);

    if (dpRows.length === 0) {
      return res.status(404).json({ message: 'Không tìm thấy đơn đặt phòng' });
    }
    const don = dpRows[0];

    // 2. Lấy danh sách phòng đã phân bổ
    const [phongRows] = await db.execute(`
      SELECT pbp.id, pbp.id_phong, p.so_phong, p.trang_thai as trang_thai_phong, t.ten_tang
      FROM phan_bo_phong pbp
      JOIN phong p ON pbp.id_phong = p.id
      LEFT JOIN tang t ON p.id_tang = t.id
      WHERE pbp.id_dat_phong = ?
      ORDER BY p.so_phong ASC
    `, [id]);

    // 3. Lấy danh sách dịch vụ đã gọi cho đơn này
    const [dvRows] = await db.execute(`
      SELECT sdv.*, dv.ten_dich_vu, dv.gia as don_gia_dich_vu, dv.hinh_anh as hinh_anh_dich_vu, p.so_phong
      FROM su_dung_dich_vu sdv
      JOIN dich_vu dv ON sdv.id_dich_vu = dv.id
      LEFT JOIN phong p ON sdv.id_phong = p.id
      WHERE sdv.id_dat_phong = ?
      ORDER BY sdv.id DESC
    `, [id]);

    // 4. Tính toán chi phí
    const tienPhong = parseFloat(don.tong_tien) || 0;
    const tongTienDichVu = dvRows.reduce((sum, item) => sum + (parseFloat(item.tong_tien) || 0), 0);
    const tongUocTinh = tienPhong + tongTienDichVu;
    const daThanhToan = parseFloat(don.so_tien_da_thanh_toan) || 0;
    const conLaiPhaiTra = Math.max(0, tongUocTinh - daThanhToan);

    res.json({
      don: {
        ...don,
        loai_phong: {
          id: don.id_loai_phong,
          ten_loai: don.ten_loai,
          gia_co_ban: don.gia_co_ban,
          hinh_anh: don.hinh_anh,
          mo_ta: don.mo_ta,
          suc_chua: don.suc_chua,
        },
        phan_bo_phongs: phongRows.map(p => ({
          id_phong: p.id_phong,
          phong: {
            id: p.id_phong,
            so_phong: p.so_phong,
            ten_tang: p.ten_tang,
            trang_thai: p.trang_thai_phong
          }
        })),
        danh_sach_so_phong: phongRows.map(p => p.so_phong)
      },
      dich_vu_da_goi: dvRows.map(dv => ({
        id: dv.id,
        id_dich_vu: dv.id_dich_vu,
        ten_dich_vu: dv.ten_dich_vu,
        so_luong: dv.so_luong,
        don_gia: parseFloat(dv.don_gia_dich_vu),
        tong_tien: parseFloat(dv.tong_tien),
        so_phong: dv.so_phong,
        trang_thai: dv.trang_thai,
        thoi_gian: dv.thoi_gian_su_dung || dv.created_at,
        hinh_anh: dv.hinh_anh_dich_vu,
      })),
      tong_ket_chi_phi: {
        tien_phong: tienPhong,
        tong_tien_dich_vu: tongTienDichVu,
        tong_uoc_tinh: tongUocTinh,
        da_thanh_toan: daThanhToan,
        con_lai_phai_tra: conLaiPhaiTra,
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi lấy chi tiết đơn đặt phòng', error: err.message });
  }
});


// ======================== API DỊCH VỤ & GỌI DỊCH VỤ ========================

// 12. Lấy danh sách dịch vụ cho Mobile App & Web
app.get("/api/dich-vu", async (req, res) => {
  try {
    const [rows] = await db.execute("SELECT * FROM dich_vu WHERE dang_hoat_dong = 1 ORDER BY id ASC");
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: "Lỗi tải dịch vụ", error: err.message });
  }
});

// 13. Khách hàng gửi yêu cầu gọi dịch vụ tới phòng
app.post("/api/yeu-cau-dich-vu", async (req, res) => {
  try {
    const { id_dat_phong, id_dich_vu, so_luong, so_phong, ghi_chu } = req.body;
    const [dvRows] = await db.execute("SELECT * FROM dich_vu WHERE id = ?", [id_dich_vu]);
    if (dvRows.length === 0) {
      return res.status(404).json({ message: "Không tìm thấy dịch vụ" });
    }
    const dv = dvRows[0];
    const qty = parseInt(so_luong) || 1;
    const tongTien = parseFloat(dv.gia) * qty;

    let datPhongId = id_dat_phong;
    if (!datPhongId) {
      const [latest] = await db.execute("SELECT id FROM dat_phong ORDER BY id DESC LIMIT 1");
      if (latest.length > 0) datPhongId = latest[0].id;
    }

    let idPhong = null;
    if (so_phong) {
      const [pRows] = await db.execute("SELECT id FROM phong WHERE so_phong = ?", [so_phong.trim()]);
      if (pRows.length > 0) idPhong = pRows[0].id;
    }

    const [insertResult] = await db.execute(
      `INSERT INTO su_dung_dich_vu (
        id_dat_phong, id_phong, id_dich_vu, so_luong, tong_tien, trang_thai, thoi_gian_su_dung, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, "Cho_Phuc_Vu", NOW(), NOW(), NOW())`,
      [datPhongId, idPhong, id_dich_vu, qty, tongTien]
    );

    res.status(201).json({
      message: "Yêu cầu dịch vụ thành công! Khách sạn sẽ phục vụ tới phòng bạn trong ít phút.",
      id: insertResult.insertId,
      ten_dich_vu: dv.ten_dich_vu,
      so_luong: qty,
      tong_tien: tongTien,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Lỗi gọi dịch vụ", error: err.message });
  }
});

// ======================== API ADMIN QUẢN TRỊ ========================

// A1. Lấy danh sách toàn bộ đơn đặt phòng
app.get("/api/admin/dat-phong", async (req, res) => {
  try {
    const [rows] = await db.execute(`
      SELECT dp.*, lp.ten_loai, lp.gia_co_ban, lp.hinh_anh
      FROM dat_phong dp
      LEFT JOIN loai_phong lp ON dp.id_loai_phong = lp.id
      ORDER BY dp.id DESC
    `);

    const datPhongIds = rows.map((r) => r.id);
    const phanBoMap = {};
    if (datPhongIds.length > 0) {
      const placeholders = datPhongIds.map(() => '?').join(',');
      const [pbRows] = await db.execute(
        `SELECT pbp.id_dat_phong, p.id as id_phong, p.so_phong
         FROM phan_bo_phong pbp
         JOIN phong p ON pbp.id_phong = p.id
         WHERE pbp.id_dat_phong IN (${placeholders})`,
        datPhongIds
      );
      for (const pb of pbRows) {
        if (!phanBoMap[pb.id_dat_phong]) {
          phanBoMap[pb.id_dat_phong] = [];
        }
        phanBoMap[pb.id_dat_phong].push({
          id_phong: pb.id_phong,
          phong: {
            id: pb.id_phong,
            so_phong: pb.so_phong,
          },
        });
      }
    }

    const ketQua = rows.map((dp) => ({
      ...dp,
      phan_bo_phongs: phanBoMap[dp.id] || [],
    }));

    res.json(ketQua);
  } catch (err) {
    res.status(500).json({ message: "Lỗi tải danh sách đơn", error: err.message });
  }
});

// A2. Danh sách phòng trống theo hạng phòng (cho modal check-in)
app.get("/api/admin/phong-trong/:id_loai_phong", async (req, res) => {
  try {
    const [rows] = await db.execute(
      `SELECT p.id, p.so_phong, t.ten_tang
       FROM phong p
       LEFT JOIN tang t ON p.id_tang = t.id
       WHERE p.id_loai_phong = ? AND p.trang_thai = 'Trong'
       ORDER BY p.so_phong ASC`,
      [req.params.id_loai_phong]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: "Lỗi lấy phòng trống", error: err.message });
  }
});

// A2.1 Cập nhật trạng thái đơn (gán phòng khi check-in, trả phòng khi checkout/hủy)
app.put("/api/admin/dat-phong/:id/trang-thai", async (req, res) => {
  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();
    const id_don = req.params.id;
    const trang_thai = req.body.trang_thai !== undefined ? req.body.trang_thai : null;
    const trang_thai_thanh_toan = req.body.trang_thai_thanh_toan !== undefined ? req.body.trang_thai_thanh_toan : null;
    const ids_phong = req.body.ids_phong || null;

    // Cập nhật trạng thái đơn
    await conn.execute(
      "UPDATE dat_phong SET trang_thai = COALESCE(?, trang_thai), trang_thai_thanh_toan = COALESCE(?, trang_thai_thanh_toan), updated_at = NOW() WHERE id = ?",
      [trang_thai, trang_thai_thanh_toan, id_don]
    );

    // CHECK-IN: gán phòng được chọn hoặc tự động chọn nếu chưa chọn
    if (trang_thai === 'Da_Nhan_Phong') {
      if (ids_phong && ids_phong.length > 0) {
        await conn.execute("DELETE FROM phan_bo_phong WHERE id_dat_phong = ?", [id_don]);
        for (const id_phong of ids_phong) {
          await conn.execute(
            "INSERT INTO phan_bo_phong (id_dat_phong, id_phong, thoi_gian_phan_bo) VALUES (?, ?, NOW())",
            [id_don, id_phong]
          );
          await conn.execute("UPDATE phong SET trang_thai = 'Da_Su_Dung' WHERE id = ?", [id_phong]);
        }
      } else {
        const [existing] = await conn.execute("SELECT id FROM phan_bo_phong WHERE id_dat_phong = ?", [id_don]);
        if (existing.length === 0) {
          const [dpRows] = await conn.execute("SELECT id_loai_phong, so_luong_phong FROM dat_phong WHERE id = ?", [id_don]);
          if (dpRows.length > 0) {
            const { id_loai_phong, so_luong_phong } = dpRows[0];
            const [availableRooms] = await conn.execute(
              "SELECT id FROM phong WHERE id_loai_phong = ? AND trang_thai = 'Trong' ORDER BY RAND() LIMIT ?",
              [id_loai_phong, Number(so_luong_phong) || 1]
            );
            for (const r of availableRooms) {
              await conn.execute(
                "INSERT INTO phan_bo_phong (id_dat_phong, id_phong, thoi_gian_phan_bo) VALUES (?, ?, NOW())",
                [id_don, r.id]
              );
              await conn.execute("UPDATE phong SET trang_thai = 'Da_Su_Dung' WHERE id = ?", [r.id]);
            }
          }
        }
      }
    }

    // CHECKOUT / HỦY: trả phòng về trống
    if (trang_thai === 'Da_Thanh_Toan' || trang_thai === 'Da_Huy') {
      const [phongDaGan] = await conn.execute(
        "SELECT id_phong FROM phan_bo_phong WHERE id_dat_phong = ?", [id_don]
      );
      for (const row of phongDaGan) {
        await conn.execute("UPDATE phong SET trang_thai = 'Trong' WHERE id = ?", [row.id_phong]);
      }
    }

    await conn.commit();
    res.json({ message: "Cập nhật trạng thái thành công" });
  } catch (err) {
    await conn.rollback();
    console.error(err);
    res.status(500).json({ message: "Lỗi cập nhật đơn", error: err.message });
  } finally {
    conn.release();
  }
});

// A2.1 Xóa vĩnh viễn đơn đặt phòng
app.delete("/api/admin/dat-phong/:id", async (req, res) => {
  try {
    await db.execute("DELETE FROM phan_bo_phong WHERE id_dat_phong = ?", [req.params.id]);
    await db.execute("DELETE FROM su_dung_dich_vu WHERE id_dat_phong = ?", [req.params.id]);
    await db.execute("DELETE FROM thanh_toan WHERE id_dat_phong = ?", [req.params.id]);
    await db.execute("DELETE FROM dat_phong WHERE id = ?", [req.params.id]);
    res.json({ message: "Xóa đơn đặt phòng thành công" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Lỗi xóa đơn", error: err.message });
  }
});

// A3. Danh sách hạng phòng (Admin)
app.get("/api/admin/loai-phong", async (req, res) => {
  try {
    const [rows] = await db.execute("SELECT * FROM loai_phong ORDER BY id ASC");
    const ketQua = rows.map((lp) => ({
      ...lp,
      tien_ich: lp.tien_ich ? (typeof lp.tien_ich === 'string' && lp.tien_ich.startsWith('[') ? JSON.parse(lp.tien_ich) : lp.tien_ich) : [],
    }));
    res.json(ketQua);
  } catch (err) {
    res.status(500).json({ message: "Lỗi tải hạng phòng", error: err.message });
  }
});

// A4. Thêm hạng phòng mới
app.post("/api/admin/loai-phong", async (req, res) => {
  try {
    const { ten_loai, suc_chua, gia_co_ban, mo_ta, tien_ich, hinh_anh } = req.body;
    const [result] = await db.execute(
      `INSERT INTO loai_phong (ten_loai, suc_chua, gia_co_ban, mo_ta, tien_ich, hinh_anh, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())`,
      [
        ten_loai,
        parseInt(suc_chua) || 2,
        parseFloat(gia_co_ban) || 0,
        mo_ta || "",
        typeof tien_ich === "object" ? JSON.stringify(tien_ich) : (tien_ich || "[]"),
        hinh_anh || "storage/rooms/suite.jpg",
      ]
    );
    res.status(201).json({ message: "Thêm hạng phòng thành công", id: result.insertId });
  } catch (err) {
    res.status(500).json({ message: "Lỗi thêm hạng phòng", error: err.message });
  }
});

// A4.1 Cập nhật hạng phòng
app.put("/api/admin/loai-phong/:id", async (req, res) => {
  try {
    const { ten_loai, suc_chua, gia_co_ban, mo_ta, hinh_anh, tien_ich } = req.body;
    let tienIchJson = null;
    if (tien_ich !== undefined) {
      tienIchJson = typeof tien_ich === "object" ? JSON.stringify(tien_ich) : (tien_ich || "[]");
    }

    await db.execute(
      `UPDATE loai_phong SET
        ten_loai = COALESCE(?, ten_loai),
        suc_chua = COALESCE(?, suc_chua),
        gia_co_ban = COALESCE(?, gia_co_ban),
        mo_ta = COALESCE(?, mo_ta),
        hinh_anh = COALESCE(?, hinh_anh),
        tien_ich = COALESCE(?, tien_ich),
        updated_at = NOW()
       WHERE id = ?`,
      [
        ten_loai !== undefined ? ten_loai : null,
        suc_chua !== undefined ? parseInt(suc_chua) : null,
        gia_co_ban !== undefined ? parseFloat(gia_co_ban) : null,
        mo_ta !== undefined ? mo_ta : null,
        hinh_anh !== undefined ? hinh_anh : null,
        tienIchJson,
        req.params.id
      ]
    );
    res.json({ message: "Cập nhật hạng phòng thành công" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Lỗi cập nhật hạng phòng", error: err.message });
  }
});

// A5. Xóa hạng phòng
app.delete("/api/admin/loai-phong/:id", async (req, res) => {
  try {
    const [pRows] = await db.execute("SELECT COUNT(*) as count FROM phong WHERE id_loai_phong = ?", [req.params.id]);
    const [dpRows] = await db.execute("SELECT COUNT(*) as count FROM dat_phong WHERE id_loai_phong = ?", [req.params.id]);
    if (pRows[0].count > 0 || dpRows[0].count > 0) {
      return res.status(400).json({
        message: `Không thể xóa hạng phòng này vì đang có ${pRows[0].count} phòng hoặc ${dpRows[0].count} đơn đặt phòng liên kết.`
      });
    }
    await db.execute("DELETE FROM loai_phong WHERE id = ?", [req.params.id]);
    res.json({ message: "Xóa hạng phòng thành công" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Lỗi xóa hạng phòng", error: err.message });
  }
});

// A6. Danh sách dịch vụ (Admin)
app.get("/api/admin/dich-vu", async (req, res) => {
  try {
    const [rows] = await db.execute("SELECT * FROM dich_vu ORDER BY id ASC");
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: "Lỗi tải dịch vụ", error: err.message });
  }
});

// A7. Thêm dịch vụ mới
app.post("/api/admin/dich-vu", async (req, res) => {
  try {
    const { ten_dich_vu, gia, hinh_anh } = req.body;
    const [result] = await db.execute(
      `INSERT INTO dich_vu (ten_dich_vu, gia, dang_hoat_dong, hinh_anh, id_loai_dich_vu, created_at, updated_at)
       VALUES (?, ?, 1, ?, 3, NOW(), NOW())`,
      [
        ten_dich_vu,
        parseFloat(gia) || 0,
        hinh_anh || "storage/defaults/service.jpg",
      ]
    );
    res.status(201).json({ message: "Thêm dịch vụ thành công", id: result.insertId });
  } catch (err) {
    res.status(500).json({ message: "Lỗi thêm dịch vụ", error: err.message });
  }
});

// A7.1 Cập nhật dịch vụ
app.put("/api/admin/dich-vu/:id", async (req, res) => {
  try {
    const { ten_dich_vu, gia, hinh_anh, dang_hoat_dong } = req.body;
    await db.execute(
      `UPDATE dich_vu SET
        ten_dich_vu = COALESCE(?, ten_dich_vu),
        gia = COALESCE(?, gia),
        hinh_anh = COALESCE(?, hinh_anh),
        dang_hoat_dong = COALESCE(?, dang_hoat_dong),
        updated_at = NOW()
       WHERE id = ?`,
      [
        ten_dich_vu !== undefined ? ten_dich_vu : null,
        gia !== undefined ? parseFloat(gia) : null,
        hinh_anh !== undefined ? hinh_anh : null,
        dang_hoat_dong !== undefined ? dang_hoat_dong : null,
        req.params.id
      ]
    );
    res.json({ message: "Cập nhật dịch vụ thành công" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Lỗi cập nhật dịch vụ", error: err.message });
  }
});

// A8. Xóa dịch vụ
app.delete("/api/admin/dich-vu/:id", async (req, res) => {
  try {
    await db.execute("DELETE FROM su_dung_dich_vu WHERE id_dich_vu = ?", [req.params.id]);
    await db.execute("DELETE FROM dich_vu WHERE id = ?", [req.params.id]);
    res.json({ message: "Xóa dịch vụ thành công" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Lỗi xóa dịch vụ", error: err.message });
  }
});

// A9. Danh sách yêu cầu gọi dịch vụ tới phòng
app.get("/api/admin/yeu-cau-dich-vu", async (req, res) => {
  try {
    const [rows] = await db.execute(`
      SELECT sdv.*, dv.ten_dich_vu, dv.gia as don_gia, dp.ten_khach_hang, dp.sdt_khach_hang, p.so_phong
      FROM su_dung_dich_vu sdv
      LEFT JOIN dich_vu dv ON sdv.id_dich_vu = dv.id
      LEFT JOIN dat_phong dp ON sdv.id_dat_phong = dp.id
      LEFT JOIN phong p ON sdv.id_phong = p.id
      ORDER BY sdv.id DESC
    `);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: "Lỗi tải yêu cầu dịch vụ", error: err.message });
  }
});

// A10. Cập nhật trạng thái phục vụ dịch vụ
app.put("/api/admin/yeu-cau-dich-vu/:id/trang-thai", async (req, res) => {
  try {
    const { trang_thai } = req.body;
    await db.execute(
      "UPDATE su_dung_dich_vu SET trang_thai = ?, updated_at = NOW() WHERE id = ?",
      [trang_thai, req.params.id]
    );
    res.json({ message: "Cập nhật trạng thái phục vụ thành công" });
  } catch (err) {
    res.status(500).json({ message: "Lỗi cập nhật", error: err.message });
  }
});

// ======================== API TRỢ LÝ AI CHATBOT (GEMINI CLOUD) ========================
app.post("/api/chat-bot", async (req, res) => {
  try {
    const { tin_nhan, lich_su, gemini_key } = req.body;
    if (!tin_nhan || !tin_nhan.trim()) {
      return res.status(400).json({ success: false, message: "Thiếu nội dung tin nhắn" });
    }

                let apiKey = gemini_key || req.headers['x-gemini-key'];
    let geminiModel = 'gemini-2.5-flash';

    try {
      const fs = require('fs');
      const envPath = path.join(__dirname, '.env');
      if (fs.existsSync(envPath)) {
        const lines = fs.readFileSync(envPath, 'utf8').split(/[\r\n]+/);
        for (const l of lines) {
          const trimmed = l.trim();
          if (trimmed.startsWith('GEMINI_API_KEY=')) {
            const val = trimmed.substring('GEMINI_API_KEY='.length).trim().replace(/^['"]|['"]$/g, '');
            if (val) apiKey = val;
          }
          if (trimmed.startsWith('GEMINI_MODEL=')) {
            const val = trimmed.substring('GEMINI_MODEL='.length).trim().replace(/^['"]|['"]$/g, '');
            if (val) geminiModel = val;
          }
        }
      }
    } catch (err) {
      console.error('Lỗi đọc .env:', err);
    }

    if (!apiKey) {
      apiKey = process.env.GEMINI_API_KEY;
    }
    if (!geminiModel) {
      geminiModel = process.env.GEMINI_MODEL || 'gemini-2.5-flash';
    }
    if (!apiKey) {
      return res.status(503).json({
        success: false,
        message: "Chưa cấu hình GEMINI_API_KEY. Vui lòng sử dụng AI On-Device cục bộ.",
      });
    }

    // 1. Lấy dữ liệu phòng và cấu hình thực tế từ CSDL MySQL để đưa vào ngữ cảnh AI
    const [rawRooms] = await db.execute("SELECT * FROM loai_phong ORDER BY gia_co_ban ASC");
    const [caiDatRows] = await db.execute("SELECT khoa, gia_tri FROM cai_dat");
    const hConfig = {};
    for (const c of caiDatRows) {
      hConfig[c.khoa] = c.gia_tri;
    }
    const rooms = rawRooms.map(lp => ({
      ...lp,
      tien_ich: lp.tien_ich ? (typeof lp.tien_ich === 'string' && lp.tien_ich.startsWith('[') ? JSON.parse(lp.tien_ich) : lp.tien_ich) : [],
      hinh_anh_phu: lp.hinh_anh_phu ? (typeof lp.hinh_anh_phu === 'string' && lp.hinh_anh_phu.startsWith('[') ? JSON.parse(lp.hinh_anh_phu) : lp.hinh_anh_phu) : [],
    }));

    const danhSachPhongContext = rooms.map(r => {
      const tienIchStr = Array.isArray(r.tien_ich) ? r.tien_ich.join(', ') : (r.tien_ich || '');
      return `- ID ${r.id}: ${r.ten_loai} (Giá: ${Number(r.gia_co_ban).toLocaleString('vi-VN')} đ/đêm, Sức chứa: ${r.suc_chua} người. Tiện ích: ${tienIchStr}. Mô tả: ${r.mo_ta || ''})`;
    }).join("\n");

    const systemPrompt = `Bạn là Trợ lý AI tư vấn phòng cao cấp của Khách Sạn Grand Luxury tại Đà Nẵng (sát biển Mỹ Khê).
Hãy trả lời khách hàng bằng tiếng Việt một cách tự nhiên, lịch sự, thân thiện và chính xác tuyệt đối.

THÔNG TIN DANH SÁCH HẠNG PHÒNG HIỆN CÓ TẠI KHÁCH SẠN:
${danhSachPhongContext}

THÔNG TIN TIỆN ÍCH & DỊCH VỤ KHÁCH SẠN (DỮ LIỆU THỰC TẾ CSDL):
- Tên khách sạn: ${hConfig.ten_khach_san || 'Khách Sạn Grand Luxury'} | Địa chỉ: ${hConfig.dia_chi || '123 Đường Bờ Biển, Đà Nẵng'}
- Vị trí ra biển: ${hConfig.khoang_cach_bien || '50m (2 phút đi bộ)'}
- Giờ nhận phòng: ${hConfig.gio_check_in || '14:00'} | Giờ trả phòng: ${hConfig.gio_check_out || '12:00'}
- Bữa sáng: Buffet sáng (${hConfig.buffet_sang_gio || '06:30 - 09:30'}), giá: ${Number(hConfig.buffet_sang_gia || 150000).toLocaleString('vi-VN')} đ/người.
- Bể bơi: ${hConfig.ho_boi_mo_ta || 'Khách sạn chưa có hồ bơi riêng, nằm sát biển Mỹ Khê.'}
- Đưa đón sân bay: ${Number(hConfig.xe_san_bay_gia || 300000).toLocaleString('vi-VN')} đ/chuyến. Thuê xe máy: ${Number(hConfig.thue_xe_may_gia || 120000).toLocaleString('vi-VN')} đ/ngày.
- Trẻ em: Dưới 6 tuổi miễn phí. Giường phụ: ${Number(hConfig.giuong_phu_gia || 200000).toLocaleString('vi-VN')} đ/đêm.
- Bãi đỗ xe: ${hConfig.bai_do_xe_mo_ta || 'Tầng hầm đỗ xe ô tô và xe máy MIỄN PHÍ 24/7.'}
- Đặt cọc: ${hConfig.ti_le_coc || '30'}% giữ phòng. Hủy phòng: ${hConfig.chinh_sach_huy || 'Miễn phí trước 48 giờ'}.
- Hotline lễ tân: ${hConfig.so_dien_thoai || '1900 6868'} (24/24).

QUY TẮC PHẢN HỒI (RẤT QUAN TRỌNG):
1. Bạn BẮT BUỘC trả về kết quả dưới định dạng JSON duy nhất (không bọc trong markdown code block, không có thêm chữ nào ngoài JSON):
{
  "noi_dung": "câu trả lời đầy đủ, chi tiết, thân thiện cho khách bằng tiếng Việt",
  "phong_ids": [danh sách mảng ID phòng phù hợp nhất được gợi ý],
  "intent": "tên ý định"
}

2. QUY TẮC CHỌN phong_ids:
- Nếu khách hỏi "phòng rẻ nhất", "giá thấp nhất": CHỈ trả về đúng 1 ID phòng có giá thấp nhất (ví dụ: [1]). TUYỆT ĐỐI KHÔNG đưa hết các phòng!
- Nếu khách hỏi "phòng xịn nhất", "phòng đắt nhất", "phòng VIP": CHỈ trả về đúng 1 ID phòng cao cấp nhất (ví dụ: [4]).
- Nếu khách hỏi phòng view biển: chỉ trả về các ID phòng view biển (Deluxe, Suite).
- Nếu khách hỏi phòng theo số người (ví dụ: 2 người, 4 người): chỉ trả về các ID phòng có sức chứa phù hợp.
- Nếu khách hỏi cụ thể 1 phòng (ví dụ: phòng Deluxe): chỉ trả về đúng 1 ID phòng đó.
- NẾU VÀ CHỈ NẾU khách hỏi tổng quan "khách sạn có bao nhiêu hạng phòng" hoặc "có những loại phòng nào": mới đưa mảng tất cả các ID phòng [1, 2, 3, 4].
- Nếu câu hỏi chỉ về tiện ích (ăn sáng, bãi xe, giờ nhận phòng...): để phong_ids là mảng rỗng [].`;

    // 2. Gọi Google Gemini API
    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/${geminiModel}:generateContent?key=${apiKey}`;
    const payload = {
      contents: [
        {
          role: "user",
          parts: [
            { text: `${systemPrompt}\n\nCâu hỏi của khách hàng: "${tin_nhan}"` }
          ]
        }
      ],
      generationConfig: {
        temperature: 0.3,
        maxOutputTokens: 2048,
        responseMimeType: "application/json",
      }
    };

    let geminiRes = await fetch(geminiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });

    if (!geminiRes.ok) {
      // Fallback model gemini-1.5-flash
      const fallbackUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=${apiKey}`;
      geminiRes = await fetch(fallbackUrl, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });
    }

    if (!geminiRes.ok) {
      const errText = await geminiRes.text();
      console.error("Gemini API Error:", errText);
      return res.status(502).json({ success: false, message: "Lỗi phản hồi từ Gemini API", chi_tiet: errText });
    }

    const geminiData = await geminiRes.json();
    const rawText = geminiData.candidates?.[0]?.content?.parts?.[0]?.text || "";
    
    // Parse JSON từ phản hồi của Gemini
    let parsed = null;
    try {
      const cleanedJson = rawText.replace(/```json/g, "").replace(/```/g, "").trim();
      parsed = JSON.parse(cleanedJson);
    } catch (e) {
      const matchNoiDung = rawText.match(/"noi_dung"\s*:\s*"((?:[^"\\]|\\.)*)"/);
      const matchIds = rawText.match(/"phong_ids"\s*:\s*\[([0-9,\s]*)\]/);
      parsed = {
        noi_dung: matchNoiDung ? matchNoiDung[1].replace(/\\n/g, '\n').replace(/\\"/g, '"') : rawText,
        phong_ids: matchIds ? matchIds[1].split(',').map(s => parseInt(s.trim())).filter(n => !isNaN(n)) : [],
        intent: "GEMINI_CHAT",
      };
    }

    // Lấy chi tiết các phòng được gợi ý
    let matchedRooms = [];
    if (Array.isArray(parsed.phong_ids) && parsed.phong_ids.length > 0) {
      matchedRooms = rooms.filter(r => parsed.phong_ids.includes(r.id));
    }

    return res.json({
      success: true,
      noi_dung: parsed.noi_dung,
      danh_sach_phong: matchedRooms,
      phong_ids: parsed.phong_ids || [],
      intent: parsed.intent || "GEMINI_AI",
      nguon: "API_GEMINI",
    });
  } catch (err) {
    console.error("Lỗi chat-bot API:", err);
    return res.status(500).json({ success: false, message: err.message });
  }
});

// Chạy server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`=====================================================`);
  console.log(`🚀 Hotel API Server running at: http://localhost:${PORT}`);
  console.log(`📱 Mobile Emulator connect at:   http://10.0.2.2:${PORT}`);
  console.log(`=====================================================`);
});
