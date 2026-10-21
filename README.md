# SPC Sosro Pallet Counter

Aplikasi Android untuk mencatat, menghitung, memantau, dan melaporkan stok palet serta dus produk secara terpusat.

Dibangun dengan **Flutter**, **Supabase Auth**, **Supabase PostgreSQL**, dan **Row Level Security (RLS)**. Satu aplikasi APK memiliki halaman untuk **Admin** dan **Operator**.

> **Status proyek:** perencanaan / blueprint teknis. Implementasi aplikasi belum dimulai. README ini menjadi acuan produk dan teknis untuk tahap Build.

---

## Daftar Isi

- [Tentang](#tentang)
- [Fitur](#fitur)
- [Peran Pengguna](#peran-pengguna)
- [Teknologi](#teknologi)
- [Arsitektur](#arsitektur)
- [Alur Perhitungan Stok](#alur-perhitungan-stok)
- [Struktur Proyek](#struktur-proyek)
- [Prasyarat](#prasyarat)
- [Persiapan Supabase](#persiapan-supabase)
- [Konfigurasi Aplikasi](#konfigurasi-aplikasi)
- [Menjalankan Aplikasi](#menjalankan-aplikasi)
- [Membuat APK](#membuat-apk)
- [Akun Admin Pertama](#akun-admin-pertama)
- [Skema Database](#skema-database)
- [Pengujian](#pengujian)
- [Keamanan](#keamanan)
- [Status dan Roadmap](#status-dan-roadmap)
- [Dokumentasi](#dokumentasi)
- [Lisensi](#lisensi)

---

## Tentang

SPC Sosro Pallet Counter adalah aplikasi operasional gudang untuk:

- mencatat barang masuk dan keluar;
- menghitung stok palet dan dus secara otomatis;
- memantau stok setiap produk secara terpisah;
- mencatat riwayat transaksi dan aktivitas operator;
- melakukan koreksi transaksi dengan jejak audit;
- membuat laporan barang masuk, keluar, stok harian, pergerakan produk, aktivitas, dan koreksi;
- mengekspor laporan ke CSV dan PDF.

Aplikasi menggunakan satu proyek Flutter dan satu APK. Tampilan dan hak akses pengguna ditentukan dari peran yang tersimpan di database.

---

## Fitur

### Operator

- Login email dan password.
- Dashboard stok hari ini.
- Ringkasan stok setiap produk.
- Form barang masuk.
- Form barang keluar.
- Transaksi berisi 1–5 produk sekaligus.
- Perhitungan total dus otomatis.
- Dukungan palet penuh, baris tambahan, dan dus lepas.
- Pratinjau sebelum menyimpan transaksi.
- Pencegahan transaksi ganda.
- Riwayat transaksi milik sendiri.
- Filter tanggal, produk, dan jenis transaksi.

### Admin

- Dashboard seluruh perusahaan.
- Melihat transaksi semua operator.
- Manajemen produk dan konfigurasi palet.
- Manajemen akun user, role, dan status.
- Koreksi transaksi dengan alasan.
- Pembatalan transaksi tanpa menghapus riwayat.
- Activity log.
- Laporan dan ekspor CSV/PDF.
- Pengaturan identitas perusahaan dan laporan.
- Peringatan stok rendah berdasarkan minimum stok per produk.

### Fitur database

- Peran `admin` dan `operator`.
- Row Level Security pada tabel operasional.
- Penulisan transaksi melalui RPC atomik.
- Pemeriksaan stok di database, bukan hanya di Flutter.
- Lock produk untuk mencegah stok negatif saat transaksi bersamaan.
- `client_request_id` untuk mencegah duplikasi transaksi.
- Snapshot nama dan konfigurasi produk pada detail transaksi.
- Audit sebelum/sesudah untuk koreksi dan perubahan stok awal.

---

## Peran Pengguna

| Kemampuan | Operator | Admin |
|---|:---:|:---:|
| Login aplikasi | Ya | Ya |
| Melihat dashboard | Ya | Ya |
| Melihat stok per produk | Ya | Ya |
| Membuat barang masuk | Ya | Ya |
| Membuat barang keluar | Ya | Ya |
| Melihat transaksi sendiri | Ya | Ya |
| Melihat transaksi semua operator | Tidak | Ya |
| Mengelola produk | Tidak | Ya |
| Mengelola user | Tidak | Ya |
| Koreksi dan pembatalan | Tidak | Ya |
| Activity log | Tidak | Ya |
| Laporan dan ekspor | Tidak | Ya |
| Pengaturan aplikasi | Tidak | Ya |

Pembatasan tidak hanya dilakukan dengan menyembunyikan menu. Database memeriksa role melalui RLS dan validasi RPC.

---

## Teknologi

| Komponen | Teknologi |
|---|---|
| Aplikasi mobile | Flutter, Dart |
| State management | Riverpod |
| Routing | go_router |
| Autentikasi | Supabase Auth |
| Database | Supabase PostgreSQL |
| Keamanan data | Row Level Security |
| Backend function | Supabase Edge Functions |
| Grafik | fl_chart |
| Laporan | CSV, PDF |
| Android | Android SDK, Gradle |

Lingkungan pengembangan yang sudah diperiksa:

- Flutter `3.47.7`
- Dart `3.13.5`
- OpenJDK `17`
- Android SDK `36`
- Supabase CLI melalui `npx supabase`

---

## Arsitektur

```text
Flutter Android
  ├── Auth & role-based routing
  ├── UI Operator / Admin
  ├── Riverpod + Repository
  └── Laporan CSV/PDF
          │
          ▼
Supabase
  ├── Auth
  ├── PostgreSQL + RLS
  ├── RPC transaksi dan laporan
  └── Edge Function admin-users
```

Prinsip utama:

1. Role diambil dari tabel `profiles`.
2. Semua penulisan data kritis melalui RPC.
3. Header dan detail transaksi disimpan dalam satu transaksi database.
4. Stok final selalu dihitung di database.
5. Service-role key hanya berada di Edge Function, tidak pernah di APK.
6. Transaksi tidak diedit atau dihapus diam-diam.

---

## Alur Perhitungan Stok

Stok disimpan dalam satuan **dus**.

### Total dus per baris transaksi

```text
total_boxes =
    ((full_pallets × rows_per_pallet_snapshot) + loose_rows)
    × boxes_per_row_snapshot
    + loose_boxes
```

Batasan:

```text
full_pallets >= 0
0 <= loose_rows < rows_per_pallet_snapshot
0 <= loose_boxes < boxes_per_row_snapshot
total_boxes > 0
```

Jika hanya menggunakan palet penuh:

```text
total dus = jumlah palet × jumlah baris per palet × jumlah dus per baris
```

### Saldo harian

```text
stok_awal(D) =
    saldo_awal
    + total masuk sebelum D
    - total keluar sebelum D

stok_akhir(D) =
    stok_awal(D)
    + masuk(D)
    - keluar(D)
```

Dengan demikian:

```text
stok_awal(D + 1) = stok_akhir(D)
```

Hanya transaksi berstatus `posted` yang dihitung. Transaksi `voided` dan `corrected` tidak memengaruhi stok valid.

### Tampilan palet dan dus

```text
boxes_per_pallet = rows_per_pallet × boxes_per_row
palet_penuh = stok_dus ÷ boxes_per_pallet
sisa_dus = stok_dus mod boxes_per_pallet
baris = sisa_dus ÷ boxes_per_row
dus_lepas = sisa_dus mod boxes_per_row
```

Contoh: konfigurasi 5 baris per palet dan 10 dus per baris menghasilkan 50 dus per palet. Stok 137 dus ditampilkan sebagai **2 palet, 3 baris, 7 dus**.

Produk berbeda selalu memiliki angka stok sendiri dan tidak digabung.

---

## Struktur Proyek

```text
spc_sosro_pallet_counter/
├── android/
├── assets/
├── supabase/
│   ├── migrations/
│   ├── functions/
│   │   └── admin-users/
│   └── bootstrap_admin.sql
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   ├── models/
│   ├── services/
│   ├── repositories/
│   ├── providers/
│   ├── screens/
│   │   ├── auth/
│   │   ├── user/
│   │   ├── admin/
│   │   └── shared/
│   └── widgets/
├── test/
├── docs/
├── env.json.example
├── analysis_options.yaml
└── pubspec.yaml
```

Detail struktur dan rancangan lengkap tersedia pada dokumen rencana:

```text
/home/hapiee/.opencode/plan/spc_sosro_pallet_counter_plan.md
```

---

## Prasyarat

Sebelum menjalankan proyek, pastikan perangkat sudah memiliki:

- Flutter SDK stable
- Dart SDK
- Android Studio dan Android SDK
- JDK 17
- VS Code dengan ekstensi Flutter dan Dart
- Akun Supabase
- Proyek Supabase (gratis atau berbayar)

Periksa instalasi:

```bash
flutter --version
flutter doctor -v
java -version
```

Pastikan `flutter doctor` tidak menunjukkan masalah pada Android toolchain.

---

## Persiapan Supabase

### 1. Membuat proyek

1. Masuk ke https://supabase.com/dashboard.
2. Buat proyek baru.
3. Catat **Project URL**.
4. Catat **publishable key** atau **anon key**.

Jangan menyalin atau membagikan **service-role key**.

### 2. Menjalankan migrasi

File migrasi berada di `supabase/migrations/` dan harus dijalankan berurutan:

```text
01 extensions dan enum
02 tabel dan constraint
03 function dan trigger
04 RPC transaksi
05 RPC admin
06 RPC laporan
07 RLS dan policy
08 seed produk
```

Pilih salah satu metode:

**Menggunakan SQL Editor Supabase**

Buka SQL Editor, tempel isi file migrasi secara berurutan, lalu jalankan.

**Menggunakan Supabase CLI**

```bash
npx supabase login
npx supabase link --project-ref <PROJECT_REF>
npx supabase db push
```

### 3. Mengatur autentikasi

Pada Supabase Dashboard:

1. Buka **Authentication → Providers → Email**.
2. Nonaktifkan pendaftaran publik.
3. Aktifkan konfirmasi email bila diperlukan.
4. Akun user baru dibuat oleh Admin melalui Edge Function.

### 4. Deploy Edge Function

```bash
npx supabase functions deploy admin-users
```

Edge Function menggunakan service-role key dari environment Supabase. Key tersebut tidak boleh dikirim ke aplikasi Flutter.

### 5. Mengisi konfigurasi produk

Produk awal:

- PAB1500
- PAB600
- PAB330
- PAP220
- 19L000 / Galon

Isi konfigurasi nyata untuk setiap produk sebelum transaksi pertama:

- jumlah baris per palet;
- jumlah dus per baris;
- minimum stok;
- status aktif.

Jangan menggunakan angka contoh sebagai konfigurasi produksi.

### 6. Mengatur stok awal

Admin menetapkan stok awal setiap produk melalui aplikasi atau RPC Admin. Perubahan saldo awal harus memiliki catatan dan tercatat di activity log.

---

## Konfigurasi Aplikasi

Salin contoh konfigurasi:

```bash
cp env.json.example env.json
```

Isi `env.json`:

```json
{
  "SUPABASE_URL": "https://PROJECT_REF.supabase.co",
  "SUPABASE_ANON_KEY": "PUBLISHABLE_OR_ANON_KEY"
}
```

`env.json` berisi konfigurasi publik yang memang dibutuhkan aplikasi. Jangan mengisi dengan service-role key.

Pastikan `env.json` tidak ikut di-commit:

```gitignore
env.json
key.properties
*.jks
*.keystore
```

---

## Menjalankan Aplikasi

Setelah proyek tersedia:

```bash
flutter pub get
flutter run --dart-define-from-file=env.json
```

Untuk memilih perangkat:

```bash
flutter devices
flutter run -d <DEVICE_ID> --dart-define-from-file=env.json
```

Alur awal:

1. Login dengan akun Admin pertama.
2. Periksa data produk.
3. Lengkapi konfigurasi palet dan stok awal.
4. Buat akun operator melalui menu Data User.
5. Login sebagai operator pada perangkat lain.

---

## Membuat APK

### APK debug

```bash
flutter build apk --debug --dart-define-from-file=env.json
```

Hasil:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

### APK release

Siapkan keystore dan konfigurasi signing terlebih dahulu. Jangan menyimpan password keystore di repository.

```bash
flutter build apk --release --dart-define-from-file=env.json
```

Hasil:

```text
build/app/outputs/flutter-apk/app-release.apk
```

### Memasang APK

Aktifkan **Install unknown apps** pada HP Android, lalu pasang APK melalui file manager atau:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Panduan build, signing, dan troubleshooting lengkap akan tersedia di:

```text
docs/05_BUILD_APK.md
docs/06_TROUBLESHOOTING.md
```

---

## Akun Admin Pertama

Admin pertama tidak dibuat melalui halaman publik pendaftaran.

Prosedur:

1. Buat user di **Supabase Dashboard → Authentication → Users**.
2. Catat email user tersebut.
3. Jalankan `supabase/bootstrap_admin.sql` dengan email yang sesuai.
4. Pastikan profil berubah menjadi role `admin`.
5. Login ke aplikasi.

Setelah Admin pertama aktif, akun berikutnya dibuat dari aplikasi melalui Edge Function `admin-users`.

Jangan:
- menyimpan password di tabel profil;
- membuat form pendaftaran Admin publik;
- memasukkan service-role key ke aplikasi;
- mengizinkan user mengubah role sendiri.

---

## Skema Database

Tabel utama:

| Tabel | Fungsi |
|---|---|
| `profiles` | Profil, email, role, dan status aktif pengguna |
| `products` | Produk dan konfigurasi palet |
| `stock_opening_balances` | Saldo awal per produk |
| `stock_transactions` | Header transaksi masuk/keluar |
| `stock_transaction_details` | Detail produk dalam transaksi |
| `transaction_corrections` | Snapshot koreksi transaksi |
| `activity_logs` | Audit aktivitas |
| `app_settings` | Pengaturan aplikasi |

RPC utama:

| RPC | Fungsi |
|---|---|
| `create_stock_transaction` | Membuat transaksi masuk/keluar secara atomik |
| `void_stock_transaction` | Membatalkan transaksi dengan alasan |
| `correct_stock_transaction` | Membuat transaksi pengganti dan audit |
| `admin_set_opening_balance` | Mengatur saldo awal |
| `admin_save_product` | Menyimpan produk |
| `admin_update_profile` | Mengubah profil user |
| `get_stock_summary` | Ringkasan stok per produk |
| `get_daily_stock_report` | Laporan stok harian |
| `get_dashboard_summary` | Data dashboard |
| `get_report_data` | Data laporan dan ekspor |

---

## Pengujian

Perintah dasar:

```bash
flutter analyze
flutter test
```

Skenario wajib:

1. Login Admin berhasil.
2. Login Operator berhasil.
3. Operator tidak dapat membuka route Admin.
4. Operator ditolak oleh RPC Admin.
5. Operator ditolak saat insert/update langsung.
6. Transaksi satu produk berhasil.
7. Transaksi lima produk berhasil.
8. Transaksi enam produk ditolak.
9. Total dus dan palet parsial benar.
10. Barang keluar melebihi stok ditolak.
11. Dua transaksi bersamaan tidak menghasilkan stok negatif.
12. Double submit tidak membuat transaksi ganda.
13. Riwayat dan stok harian berantai.
14. Filter tanggal, produk, operator, dan jenis transaksi bekerja.
15. Koreksi tercatat dengan snapshot.
16. Pembatalan tidak dihitung sebagai stok valid.
17. Perubahan stok awal memiliki log.
18. Data tetap ada setelah aplikasi dibuka ulang.
19. Kegagalan jaringan ditangani dengan retry yang aman.
20. User nonaktif kehilangan akses.
21. Ekspor CSV/PDF sama dengan data database.
22. APK debug dan release terpasang.

Panduan pengujian lengkap akan tersedia di `docs/04_PENGUJIAN.md`.

---

## Keamanan

- Autentikasi menggunakan Supabase Auth.
- Password tidak pernah disimpan di tabel `profiles`.
- RLS aktif pada seluruh tabel operasional.
- User hanya dapat membaca data sesuai perannya.
- Penulisan data transaksi hanya melalui RPC.
- Stok dihitung ulang dan dikunci di database.
- Service-role key hanya disimpan di environment server Edge Function.
- APK hanya memakai publishable/anon key.
- User tidak dapat mengubah role sendiri.
- Koreksi dan pembatalan memiliki alasan dan audit.
- Log tidak dapat diubah dari aplikasi.
- Token, password, dan data sensitif tidak ditulis ke log aplikasi.

Laporkan masalah keamanan kepada pengelola internal. Jangan membuka detail kredensial atau service-role key di issue publik.

---

## Status dan Roadmap

| Tahap | Status |
|---|---|
| M0 — Konfirmasi awal | Belum selesai |
| M1 — Database, RPC, RLS | Belum dimulai |
| M2 — Fondasi Flutter | Belum dimulai |
| M3 — Auth dan role guard | Belum dimulai |
| M4 — Modul operator | Belum dimulai |
| M5 — Modul admin | Belum dimulai |
| M6 — Laporan dan ekspor | Belum dimulai |
| M7 — QA, APK, dokumentasi | Belum dimulai |

Status akan diperbarui setelah implementasi berjalan.

---

## Dokumentasi

Dokumen yang direncanakan:

| File | Isi |
|---|---|
| `docs/01_INSTALASI.md` | Instalasi Flutter, Dart, VS Code, Android SDK |
| `docs/02_SETUP_SUPABASE.md` | Membuat proyek, migrasi, Auth, Edge Function |
| `docs/03_PANDUAN_PENGGUNAAN.md` | Panduan Admin dan Operator |
| `docs/04_PENGUJIAN.md` | Skenario pengujian dan uji keamanan |
| `docs/05_BUILD_APK.md` | Build debug/release dan signing |
| `docs/06_TROUBLESHOOTING.md` | Error umum dan cara memperbaikinya |

Dokumen perencanaan teknis:

```text
/home/hapiee/.opencode/plan/spc_sosro_pallet_counter_plan.md
```

---

## Lisensi

Aplikasi ini dirancang sebagai aplikasi internal perusahaan. Lisensi penggunaan dan distribusi belum ditentukan. Jangan mendistribusikan APK atau kode sumber tanpa izin pengelola proyek.
