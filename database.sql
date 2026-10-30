/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.20-13.0.2-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: ql_khachsan
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `dat_phong`
--

DROP TABLE IF EXISTS `dat_phong`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dat_phong` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `id_tai_khoan` bigint unsigned DEFAULT NULL,
  `ten_khach_hang` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sdt_khach_hang` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ngay_nhan_phong` datetime NOT NULL,
  `ngay_tra_phong` datetime NOT NULL,
  `id_loai_phong` bigint unsigned NOT NULL,
  `ten_loai_phong_khi_dat` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `so_luong_phong` int NOT NULL,
  `gia_phong_khi_dat` decimal(15,2) NOT NULL,
  `tong_tien` decimal(15,2) NOT NULL DEFAULT '0.00',
  `so_tien_da_thanh_toan` decimal(15,2) NOT NULL DEFAULT '0.00',
  `trang_thai` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Moi_Dat',
  `trang_thai_thanh_toan` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Chưa thanh toán',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `dat_phong_id_tai_khoan_foreign` (`id_tai_khoan`),
  KEY `dat_phong_id_loai_phong_foreign` (`id_loai_phong`),
  CONSTRAINT `dat_phong_id_loai_phong_foreign` FOREIGN KEY (`id_loai_phong`) REFERENCES `loai_phong` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `dat_phong_id_tai_khoan_foreign` FOREIGN KEY (`id_tai_khoan`) REFERENCES `tai_khoan` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dat_phong`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `dat_phong` WRITE;
