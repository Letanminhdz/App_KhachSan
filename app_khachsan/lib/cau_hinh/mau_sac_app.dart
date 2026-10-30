import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MauSacApp {
  // Bang mau phong cach khach san sang trong
  static const Color mauChinh = Color(0xFF1E3A8A); // Xanh Navy Hoang Gia
  static const Color mauChinhDam = Color(0xFF0F172A);
  static const Color mauChinhNhat = Color(0xFF3B82F6);
  static const Color mauDiemNhan = Color(0xFFD97706); // Vang Ho Phach
  static const Color mauDiemNhanNhat = Color(0xFFFDE68A);

  static const Color mauNen = Color(0xFFF8FAFC); // Trang xam nhe
  static const Color mauBeMat = Colors.white;
  static const Color mauBeMatPhu = Color(0xFFF1F5F9);

  static const Color mauChuChinh = Color(0xFF0F172A);
  static const Color mauChuPhu = Color(0xFF475569);
  static const Color mauChuMo = Color(0xFF94A3B8);

  static const Color mauThanhCong = Color(0xFF10B981); // Xanh ngoc
  static const Color mauLoi = Color(0xFFEF4444); // Do
  static const Color mauCanhBao = Color(0xFFF59E0B); // Vang cam

  static ThemeData get giaoDienSang {
    final kieuChuCoBan = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: mauChinh,
      scaffoldBackgroundColor: mauNen,
      colorScheme: ColorScheme.fromSeed(
        seedColor: mauChinh,
        primary: mauChinh,
        secondary: mauDiemNhan,
        surface: mauBeMat,
        error: mauLoi,
      ),
      textTheme: kieuChuCoBan.copyWith(
        displayLarge: kieuChuCoBan.displayLarge?.copyWith(
          color: mauChuChinh,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: kieuChuCoBan.titleLarge?.copyWith(
          color: mauChuChinh,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: kieuChuCoBan.titleMedium?.copyWith(
          color: mauChuChinh,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: kieuChuCoBan.bodyLarge?.copyWith(
          color: mauChuChinh,
        ),
        bodyMedium: kieuChuCoBan.bodyMedium?.copyWith(
          color: mauChuPhu,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: mauBeMat,
        foregroundColor: mauChuChinh,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: mauChuChinh,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: mauChuChinh),
      ),
      cardTheme: CardThemeData(
        color: mauBeMat,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: mauChinh,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: mauChinh,
          side: const BorderSide(color: mauChinh, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: mauBeMatPhu,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: mauChinh, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: mauLoi),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: mauChuMo,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: mauChuPhu,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
      ),
    );
  }
}
