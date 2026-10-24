# Praktikum Aplikasi Mobile

Kumpulan praktikum dan tugas mata kuliah **Aplikasi Mobile** menggunakan **Flutter** dan **Dart**, mulai dari form input sederhana hingga aplikasi pencatatan keuangan dengan beberapa halaman.

| Identitas | Keterangan |
| --- | --- |
| Nama | Habibi Putra Rizqullah |
| NIM | 2411531001 |
| Kelas | A |
| Repository | [ApMob_A_2411531001_Habibi-Putra-Rizqullah](https://github.com/habibiputrar/ApMob_A_2411531001_Habibi-Putra-Rizqullah) |

## Daftar Pertemuan

Setiap pertemuan disimpan dalam folder tersendiri di dalam `lib/`. Branch `main` memuat gabungan Pertemuan 01–05, sedangkan branch setiap pertemuan menyimpan tahap pengerjaannya.

| Pertemuan | Materi dan Implementasi | Folder | Branch |
| --- | --- | --- | --- |
| 01 | Form input dengan `TextField`, validasi `TextFormField`, dan kalkulator Kabataku | [pertemuan_01](lib/pertemuan_01/) | [pertemuan-01](https://github.com/habibiputrar/ApMob_A_2411531001_Habibi-Putra-Rizqullah/tree/pertemuan-01) |
| 02 | Pengenalan widget, penyusunan layout, styling, dan tampilan dashboard keuangan | [pertemuan_02](lib/pertemuan_02/) | [pertemuan-02](https://github.com/habibiputrar/ApMob_A_2411531001_Habibi-Putra-Rizqullah/tree/pertemuan-02) |
| 03 | Form transaksi, validasi input, kategori, serta tanggal pada bagian tugas; tersedia latihan login terpisah | [pertemuan_03](lib/pertemuan_03/) | [pertemuan-03](https://github.com/habibiputrar/ApMob_A_2411531001_Habibi-Putra-Rizqullah/tree/pertemuan-03) |
| 04 | Navigasi antara dashboard, form tambah transaksi, dan detail transaksi | [pertemuan_04](lib/pertemuan_04/) | [pertemuan-04](https://github.com/habibiputrar/ApMob_A_2411531001_Habibi-Putra-Rizqullah/tree/pertemuan-04) |
| 05 | Login simulasi, tab Beranda–Riwayat–Profil, pencatatan transaksi, perhitungan saldo, dan logout | [pertemuan_05](lib/pertemuan_05/) | [pertemuan-05](https://github.com/habibiputrar/ApMob_A_2411531001_Habibi-Putra-Rizqullah/tree/pertemuan-05) |

## Struktur Folder

```text
lib/
├── pertemuan_01/
│   ├── form-textfield.dart
│   ├── textformfield.dart
│   └── kalkulator_kabataku.dart
├── pertemuan_02/
│   ├── modul1_widgets/
│   │   ├── Praktikum/
│   │   └── Tugas/
│   └── modul2_layouts/
│       ├── Praktikum/
│       └── Tugas/
├── pertemuan_03/
│   ├── Praktikum/
│   └── Tugas/
├── pertemuan_04/
│   ├── Praktikum/
│   └── Tugas/
└── pertemuan_05/
```

## Persiapan

- Flutter SDK dengan Dart yang sesuai dengan `pubspec.yaml` (`^3.13.2`).
- Android SDK dan emulator Android, atau perangkat Android dengan USB debugging aktif.
- Git untuk mengunduh repository.
- Editor seperti Android Studio atau Visual Studio Code.

Unduh repository dan siapkan dependensi dari folder yang berisi `pubspec.yaml`:

```bash
git clone https://github.com/habibiputrar/ApMob_A_2411531001_Habibi-Putra-Rizqullah.git
cd ApMob_A_2411531001_Habibi-Putra-Rizqullah
flutter pub get
```

Periksa lingkungan pengembangan dan perangkat yang tersedia:

```bash
flutter doctor
flutter devices
flutter emulators
```

## Menjalankan Praktikum

Repository ini menggunakan beberapa entry point. Jalankan file yang dipilih melalui opsi `-t`, karena tidak tersedia entry point gabungan pada `lib/main.dart`.

Gunakan pola perintah berikut, lalu ganti `<entry-point>` dengan path dari tabel di bawah:

```bash
flutter run -t <entry-point>
```

Untuk memilih perangkat tertentu, ambil ID dari `flutter devices`, lalu ganti `<device-id>` pada perintah berikut:

```bash
flutter run -d <device-id> -t <entry-point>
```

Pilih entry point sesuai pertemuan dan latihan yang ingin dijalankan.

| Pertemuan | Latihan | Entry Point |
| --- | --- | --- |
| 01 | Form TextField | [lib/pertemuan_01/form-textfield.dart](lib/pertemuan_01/form-textfield.dart) |
| 01 | Validasi TextFormField | [lib/pertemuan_01/textformfield.dart](lib/pertemuan_01/textformfield.dart) |
| 01 | Kalkulator Kabataku | [lib/pertemuan_01/kalkulator_kabataku.dart](lib/pertemuan_01/kalkulator_kabataku.dart) |
| 02 | Widget — Praktikum | [lib/pertemuan_02/modul1_widgets/Praktikum/main.dart](lib/pertemuan_02/modul1_widgets/Praktikum/main.dart) |
| 02 | Widget — Tugas | [lib/pertemuan_02/modul1_widgets/Tugas/main.dart](lib/pertemuan_02/modul1_widgets/Tugas/main.dart) |
| 02 | Layout — Praktikum | [lib/pertemuan_02/modul2_layouts/Praktikum/main.dart](lib/pertemuan_02/modul2_layouts/Praktikum/main.dart) |
| 02 | Layout — Tugas | [lib/pertemuan_02/modul2_layouts/Tugas/main.dart](lib/pertemuan_02/modul2_layouts/Tugas/main.dart) |
| 03 | Form transaksi — Praktikum | [lib/pertemuan_03/Praktikum/main.dart](lib/pertemuan_03/Praktikum/main.dart) |
| 03 | Form transaksi — Tugas | [lib/pertemuan_03/Tugas/main.dart](lib/pertemuan_03/Tugas/main.dart) |
| 03 | Latihan login terpisah | [lib/pertemuan_03/Praktikum/login_page.dart](lib/pertemuan_03/Praktikum/login_page.dart) |
| 04 | Navigasi — Praktikum | [lib/pertemuan_04/Praktikum/main.dart](lib/pertemuan_04/Praktikum/main.dart) |
| 04 | Navigasi — Tugas | [lib/pertemuan_04/Tugas/main.dart](lib/pertemuan_04/Tugas/main.dart) |
| 05 | Expense Tracker | [lib/pertemuan_05/main.dart](lib/pertemuan_05/main.dart) |

## Pemeriksaan Kode

Untuk memeriksa kode pada seluruh folder praktikum:

```bash
flutter analyze lib
```

Untuk memeriksa satu pertemuan saja, ganti `lib` dengan path folder pertemuan tersebut.

## Referensi

- [Dokumentasi Flutter](https://docs.flutter.dev/)
- [Belajar Dart](https://dart.dev/language)
- [Katalog Widget Flutter](https://docs.flutter.dev/ui/widgets)