/*!40000 ALTER TABLE `dat_phong` DISABLE KEYS */;
INSERT INTO `dat_phong` VALUES
(13,1,'Administrator','0987654321','2026-09-25 17:52:51','2026-09-25 17:55:27',1,'Standard',1,500000.00,1000000.00,1000000.00,'Da_Tra_Phong','Đã thanh toán','2026-09-25 17:52:26','2026-09-25 17:55:27'),
(14,1,'Administrator','0987654321','2026-09-25 18:01:35','2026-10-11 13:00:23',3,'Deluxe',1,1200000.00,19560000.00,19560000.00,'Da_Tra_Phong','Đã thanh toán','2026-09-25 18:00:49','2026-10-11 13:00:23'),
(15,1,'Administrator','0987654321','2026-10-02 10:48:07','2026-10-11 13:00:17',3,'Deluxe',1,1200000.00,11520000.00,11520000.00,'Da_Tra_Phong','Đã thanh toán','2026-09-25 18:22:46','2026-10-11 13:00:17');
/*!40000 ALTER TABLE `dat_phong` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `dich_vu`
--

DROP TABLE IF EXISTS `dich_vu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dich_vu` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ten_dich_vu` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `gia` decimal(15,2) NOT NULL,
  `dang_hoat_dong` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `hinh_anh` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_loai_dich_vu` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `dich_vu_id_loai_dich_vu_foreign` (`id_loai_dich_vu`),
  CONSTRAINT `dich_vu_id_loai_dich_vu_foreign` FOREIGN KEY (`id_loai_dich_vu`) REFERENCES `loai_dich_vu` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dich_vu`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `dich_vu` WRITE;
/*!40000 ALTER TABLE `dich_vu` DISABLE KEYS */;
INSERT INTO `dich_vu` VALUES
(1,'Phở Bò Kobe',150000.00,1,'2026-09-23 13:52:26','2026-09-23 13:52:26',NULL,3),
(2,'Bít Tết Bò Mỹ',350000.00,1,'2026-09-23 13:52:27','2026-09-23 13:52:27','storage/dich_vu/J1pVKijOKT.jpg',3),
(3,'Nước Ép Cam Tươi',60000.00,1,'2026-09-23 13:52:27','2026-09-23 13:52:27','storage/dich_vu/SccoKqKFFp.jpg',3),
(4,'Massage Thư Giãn',500000.00,1,'2026-09-23 13:52:28','2026-09-23 13:52:28','storage/dich_vu/SxYg2niR6Y.jpg',3);
/*!40000 ALTER TABLE `dich_vu` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`),
  KEY `failed_jobs_connection_queue_failed_at_index` (`connection`,`queue`,`failed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` smallint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `loai_dich_vu`
--

DROP TABLE IF EXISTS `loai_dich_vu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `loai_dich_vu` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ten_loai` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loai_dich_vu`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `loai_dich_vu` WRITE;
/*!40000 ALTER TABLE `loai_dich_vu` DISABLE KEYS */;
INSERT INTO `loai_dich_vu` VALUES
(1,'Đồ Ăn','2026-09-23 14:39:30','2026-09-23 14:39:30'),
(2,'Nước Uống','2026-09-23 14:39:30','2026-09-23 14:39:30'),
(3,'Dịch Vụ Khác','2026-09-23 14:39:30','2026-09-23 14:39:30');
/*!40000 ALTER TABLE `loai_dich_vu` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `loai_phong`
--

DROP TABLE IF EXISTS `loai_phong`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `loai_phong` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ten_loai` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `suc_chua` int NOT NULL,
  `gia_co_ban` decimal(15,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `hinh_anh` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mo_ta` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `tien_ich` json DEFAULT NULL,
  `hinh_anh_phu` json DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loai_phong`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `loai_phong` WRITE;
/*!40000 ALTER TABLE `loai_phong` DISABLE KEYS */;
INSERT INTO `loai_phong` VALUES
(1,'Standard',2,500000.00,'2026-09-18 08:22:42','2026-10-11 12:21:24','storage/rooms/standard.jpg','Không gian lưu trú tiêu chuẩn cao cấp với đầy đủ tiện nghi hiện đại, mang lại sự thoải mái tối đa cho kỳ nghỉ của bạn.','["Wifi miễn phí", "Điều hòa", "Tivi", "Bàn làm việc", "Máy sấy tóc"]','["storage/rooms/standard_sub1.jpg", "storage/rooms/standard_sub2.jpg"]'),
(2,'Superior',2,800000.00,'2026-09-18 08:22:42','2026-10-11 12:21:24','storage/rooms/superior.jpg','Phòng Superior với tầm nhìn thoáng đãng, nội thất tinh tế và không gian thư giãn sang trọng bậc nhất.','["Wifi miễn phí", "Điều hòa", "Tivi 55 inch", "Minibar", "Ban công", "Bồn tắm đứng"]','["storage/rooms/superior_sub1.jpg", "storage/rooms/superior_sub2.jpg"]'),
(3,'Deluxe',3,1200000.00,'2026-09-18 08:22:42','2026-10-11 12:21:24','storage/rooms/deluxe.jpg','Phòng Deluxe đẳng cấp, diện tích rộng rãi với giường King Size êm ái, bồn tắm nằm thư giãn và view ngắm cảnh tuyệt đẹp.','["Wifi tốc độ cao", "Điều hòa hai chiều", "Smart TV 65 inch", "Minibar cao cấp", "Bồn tắm nằm", "Két sắt", "Ăn sáng miễn phí"]','["storage/rooms/deluxe_sub1.jpg", "storage/rooms/deluxe_sub2.jpg"]'),
(4,'Suite',4,2500000.00,'2026-09-18 08:22:42','2026-10-11 12:21:24','storage/rooms/suite.jpg','Phòng Suite Hoàng Gia - đỉnh cao của sự xa hoa với phòng khách riêng biệt, bồn tắm sục Jacuzzi và dịch vụ phục vụ phòng 24/7.','["Phòng khách riêng", "Bồn tắm sục Jacuzzi", "Smart TV 75 inch", "Quầy bar mini riêng", "Dịch vụ phòng 24/7", "Bữa sáng Buffet cao cấp", "Xe đưa đón sân bay"]','["storage/rooms/suite_sub1.jpg", "storage/rooms/suite_sub2.jpg"]');
/*!40000 ALTER TABLE `loai_phong` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES
(1,'0001_01_01_000000_create_users_table',1),
(2,'0001_01_01_000001_create_cache_table',1),
(3,'0001_01_01_000002_create_jobs_table',1),
(4,'2026_09_18_062217_create_hotel_tables',1),
(5,'2026_09_18_082322_create_personal_access_tokens_table',2),
(6,'2026_09_23_132504_add_details_to_loai_phong_table',3),
(7,'2026_09_23_133629_add_hinh_anh_phu_to_loai_phong_table',4),
(8,'2026_09_23_134310_add_hinh_anh_to_dich_vu_table',5),
(9,'2026_09_23_142405_add_loai_dich_vu_to_dich_vu_table',6),
(10,'2026_09_23_143744_create_loai_dich_vu_table',7),
(11,'2026_09_24_054913_add_trang_thai_thanh_toan_to_dat_phong_table',8),
(12,'2026_09_25_060417_add_trang_thai_to_su_dung_dich_vu_table',9),
(13,'2026_09_25_085520_add_so_tien_da_thanh_toan_to_dat_phong_table',10);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES
(1,'App\\Models\\User',2,'auth_token','116411350cbd3543018ae5c52ebe69fef3add5245e5b39f9255fab824f779993','[\"*\"]',NULL,NULL,'2026-09-18 08:23:43','2026-09-18 08:23:43'),
(2,'App\\Models\\User',1,'auth_token','5af5acb6419949e5b30a8ef3e9fcba241c439d20a3c034d9f2bde1ec003542eb','[\"*\"]','2026-10-02 10:55:13',NULL,'2026-09-18 08:29:48','2026-10-02 10:55:13'),
(3,'App\\Models\\User',1,'auth_token','e24907c6c6206c70e8dd298880454f1d9ed540b20df80aad808496cd331b7eaf','[\"*\"]','2026-10-11 13:07:14',NULL,'2026-09-23 00:57:06','2026-10-11 13:07:14'),
(4,'App\\Models\\User',1,'auth_token','4aba01074045ce3d6251d17c5146adea676611cd5b87c9623071f53709932964','[\"*\"]',NULL,NULL,'2026-09-23 01:49:03','2026-09-23 01:49:03'),
(5,'App\\Models\\User',1,'auth_token','2495fdf1a476d4ffcc2b24fc75e3aa39ebf3f64f3ac791ef0041914549f4621d','[\"*\"]','2026-09-23 01:49:51',NULL,'2026-09-23 01:49:18','2026-09-23 01:49:51'),
(6,'App\\Models\\User',1,'auth_token','9b4b0cc0fb5ee483bf75caf244e6d2410efa02657bfd2d69a3436d1dd055a7e2','[\"*\"]','2026-09-23 01:50:19',NULL,'2026-09-23 01:50:18','2026-09-23 01:50:19'),
(7,'App\\Models\\User',1,'test_token','d18612045c948dea01216713a681bc0228d2a41f6f47da04a31cbadef810472b','[\"*\"]',NULL,NULL,'2026-10-11 12:43:39','2026-10-11 12:43:39');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `phan_bo_phong`
--

DROP TABLE IF EXISTS `phan_bo_phong`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `phan_bo_phong` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `id_dat_phong` bigint unsigned NOT NULL,
  `id_phong` bigint unsigned NOT NULL,
  `thoi_gian_phan_bo` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `phan_bo_phong_id_dat_phong_foreign` (`id_dat_phong`),
  KEY `phan_bo_phong_id_phong_foreign` (`id_phong`),
  CONSTRAINT `phan_bo_phong_id_dat_phong_foreign` FOREIGN KEY (`id_dat_phong`) REFERENCES `dat_phong` (`id`) ON DELETE CASCADE,
  CONSTRAINT `phan_bo_phong_id_phong_foreign` FOREIGN KEY (`id_phong`) REFERENCES `phong` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `phan_bo_phong`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `phan_bo_phong` WRITE;
/*!40000 ALTER TABLE `phan_bo_phong` DISABLE KEYS */;
INSERT INTO `phan_bo_phong` VALUES
(13,13,1,'2026-09-25 17:52:26','2026-09-25 17:52:26','2026-09-25 17:52:26'),
(14,14,4,'2026-09-25 18:00:49','2026-09-25 18:00:49','2026-09-25 18:00:49'),
(15,15,5,'2026-09-25 18:22:46','2026-09-25 18:22:46','2026-09-25 18:22:46');
/*!40000 ALTER TABLE `phan_bo_phong` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `phong`
--

DROP TABLE IF EXISTS `phong`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `phong` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `so_phong` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_loai_phong` bigint unsigned NOT NULL,
  `id_tang` bigint unsigned NOT NULL,
  `trang_thai` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Trong',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `phong_id_loai_phong_foreign` (`id_loai_phong`),
  KEY `phong_id_tang_foreign` (`id_tang`),
  CONSTRAINT `phong_id_loai_phong_foreign` FOREIGN KEY (`id_loai_phong`) REFERENCES `loai_phong` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `phong_id_tang_foreign` FOREIGN KEY (`id_tang`) REFERENCES `tang` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `phong`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `phong` WRITE;
/*!40000 ALTER TABLE `phong` DISABLE KEYS */;
INSERT INTO `phong` VALUES
(1,'101',1,1,'Trong','2026-09-18 08:22:42','2026-09-25 17:52:07'),
(2,'102',1,1,'Trong','2026-09-18 08:22:42','2026-09-25 17:52:04'),
(3,'103',2,1,'Trong','2026-09-18 08:22:42','2026-09-24 05:28:34'),
(4,'201',3,2,'Trong','2026-09-18 08:22:42','2026-09-24 05:28:31'),
(5,'202',3,2,'Trong','2026-09-18 08:22:42','2026-09-24 05:28:28'),
(6,'203',4,2,'Trong','2026-09-18 08:22:42','2026-10-05 14:38:18');
/*!40000 ALTER TABLE `phong` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_tai_khoan` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_id_tai_khoan_index` (`id_tai_khoan`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `su_dung_dich_vu`
--

DROP TABLE IF EXISTS `su_dung_dich_vu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `su_dung_dich_vu` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `id_dat_phong` bigint unsigned NOT NULL,
  `id_phong` bigint unsigned DEFAULT NULL,
  `id_dich_vu` bigint unsigned NOT NULL,
  `so_luong` int NOT NULL,
  `tong_tien` decimal(15,2) NOT NULL,
  `trang_thai` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Cho_Phuc_Vu',
  `thoi_gian_su_dung` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `su_dung_dich_vu_id_dat_phong_foreign` (`id_dat_phong`),
  KEY `su_dung_dich_vu_id_phong_foreign` (`id_phong`),
  KEY `su_dung_dich_vu_id_dich_vu_foreign` (`id_dich_vu`),
  CONSTRAINT `su_dung_dich_vu_id_dat_phong_foreign` FOREIGN KEY (`id_dat_phong`) REFERENCES `dat_phong` (`id`) ON DELETE CASCADE,
  CONSTRAINT `su_dung_dich_vu_id_dich_vu_foreign` FOREIGN KEY (`id_dich_vu`) REFERENCES `dich_vu` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `su_dung_dich_vu_id_phong_foreign` FOREIGN KEY (`id_phong`) REFERENCES `phong` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `su_dung_dich_vu`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `su_dung_dich_vu` WRITE;
/*!40000 ALTER TABLE `su_dung_dich_vu` DISABLE KEYS */;
/*!40000 ALTER TABLE `su_dung_dich_vu` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `tai_khoan`
--

DROP TABLE IF EXISTS `tai_khoan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tai_khoan` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ho_ten` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `mat_khau` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `so_dien_thoai` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `vai_tro` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Khach_Hang',
  `dang_hoat_dong` tinyint(1) NOT NULL DEFAULT '1',
  `remember_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tai_khoan_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tai_khoan`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `tai_khoan` WRITE;
/*!40000 ALTER TABLE `tai_khoan` DISABLE KEYS */;
INSERT INTO `tai_khoan` VALUES
(1,'Administrator','admin@hotel.com',NULL,'$2y$12$cHnuwwZwA4JybBdt08hIFuid8ggkyxjpHSEr2XgJpvpIRDoTMb926','0987654321','Admin',1,NULL,'2026-09-18 08:22:42','2026-09-18 08:22:42'),
(2,'Khách Hàng','khachhang@hotel.com',NULL,'$2y$12$hm8TbMTUOj6aurHHkwJvx..XFN3m7d8WFUbmxkzsfJOuihIJhhm2K','0123456789','Khach_Hang',1,NULL,'2026-09-18 08:22:42','2026-09-18 08:22:42');
/*!40000 ALTER TABLE `tai_khoan` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `tang`
--

DROP TABLE IF EXISTS `tang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tang` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ten_tang` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `thu_tu` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tang`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `tang` WRITE;
/*!40000 ALTER TABLE `tang` DISABLE KEYS */;
INSERT INTO `tang` VALUES
(1,'Tầng 1',1,'2026-09-18 08:22:42','2026-09-18 08:22:42'),
(2,'Tầng 2',2,'2026-09-18 08:22:42','2026-09-18 08:22:42');
/*!40000 ALTER TABLE `tang` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `thanh_toan`
--

DROP TABLE IF EXISTS `thanh_toan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `thanh_toan` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `id_dat_phong` bigint unsigned NOT NULL,
  `so_tien_thanh_toan` decimal(15,2) NOT NULL,
  `phuong_thuc_thanh_toan` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `thoi_gian_thanh_toan` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `thanh_toan_id_dat_phong_foreign` (`id_dat_phong`),
  CONSTRAINT `thanh_toan_id_dat_phong_foreign` FOREIGN KEY (`id_dat_phong`) REFERENCES `dat_phong` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `thanh_toan`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `thanh_toan` WRITE;
/*!40000 ALTER TABLE `thanh_toan` DISABLE KEYS */;
/*!40000 ALTER TABLE `thanh_toan` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Dumping routines for database 'ql_khachsan'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-10-13  8:49:54

--
-- Table structure for table `cai_dat`
--

CREATE TABLE IF NOT EXISTS `cai_dat` (
  `khoa` VARCHAR(100) NOT NULL PRIMARY KEY,
  `gia_tri` TEXT NULL,
  `mo_ta` VARCHAR(255) NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `cai_dat` (`khoa`, `gia_tri`, `mo_ta`) VALUES
('ten_khach_san', 'Khách Sạn Grand Luxury', 'Tên khách sạn'),
('dia_chi', '123 Đường Bờ Biển, Đà Nẵng (sát bãi biển Mỹ Khê)', 'Địa chỉ'),
('so_dien_thoai', '1900 6868', 'Hotline lễ tân'),
('email', 'contact@grandluxury.vn', 'Email liên hệ'),
('khoang_cach_bien', '50 mét (chưa đầy 2 phút đi bộ)', 'Khoảng cách ra bãi tắm biển'),
('gio_check_in', '14:00', 'Giờ nhận phòng'),
('gio_check_out', '12:00', 'Giờ trả phòng'),
('ti_le_coc', '30', 'Tỷ lệ cọc giữ phòng (%)'),
('chinh_sach_huy', 'Miễn phí hủy/đổi lịch trước 48 giờ', 'Chính sách hủy phòng'),
('buffet_sang_gia', '150000', 'Giá vé Buffet sáng (VNĐ/người)'),
('buffet_sang_gio', '06:30 - 09:30', 'Khung giờ phục vụ Buffet sáng'),
('xe_san_bay_gia', '300000', 'Giá xe đưa đón sân bay 2 chiều (VNĐ/chuyến)'),
('thue_xe_may_gia', '120000', 'Giá thuê xe máy du lịch (VNĐ/ngày)'),
('giuong_phu_gia', '200000', 'Phí kê thêm giường phụ extra bed (VNĐ/đêm)'),
('ho_boi_mo_ta', 'Khách sạn chưa có hồ bơi riêng, nằm sát biển Mỹ Khê cách chỉ 50 mét.', 'Tình trạng hồ bơi'),
('bai_do_xe_mo_ta', 'Tầng hầm đỗ xe ô tô và xe máy MIỄN PHÍ 24/7 có bảo vệ trực.', 'Bãi đỗ xe')
ON DUPLICATE KEY UPDATE `mo_ta` = VALUES(`mo_ta`);
