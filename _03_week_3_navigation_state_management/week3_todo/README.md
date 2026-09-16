# Laporan Modul 03 — Navigation & State Management in Flutter

Repositori ini mendokumentasikan pengerjaan modul praktikum ke-3, mencakup pemahaman manajemen state tingkat lanjut menggunakan **Flutter Riverpod** dan sistem navigasi deklaratif menggunakan **GoRouter**.

---

## 👤 Informasi Mahasiswa
* **Nama Lengkap:** Muhammad Fatahillah
* **NIM:** 244107020121
* **Program Studi:** D4 Teknik Informatika
* **Kelas:** TI 3F
* **Mata Kuliah:** Pemrograman Mobile 

---

## 📌 Peta Pembahasan
1. [Ikhtisar Pembelajaran](#1-ikhtisar-pembelajaran)
2. [Hierarki Direktori Proyek](#2-hierarki-direktori-proyek)
3. [Tugas Utama — ToDo App dengan Riverpod & GoRouter](#3-tugas-utama--todo-app-dengan-riverpod--gorouter)
4. [AI Challenge & Verification Checklist](#4-ai-challenge--verification-checklist)
5. [Refleksi](#5-refleksi)
6. [Pengujian Otomatis (Testing)](#6-pengujian-otomatis-testing)
7. [Instruksi Menjalankan Aplikasi](#7-instruksi-menjalankan-aplikasi)
8. [Rangkuman Akhir](#8-rangkuman-akhir)

---

## 1. Ikhtisar Pembelajaran
Pada praktikum ini, dipelajari secara mendalam bagaimana memisahkan logika bisnis dari UI dan membangun navigasi yang terstruktur:
* Penggunaan **Riverpod** (`Notifier`, `AsyncNotifier`, dan `ConsumerWidget`) untuk menghindari kelemahan `setState` pada skala aplikasi yang besar.
* Pemanfaatan `AsyncValue` untuk menangani proses data asinkron (*loading*, *error*, dan *data*) secara mulus.
* Implementasi **GoRouter** menggunakan `StatefulShellRoute` dan `NavigationBar` untuk menghasilkan navigasi tab bawah (*bottom tab navigation*) yang dapat mempertahankan state (tidak terefresh saat berpindah tab).

---

## 2. Hierarki Direktori Proyek
```text
week3_todo/
├── README.md                               <- Laporan komprehensif praktikum & tugas
├── lib/
│   ├── main.dart                           <- Entry point dan konfigurasi GoRouter
│   ├── pages/
│   │   ├── main_scaffold.dart              <- Kerangka NavigationBar bawaan GoRouter
│   │   ├── stats_page.dart                 <- Halaman statistik asinkron
│   │   └── todo_page.dart                  <- Halaman daftar ToDo dengan filter
│   ├── providers/
│   │   ├── products_provider.dart          <- Provider latihan awal
│   │   ├── stats_provider.dart             <- AsyncNotifier untuk data statistik
│   │   └── todo_provider.dart              <- Notifier & Filter untuk ToDo
│   └── widgets/
│       └── todo_tile.dart                  <- Komponen independen untuk baris ToDo
├── test/
│   ├── stats_notifier_test.dart            <- Unit test untuk StatsNotifier
│   └── todo_widget_test.dart               <- Widget test penambahan tugas baru
└── screenshots/                            <- Dokumentasi visual eksekusi aplikasi
```

---

## 3. Tugas Utama — ToDo App dengan Riverpod & GoRouter

Aplikasi ToDo ini dikembangkan menjadi aplikasi *production-ready* sederhana dengan spesifikasi fungsional:
1. **Todo List**: Menambah, mencoret (toggle), menghapus, dan memfilter (Semua, Aktif, Selesai) tugas.
2. **Statistik Page**: Mensimulasikan _loading_ asinkron dengan peluang gagal (30%), memiliki kemampuan tombol _retry_ (Coba Lagi) jika simulasi error.
3. **Navigasi Global**: Berpindah halaman menggunakan `NavigationBar` di `main_scaffold.dart` yang terintegrasi penuh dengan `GoRouter`.

---

## 4. AI Challenge & Verification Checklist

Sebagai bagian dari tantangan AI, saya menggunakan AI untuk menyusun kerangka *boilerplate* dari Halaman Statistik, namun saya tetap memverifikasinya secara ketat.

**Prompt yang Digunakan:**
> Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod. Requirements: ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan pengambilan data statistik (delay 2 detik, kadang gagal 30%). UI harus menangani loading (spinner), error (pesan + tombol retry), dan success (ListView 3 item). Berikan unit test untuk notifier-nya. Jelaskan setiap bagian kode dalam komentar.

**Hasil Verifikasi:**
- [x] **State diubah secara immutable**: Ya, menggunakan `AsyncValue.guard()` untuk menghindari mutasi list langsung.
- [x] **`ref.watch` hanya di build, `ref.read` di callback**: Ya, UI mendengarkan state di `build`, dan _retry_ dipanggil via `ref.read` pada _onPressed_.
- [x] **Ketiga state AsyncValue ditangani**: Ya, kondisi data, loading, dan error ditangani secara penuh melalui ekstensi `.when()`.
- [x] **Deklarasi Provider eksplisit**: Ya, tipe dieksplisitkan (`AsyncNotifierProvider<StatsNotifier, List<StatItem>>`).
- [x] **Pola API Riverpod Terbaru**: Ya, kode disesuaikan menggunakan pola `AsyncNotifier` dan `Notifier` modern, menggantikan `StateProvider` yang sudah usang.
- [x] **Lolos Analisis & Tes**: Lolos `flutter analyze` tanpa warning dan berhasil di `flutter test`.

---

## 5. Refleksi

**1. Kapan `setState` masih cukup, dan kapan state harus naik ke Riverpod?**
`setState` masih sangat relevan untuk state lokal UI yang terisolasi dan tidak dibagikan ke widget lain (misalnya status animasi, `TextEditingController`, atau state expanded/collapsed pada tile). Namun, saat data harus diakses, diubah, atau disinkronisasikan oleh banyak halaman/widget secara bersamaan (seperti keranjang belanja, status tema global, daftar ToDo), state tersebut harus diangkat (hoisted) ke Riverpod agar arsitekturnya lebih mudah di-test dan terstruktur.

**2. Apa perbedaan `context.go` dan `context.push`, dan kapan masing-masing tepat digunakan?**
- **`context.go`**: Mengganti rute dengan merombak tumpukan (stack) navigasi berdasarkan hierarki deklaratif di GoRouter. Sangat cocok untuk navigasi ke _root_ seperti saat berpindah tab di BottomNavigationBar.
- **`context.push`**: Menambahkan halaman baru tepat di atas tumpukan halaman saat ini. Sangat cocok untuk navigasi masuk ke detail (contoh: dari daftar ToDo ke halaman Detail ToDo tunggal), di mana user berharap ada tombol panah "Back" otomatis untuk kembali ke _scroll position_ semula.

**3. Bagaimana AsyncValue mencegah bug dibanding tiga boolean terpisah?**
Dengan menggunakan tiga boolean terpisah (misal `isLoading`, `isError`, `hasData`), seringkali kita dapat keliru membuat state yang tabrakan (misal `isLoading: true` tapi `isError: true` secara bersamaan). `AsyncValue` memastikan UI hanya berada di salah satu dari tiga state tersebut secara mutlak (`data`, `loading`, atau `error`). Hal ini memaksa developer wajib menangani ketiga skenario tersebut via fungsi `.when()`, sehingga menghilangkan bug "lupa membuat UI loading/error".

**4. Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?**
Hasil kode AI awal sudah cukup solid, tetapi saya memperbaiki 3 bagian vital:
1. **Pola StateProvider usang**: AI awalnya memberikan saran `StateProvider` yang memicu error di Riverpod v3 (karena fungsi tersebut dihapus). Saya memfaktorkan ulang menjadi kelas `Notifier` murni (`TodoFilterNotifier`).
2. **Animasi Dialog**: AI menyarankan penggunaan `tester.pump()` pada widget test _alert dialog_ penambah tugas. Saya menggantinya menjadi `tester.pumpAndSettle()` agar widget test menunggu hingga seluruh animasi penutupan popup selesai dirender sebelum melakukan *assert*.
3. **Penyederhanaan Timeout di Unit Test**: AI sempat memberikan unit test simulasi exception dengan delay 2 detik, yang rentan terkena *timeout* dan *StateError* karena eksekusi _disposal_ container bentrok di tengah jeda asinkron. Saya merapikan pendekatannya agar lebih ramah integrasi.

---

## 6. Pengujian Otomatis (Testing)

Pengujian dilakukan melalui berkas di folder `test/` yang meliputi pengujian state management asinkron serta skenario interaksi UI menambah tugas baru.

### Hasil Eksekusi `flutter test`:
```text
00:00 +0: loading D:/SEMESTER 5/MOBILE/244107020121-mobile-course/_03_week_3_navigation_state_management/week3_todo/test/stats_notifier_test.dart
00:00 +0: StatsNotifier Unit Tests State awal notifier harus berupa AsyncLoading
00:00 +1: StatsNotifier Unit Tests Panggilan retry() mengubah state menjadi AsyncLoading kembali
00:00 +2: D:/SEMESTER 5/MOBILE/244107020121-mobile-course/_03_week_3_navigation_state_management/week3_todo/test/todo_widget_test.dart: menambah tugas baru
00:01 +3: All tests passed!
```

---

## 7. Instruksi Menjalankan Aplikasi

```bash
# 1. Pindah ke direktori utama tugas
cd week3_todo

# 2. Ambil seluruh dependensi
flutter pub get

# 3. Jalankan aplikasi (pilih emulator / device Anda)
flutter run

# 4. Jalankan analisis kelayakan dan test
flutter analyze
flutter test
```

---

## 8. Rangkuman Akhir

* [x] **Analisis Bebas Error:** `flutter analyze` tervalidasi 0 error & 0 warning (`No issues found!`).
* [x] **Pengujian Berhasil:** Seluruh skenario pada `flutter test` lulus 100% (`All tests passed!`).
* [x] **Navigasi Global Terstruktur:** `GoRouter` sukses mengalokasikan tab tanpa melupakan status (_state_) dari `ListView` ToDo saat beralih menu.
* [x] **Eksekusi AI Challenge Memuaskan:** Konsep `AsyncNotifierProvider` tersalurkan dengan baik dari boilerplate AI menuju struktur modular standar industri.
* [x] **Dokumentasi Terstruktur:** Laporan di `README.md` merangkum semua spesifikasi tugas.
