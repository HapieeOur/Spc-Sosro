import 'package:flutter/material.dart';

/// Token warna SPC Sosro Pallet Counter sesuai konsep "Lembar Tally Gudang"
class AppColors {
  AppColors._();

  // Dasar
  static const daun = Color(0xFF245C3E); // Primer: tombol utama, barang masuk, tab aktif
  static const daunTua = Color(0xFF143A27); // Latar hero header, teks di atas daun muda
  static const daunMuda = Color(0xFFDCE9DF); // Latar terpilih, chip aktif, sel berubah
  static const kertas = Color(0xFFF2F4F1); // Latar halaman (scaffold)
  static const permukaan = Color(0xFFFFFFFF); // Wadah daftar, form, sheet
  static const tinta = Color(0xFF1D2621); // Teks utama
  static const abuTinta = Color(0xFF59635D); // Teks sekunder, label
  static const garis = Color(0xFFD3D9D2); // Pemisah dan batas 1dp
  static const kayu = Color(0xFFA9855A); // Alas palet
  static const kayuTua = Color(0xFF7C5F3B); // Garis & bayangan palet kayu

  // Semantik
  static const biruTruk = Color(0xFF2C5B8E); // Barang keluar
  static const biruTrukMuda = Color(0xFFDDE8F3); // Latar barang keluar
  static const kuningMarka = Color(0xFFB87F00); // Visual indikator stok di bawah minimum
  static const kuningMarkaMuda = Color(0xFFFBEFC9); // Latar peringatan stok
  static const teksPeringatan = Color(0xFF7A5300); // Teks di atas latar peringatan
  static const bata = Color(0xFFA63423); // Galat, tindakan merusak (batal, nonaktif)
  static const bataMuda = Color(0xFFF7DDD8); // Latar galat

  // Aliases untuk kompatibilitas kode
  static const primary900 = daunTua;
  static const primary700 = daun;
  static const primary600 = Color(0xFF2E754F);
  static const primary100 = daunMuda;
  static const primary50 = Color(0xFFF4F8F5);
  static const surface = permukaan;
  static const background = kertas;
  static const border = garis;
  static const textPrimary = tinta;
  static const textSecondary = abuTinta;
  static const textMuted = Color(0xFF7D8781);
  static const info = biruTruk;
  static const infoBg = biruTrukMuda;
  static const success = daun;
  static const successBg = daunMuda;
  static const warning = kuningMarka;
  static const warningBg = kuningMarkaMuda;
  static const danger = bata;
  static const dangerBg = bataMuda;
  static const neutral100 = Color(0xFFE8ECE7);
}
