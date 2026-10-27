import 'package:flutter/material.dart';

/// Token warna SPC Sinar Sosro & Gunung Slamat (a REKSO Company)
/// Konsep Merah-Putih elegan bernuansa teh botol Sosro (hangat, tidak mencolok/ngejreng, dengan gradasi)
class AppColors {
  AppColors._();

  // Warna Utama Brand (Sinar Sosro Ruby Red & Rekso Identity)
  static const merahSosro = Color(0xFF9E171B); // Merah ruby hangat, matang, tidak ngejreng
  static const merahTua = Color(0xFF660B0E); // Merah wine/burgundy pekat untuk hero header
  static const merahMuda = Color(0xFFFDF2F2); // Soft rose tint untuk chip dan highlight
  static const kertas = Color(0xFFF8F9FA); // Latar scaffold bersih berkelas
  static const permukaan = Color(0xFFFFFFFF); // Putih bersih untuk kartu dan lembar sheet
  static const tinta = Color(0xFF1F2937); // Teks utama hitam arang berkontras tinggi
  static const abuTinta = Color(0xFF4B5563); // Teks sekunder, label
  static const garis = Color(0xFFE5E7EB); // Pemisah halus 1dp
  static const kayu = Color(0xFFA9855A); // Alas palet
  static const kayuTua = Color(0xFF7C5F3B); // Garis & bayangan palet kayu

  // Gradasi Ciri Khas Perusahaan
  static const heroGradient = LinearGradient(
    colors: [Color(0xFF5E090B), Color(0xFF8F1216), Color(0xFF700D10)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const primaryButtonGradient = LinearGradient(
    colors: [Color(0xFFA31A1E), Color(0xFF881014)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const cardHeaderGradient = LinearGradient(
    colors: [Color(0xFFFDF8F8), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const accentGradient = LinearGradient(
    colors: [Color(0xFF9E171B), Color(0xFFBD2227)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Semantik Transaksi & Gudang
  static const biruTruk = Color(0xFF1D4ED8); // Barang keluar
  static const biruTrukMuda = Color(0xFFEFF6FF); // Latar barang keluar
  static const kuningMarka = Color(0xFFD97706); // Peringatan stok di bawah minimum
  static const kuningMarkaMuda = Color(0xFFFFFBEB); // Latar peringatan stok
  static const teksPeringatan = Color(0xFF92400E); // Teks di atas latar peringatan
  static const bata = Color(0xFFDC2626); // Galat, tindakan merusak (batal, nonaktif)
  static const bataMuda = Color(0xFFFEF2F2); // Latar galat

  // Aliases untuk kompatibilitas kode di seluruh proyek
  static const daun = merahSosro; // Primer aplikasi (Merah Sosro)
  static const daunTua = merahTua; // Hero header aplikasi (Merah Tua)
  static const daunMuda = merahMuda; // Highlight aplikasi (Merah Muda)
  static const primary900 = merahTua;
  static const primary700 = merahSosro;
  static const primary600 = Color(0xFFB51E23);
  static const primary100 = merahMuda;
  static const primary50 = Color(0xFFFFF7F7);
  static const surface = permukaan;
  static const background = kertas;
  static const border = garis;
  static const textPrimary = tinta;
  static const textSecondary = abuTinta;
  static const textMuted = Color(0xFF9CA3AF);
  static const info = biruTruk;
  static const infoBg = biruTrukMuda;
  static const success = Color(0xFF15803D);
  static const successBg = Color(0xFFDCFCE7);
  static const warning = kuningMarka;
  static const warningBg = kuningMarkaMuda;
  static const danger = bata;
  static const dangerBg = bataMuda;
  static const neutral100 = Color(0xFFF3F4F6);
}
