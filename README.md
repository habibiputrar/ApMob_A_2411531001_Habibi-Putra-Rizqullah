# Expense Tracker

Aplikasi pencatatan keuangan berbasis Flutter yang menggabungkan materi Praktikum Aplikasi Mobile pertemuan 1–5.

| Identitas | Keterangan |
| --- | --- |
| Nama | Habibi Putra Rizqullah |
| NIM | 2411531001 |
| Kelas | A |
| Mata kuliah | Aplikasi Mobile |

Branch `gabungan-praktikum-1-5` berisi aplikasi gabungan. Source pertemuan terpisah tetap tersedia pada [branch main](https://github.com/habibiputrar/ApMob_A_2411531001_Habibi-Putra-Rizqullah/tree/main/lib).

## Fitur

- Register dan login lokal.
- Beranda dengan saldo, pemasukan, dan pengeluaran.
- Form transaksi dengan kategori, tanggal, dan validasi input.
- Riwayat, detail, edit, dan hapus transaksi.
- Profil, pengaturan saldo awal, dan logout.
- Kalkulator Kabataku.
- Penyimpanan SQLite untuk akun, sesi, transaksi, serta draft input.

Catatan transfer tidak mengubah saldo karena aplikasi belum menyediakan rekening asal dan tujuan.

## Struktur Source

```text
lib/
└── gabungan_praktikum/
    ├── main.dart
    ├── main_screen.dart
    ├── login_screen.dart
    ├── register_screen.dart
    ├── dashboard_screen.dart
    ├── history_screen.dart
    ├── add_transaction_screen.dart
    ├── transaction_detail_screen.dart
    ├── profile_screen.dart
    ├── edit_profile_screen.dart
    ├── loading_screen.dart
    ├── storage.dart
    ├── store_scope.dart
    ├── models/
    ├── widgets/
    ├── latihan/
    └── assets/
```

## Menjalankan Aplikasi

Siapkan Flutter SDK yang sesuai dengan `pubspec.yaml`, Android SDK, serta emulator atau perangkat Android.

```bash
flutter pub get
flutter run -t lib/gabungan_praktikum/main.dart
```

## Pengujian

```bash
flutter analyze lib/gabungan_praktikum
flutter test
```

## APK

[Unduh Expense Tracker v1.0.0](https://github.com/habibiputrar/ApMob_A_2411531001_Habibi-Putra-Rizqullah/releases/download/v1.0.0/expense-tracker-v1.0.0.apk) atau buka [halaman release](https://github.com/habibiputrar/ApMob_A_2411531001_Habibi-Putra-Rizqullah/releases/tag/v1.0.0).

Build debug dapat dijalankan tanpa kunci release. Untuk build release, siapkan `android/key.properties` dengan `storeFile`, `storePassword`, `keyAlias`, dan `keyPassword`, beserta keystore yang sesuai. Keystore dan konfigurasi privat diabaikan Git.

```bash
flutter build apk --release -t lib/gabungan_praktikum/main.dart
```
