# Laporan Modul 02 — Declarative UI, Responsive Layout & Accessibility in Flutter

Repositori ini mendokumentasikan pengerjaan modul praktikum ke-2, mencakup pemahaman widget dasar, eksplorasi adaptabilitas antarmuka (*responsive design*), refactoring *clean code*, hingga perancangan arsitektur perbandingan layout bersama AI.

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
3. [Praktikum 1 — Pemahaman Layout Dasar & Constraint](#3-praktikum-1--pemahaman-layout-dasar--constraint)
4. [Praktikum 2 — Implementasi Dashboard Adaptif & Manajemen Tema](#4-praktikum-2--implementasi-dashboard-adaptif--manajemen-tema)
5. [Tugas Utama — Pengembangan Academic Overview](#5-tugas-utama--pengembangan-academic-overview)
6. [Tugas Khusus — Eksplorasi Desain & Komparasi AI](#6-tugas-khusus--eksplorasi-desain--komparasi-ai)
7. [Refactoring & Standarisasi Kode](#7-refactoring--standarisasi-kode)
8. [Pengujian Otomatis (Widget Testing)](#8-pengujian-otomatis-widget-testing)
9. [Instruksi Menjalankan Aplikasi](#9-instruksi-menjalankan-aplikasi)
10. [Rangkuman Akhir](#10-rangkuman-akhir)

---

## 1. Ikhtisar Pembelajaran
Pengembangan antarmuka di Flutter berlandaskan paradigma **Declarative UI**, di mana tampilan (*view*) merupakan representasi langsung dari *state* saat ini ($UI = f(state)$). Pada praktikum ini, dipelajari secara mendalam:
* Bagaimana aturan batas ukuran (*constraints go down, sizes go up, parent sets position*) bekerja pada widget `Row`, `Column`, dan `Expanded`.
* Pemanfaatan `LayoutBuilder` untuk mendeteksi kapasitas ruang aktual layar secara presisi.
* Desain responsif yang dapat berganti struktur secara luwes antara 1 kolom (layar ponsel) dan 2 kolom (layar tablet/desktop).
* Penerapan standar aksesibilitas WCAG melalui widget `Semantics` agar antarmuka ramah terhadap pengguna difabel (*screen reader* & *high text scaling*).

---

## 2. Hierarki Direktori Proyek
```text
responsive_dashboard/
├── README.md                               <- Laporan komprehensif praktikum & tugas
├── lib/
│   └── main.dart                           <- Implementasi utama Academic Overview
├── test/
│   └── widget_test.dart                    <- Pengujian responsif layar sempit & lebar
├── Screenshot/                             <- Dokumentasi visual eksekusi aplikasi
│   ├── warm up 1.png
│   ├── warm up 2.png
│   ├── warm up 3.png
│   ├── tampilan awal dashboard responsif.png
│   ├── 1. ubah nilai breakpoint.png
│   ├── 2. theme mode dark.png
│   ├── 2.2 theme mode.sistem.png
│   ├── 3.ukuran layar emulator yang berbeda..png
│   ├── 4. semantics talkback.png
│   ├── tugas utama.png
│   ├── hasil AI PROMT 1.png
│   ├── hasil AI PROMT 2.png
│   ├── hasil AI PROMT 3.png
│   ├── hasil AI PROMT 4.png
│   └── checklist verifikasi.png
└── tugas_ai_promt_chalenge/                <- Proyek mandiri komparasi layout AI & login portal
    ├── lib/
    │   ├── main.dart
    │   ├── models/academic_data.dart
    │   ├── widgets/academic_widgets.dart
    │   └── screens/
    │       ├── login_screen.dart
    │       ├── dashboard_grid_view.dart
    │       ├── dashboard_layout_builder.dart
    │       └── tradeoff_screen.dart
    └── test/
        └── widget_test.dart
```

---

## 3. Praktikum 1 — Pemahaman Layout Dasar & Constraint

Pada tahap pemanasan (*warm-up*), dibuat komponen profil sederhana untuk mengamati interaksi antar widget fleksibel dan batas render (*render constraints*).

### Analisis Hasil Eksperimen:
1. **Peran `Expanded` pada Baris Identitas:**
   * Ketika nama mahasiswa berukuran panjang dan `Expanded` dihilangkan, `Row` tidak dapat menampung lebar teks sehingga terjadi *RenderFlex Overflow (garis kuning-hitam)*. Dengan menyematkan `Expanded`, `Row` secara otomatis mengalokasikan sisa ruang yang valid dan membungkus teks secara aman.
2. **Karakteristik `MainAxisSize.min` vs `MainAxisSize.max`:**
   * Penyetelan `mainAxisSize: MainAxisSize.min` membuat `Column` hanya mengambil tinggi sebesar total komponen anak di dalamnya. Jika diubah ke `MainAxisSize.max`, `Column` akan memanjang vertikal secara agresif menghabiskan tinggi layar Scaffold.
3. **Penyisipan Field Kontak (Email):**
   * Menambahkan baris identitas baru memanfaatkan kombinasi `Row` + `Expanded(child: Text('Email'))` + `Text(...)`.

### Dokumentasi Visual Warm-Up:

* **Warm-Up 1 — Rangka Dasar Komponen:**
  ![Warm Up 1](Screenshot/warm%20up%201.png)

* **Warm-Up 2 — Uji Batasan Ruang Konten:**
  ![Warm Up 2](Screenshot/warm%20up%202.png)

* **Warm-Up 3 — Penambahan Baris Kontak:**
  ![Warm Up 3](Screenshot/warm%20up%203.png)

---

## 4. Praktikum 2 — Implementasi Dashboard Adaptif & Manajemen Tema

Memulai perancangan *Student Dashboard* yang cerdas membaca lebar perangkat pengguna secara dinamis menggunakan `LayoutBuilder` dan `GridView.count`.

### Inti Penerapan Teknis:
* **Logika Kolom Dinamis:**
  Menggunakan `LayoutBuilder` untuk mengevaluasi `constraints.maxWidth`. Apabila layar berukuran $\ge 700\text{px}$ maka grid menampilkan 2 kolom, sedangkan untuk layar $< 700\text{px}$ disajikan dalam 1 kolom penuh.
* **Integrasi `CupertinoSwitch`:**
  Aplikasi ditingkatkan menjadi `StatefulWidget` agar dapat mengontrol state pergantian tema *Light/Dark Mode* secara langsung melalui sakelar bergaya iOS (`CupertinoSwitch`) di `AppBar`.

### Dokumentasi Eksperimen Adaptabilitas:

* **Tampilan Awal Student Dashboard:**
  ![Tampilan Awal](Screenshot/tampilan%20awal%20dashboard%20responsif.png)

* **Eksperimen 1 — Perubahan Nilai Breakpoint:**
  ![Breakpoint](Screenshot/1.%20ubah%20nilai%20breakpoint.png)

* **Eksperimen 2 — Mode Gelap (Dark Mode):**
  ![Theme Dark](Screenshot/2.%20theme%20mode%20dark.png)

* **Eksperimen 3 — Mode Mengikuti Pengaturan Sistem:**
  ![Theme Sistem](Screenshot/2.2%20theme%20mode.sistem.png)

* **Eksperimen 4 — Uji Coba Multi Dimensi Layar:**
  ![Emulator](Screenshot/3.ukuran%20layar%20emulator%20yang%20berbeda..png)

* **Eksperimen 5 — Evaluasi Aksesibilitas Pembaca Layar (TalkBack):**
  ![Semantics](Screenshot/4.%20semantics%20talkback.png)

---

## 5. Tugas Utama — Pengembangan Academic Overview

Mengembangkan dashboard praktikum menjadi satu kesatuan halaman **Academic Overview** yang siap pakai dengan spesifikasi fungsional:
* **Kartu Profil Mahasiswa:** Memuat Avatar inisial dengan latar belakang kontras, Nama Mahasiswa (`Fatah`), NIM (`244107020121`), dan Program Studi (`Teknik Informatika`).
* **Empat Kartu Metrik Akademik:**
  1. *IPK Kumulatif* $\rightarrow$ `3.85` (Ikon `Icons.school_outlined`)
  2. *Total SKS Lulus* $\rightarrow$ `84 SKS` (Ikon `Icons.menu_book_outlined`)
  3. *Kehadiran Semester* $\rightarrow$ `94%` (Ikon `Icons.event_available_outlined`)
  4. *Tugas Menunggu* $\rightarrow$ `3 Item` (Ikon `Icons.assignment_late_outlined`)
* **Penggunaan Widget Reusable `InfoCard`:** Menghilangkan duplikasi markup dengan membuat satu widget independen yang menerima `title`, `value`, dan `icon`.
* **Kepatuhan Aksesibilitas:** Setiap kartu dibungkus dengan `Semantics(label: '$title: $value', readOnly: true)` untuk memberikan deskripsi suara yang jelas saat TalkBack aktif.

### Dokumentasi Tampilan Tugas Utama:
![Tugas Utama](Screenshot/tugas%20utama.png)

---

## 6. Tugas Khusus — Eksplorasi Desain & Komparasi AI

Sebagai bagian dari pendalaman materi, dilakukan eksplorasi komparasi arsitektural antarmuka bersama AI pada proyek [tugas_ai_promt_chalenge](tugas_ai_promt_chalenge).

promt saya : nah skarang gua punya tugas buat ngebandingin  tugas gua sama buatan AI, nah itu yang uda gua buat. skarang buat program buat lu sendiri di folder tugas_ai_promt yang isinya tata letak dashboard akademik untuk Flutter: versi GridView dan versi LayoutBuilder + Column. Jelaskan trade-off responsif dan aksesibilitasnya. untuk memperbagusnya lagi buat juga login formnya dengan tampilan yang aesthetic. dengan spesifikasi 1 role saja yakni buat mahasiswa

### Ringkasan Dialog & Pembahasan Teknis:

#### 1. Komparasi Arsitektur: `GridView` vs `LayoutBuilder + Column`
* **Pertanyaan:** Bagaimana perbandingan mendalam antara pendekatan `GridView` dan `LayoutBuilder + Column` dari segi fleksibilitas responsif serta aksesibilitas?
* **Insight & Keputusan:**
  * **Pendekatan `GridView`**: Sangat cepat untuk membuat kartu berulang yang seragam. Namun memiliki limitasi kaku pada `childAspectRatio`. Jika pengguna memperbesar ukuran font sistem (*Large Text Scaling*), kartu GridView rentan mengalami pemotongan teks atau *RenderFlex Bottom Overflow*.
  * **Pendekatan `LayoutBuilder + Column`**: Menentukan tinggi kartu secara alami (*intrinsic content height*). Sangat tangguh saat font diperbesar (>1.4x) karena kartu otomatis memanjang ke bawah tanpa batasan rasio, serta pembaca layar membaca hierarki per seksi secara runtut.

#### 2. Kapan `Expanded` Menyebabkan Error di dalam `Row`?
* **Pertanyaan:** Kapan pemakaian `Expanded` justru memicu overflow/error pada `Row`?
* **Insight:** `Expanded` menuntut adanya batas lebar pasti (*bounded horizontal constraint*). Jika `Row` ditaruh di dalam container dengan lebar tak terhingga (*unbounded width*), semisal di dalam `SingleChildScrollView(scrollDirection: Axis.horizontal)`, Flutter akan melempar error layout *infinite width*. Solusinya adalah membungkus anak dengan `SizedBox` bernilai eksplisit atau beralih ke `Flexible`.

#### 3. Audit Rekomendasi Layout & Stabilitas
* **Pertanyaan:** Memastikan layout stabil di bawah 600px dan tidak ada widget usang (*deprecated*).
* **Hasil:** Seluruh komponen (`LayoutBuilder`, `CustomScrollView`, `SliverGrid`, `Card`, `Semantics`) merupakan widget inti stabil Flutter.

### Dokumentasi Hasil Tangkapan Layar AI Challenge:

* **Tangkapan Layar AI Prompt 1:**
  ![AI Prompt 1](Screenshot/hasil%20AI%20PROMT%201.png)

* **Tangkapan Layar AI Prompt 2:**
  ![AI Prompt 2](Screenshot/hasil%20AI%20PROMT%202.png)

* **Tangkapan Layar AI Prompt 3 & 4:**
  ![AI Prompt 3](Screenshot/hasil%20AI%20PROMT%203.png)
  ![AI Prompt 4](Screenshot/hasil%20AI%20PROMT%204.png)

---

## 7. Refactoring & Standarisasi Kode

Proses perapian kode pada `lib/main.dart` difokuskan pada prinsip keterbacaan (*readability*), modularitas, dan pemeliharaan jangka panjang (*maintainability*):

1. **Modularitas Kartu (`InfoCard`):**
   ```dart
   class InfoCard extends StatelessWidget {
     const InfoCard({
       required this.title,
       required this.value,
       required this.icon,
       super.key,
     });

     final String title;
     final String value;
     final IconData icon;

     @override
     Widget build(BuildContext context) {
       final theme = Theme.of(context);
       return Semantics(
         label: '$title: $value',
         readOnly: true,
         child: Card(
           elevation: 1,
           child: Padding(
             padding: const EdgeInsets.all(16),
             child: Row(
               children: [
                 Icon(icon, size: 32, color: theme.colorScheme.primary),
                 const SizedBox(width: 16),
                 Expanded(
                   child: Text(
                     title,
                     style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                   ),
                 ),
                 Text(
                   value,
                   style: theme.textTheme.titleLarge?.copyWith(
                     fontWeight: FontWeight.bold,
                     color: theme.colorScheme.onSurface,
                   ),
                 ),
               ],
             ),
           ),
         ),
       );
     }
   }
   ```
2. **Penerapan Tema Dinamis:**
   Semua penentuan warna mengacu ke `Theme.of(context).colorScheme` dan tipografi mengacu ke `Theme.of(context).textTheme`, sehingga transisi mode terang dan gelap berjalan natural tanpa artefak warna yang tertinggal.
3. **Breakpoint Terpusat:**
   Breakpoint dipusatkan pada satu konstanta global `const double kWideBreakpoint = 700.0;` untuk memudahkan perubahan skala breakpoint di kemudian hari.
4. **Kualitas Kode:**
   Verifikasi analisis statis menggunakan `flutter analyze` menghasilkan:
   ```text
   Analyzing responsive_dashboard...
   No issues found! (ran in 1.5s)
   ```

---

## 8. Pengujian Otomatis (Widget Testing)

Pengujian dilakukan melalui berkas [`test/widget_test.dart`](test/widget_test.dart) dengan menyimulasikan dua skenario dimensi viewport:
1. **Layar Sempit (400 x 800 dp):** Memverifikasi kartu tersusun dalam 1 kolom vertikal (lebar kartu $< 700\text{px}$).
2. **Layar Lebar (1200 x 800 dp):** Memverifikasi kartu tersusun dalam 2 kolom sejajar (lebar kartu $> 500\text{px}$).

### Hasil Eksekusi `flutter test`:
```text
00:00 +0: loading D:/SEMESTER 5/MOBILE/244107020121-mobile-course/responsive_dashboard/test/widget_test.dart
00:00 +0: Dashboard satu kolom di layar sempit
00:00 +1: Dashboard dua kolom di layar lebar
00:00 +2: All tests passed!
```

---

## 9. Instruksi Menjalankan Aplikasi

### Menjalankan Project Utama (Academic Overview):
```bash
# Pindah ke direktori utama
cd responsive_dashboard

# Ambil dependensi
flutter pub get

# Jalankan aplikasi
flutter run
```

### Menjalankan Proyek AI Challenge (Portal Mahasiswa & Perbandingan Layout):
```bash
# Pindah ke direktori proyek challenge
cd responsive_dashboard/tugas_ai_promt_chalenge

# Ambil dependensi & jalankan
flutter pub get
flutter run
```

### Menjalankan Unit & Widget Test:
```bash
flutter test
```

---

## 10. Rangkuman Akhir

* [x] **Analisis Bebas Error:** `flutter analyze` tervalidasi 0 error & 0 warning (`No issues found!`).
* [x] **Pengujian Berhasil:** Seluruh skenario pada `flutter test` lulus 100% (`All tests passed!`).
* [x] **Ketahanan Responsif:** Tata letak terbukti adaptif di berbagai breakpoint ukuran layar.
* [x] **Dukungan Aksesibilitas:** Komponen antarmuka memenuhi kaidah WCAG dan terbaca jelas oleh pembaca layar.
* [x] **Dokumentasi Terstruktur:** Laporan pengerjaan disusun runtut disertai bukti visual yang komprehensif.

### Dokumentasi Checklist Verifikasi:
![Checklist Verifikasi](Screenshot/checklist%20verifikasi.png)
