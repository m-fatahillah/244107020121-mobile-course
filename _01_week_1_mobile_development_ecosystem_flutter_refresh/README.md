# Laporan Praktikum - Minggu 01: Mobile Development Ecosystem & Flutter Refresh

---

## Identitas Mahasiswa

- **Nama**: Muhammad Fatahillah Athabrani
- **NIM**: 244107020121
- **Mata Kuliah**: Pemrograman Mobile
- **Semester / Kelas**: 5
- **Topik Praktikum**: Mobile Development Ecosystem & Flutter Refresh

---

## Tujuan Praktikum

1. Mengenal dan mempersiapkan ekosistem pengembangan aplikasi mobile menggunakan Flutter SDK dan Dart.
2. Memahami struktur direktori proyek Flutter standar.
3. Menjalankan aplikasi Flutter pada perangkat fisik (*mobile device*) / emulator / browser.
4. Memahami konsep dasar *Widget Tree* serta penggunaan *widgets* dasar seperti `StatelessWidget`, `MaterialApp`, `Scaffold`, `AppBar`, `Center`, `Column`, `Icon`, `Text`, dan `SizedBox`.
5. Melakukan modifikasi antarmuka (*User Interface*) untuk menampilkan data identitas mahasiswa.

---

## Langkah-Langkah Pengerjaan

### 1. Inisialisasi & Verifikasi Proyek Flutter
- Memastikan environment Flutter telah terpasang dengan baik melalui perintah `flutter doctor`.
- Membuat proyek Flutter baru atau membuka workspace proyek `_01_week_1_mobile_development_ecosystem_flutter_refresh`.
- Menjalankan aplikasi awal ke perangkat menggunakan perintah `flutter run`.

### 2. Tampilan Awal (Sebelum Perubahan)
Pada tahap awal praktikum, aplikasi dijalankan untuk memastikan integrasi framework Flutter dan device target berjalan normal tanpa *error*.

---

### 3. Modifikasi File `lib/main.dart`
File [main.dart](file:///d:/SEMESTER%205/MOBILE/244107020121-mobile-course/_01_week_1_mobile_development_ecosystem_flutter_refresh/lib/main.dart) dimodifikasi untuk menampilkan halaman profil mahasiswa yang memuat Nama, NIM, ikon kampus, dan teks motivasi/informasi tambahan.

Berikut adalah kode lengkap `lib/main.dart`:

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Profil Mahasiswa'),
        ),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school, size: 72),
              SizedBox(height: 16),
              Text(
                'Muhammad Fatahillah Athabrani',
                style: TextStyle(fontSize: 24),
              ),
              Text(
                '244107020121', 
                style: TextStyle(fontSize: 24),
              ),
              Text('CALON ORANG SUKSES'),
              Text('Pemrograman Mobile — Minggu 1'),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Kendala
Hampir tidak ada kendala dalam praktikum ini, mungkin hanya waktu load flutter awal saja yang hampir menghabiskan waktu 30 menit, tapi setelah itu tidak lama lagi

## Hasil dan Bukti Praktikum (Screenshots)

### 1. Tampilan Awal (Sebelum Perubahan)
Tampilan aplikasi Flutter sebelum dilakukan kustomisasi dan penambahan NIM serta informasi tambahan:

![Tampilan Awal Sebelum Perubahan](./Screenshot/gambar%20awal%20sebelum%20perubahan%20dan%20penambahan%20nim%20serta%201%20informasi%20lain.png)

---

### 2. Tampilan Akhir (Setelah Perubahan)
Tampilan aplikasi setelah dilakukan perubahan kode pada `lib/main.dart` yang berhasil menampilkan profil mahasiswa:

![Tampilan Setelah Perubahan](./Screenshot/gambar%202%20setelah%20perubahan.png)

---

## Kesimpulan

1. Lingkungan pengembangan Flutter dan perangkat pengujian telah berhasil disiapkan dan dikonfigurasi.
2. Flutter menggunakan paradigma *declarative UI* di mana tampilan dibangun berdasarkan hierarki widget (*widget tree*).
3. Penggunaan widget dasar seperti `Column`, `Center`, `Text`, `Icon`, dan `SizedBox` di dalam `Scaffold` memungkinkan penyusunan tata letak antarmuka yang rapi, responsif, dan mudah dipahami.
4. Fitur *Hot Reload* pada Flutter sangat mempermudah dan mempercepat proses iterasi pengembangan aplikasi *mobile*.
