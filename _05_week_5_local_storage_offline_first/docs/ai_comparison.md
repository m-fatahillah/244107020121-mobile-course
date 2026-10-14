# Laporan AI Prompt Challenge & Verifikasi Storage Lokal

Dokumen ini mendokumentasikan hasil pengujian prompt AI, komparasi storage lokal pada Flutter, verifikasi teknis, serta justifikasi keputusan arsitektur untuk aplikasi *Offline Notes*.

---

## 1. Prompt AI yang Digunakan

```text
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema. Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift untuk dua kebutuhan ini. Requirements: 
- Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream), type-safety, ukuran boilerplate, dan kemudahan testing. 
- Beri rekomendasi final: mana untuk preferensi, mana untuk catatan, beserta alasannya dalam 1 tabel. 
- Tunjukkan skema tabel/kotak untuk 1000+ catatan. Jelaskan trade-off setiap pilihan.
```

---

## 2. Output Respon Awal AI (Simulasi / Hasil Generasi AI)

### A. Tabel Komparasi Pilihan Storage

| Kriteria | SharedPreferences | Hive (NoSQL Box) | sqflite (SQLite Raw) | Drift (SQLite Type-safe) |
| :--- | :--- | :--- | :--- | :--- |
| **Model Data** | Key-Value sederhana | Key-Value / Document Object | Relasional (SQL Tables) | Relasional (SQL Tables via Dart DSL) |
| **Kompleksitas Query** | Sangat rendah (hanya `get/set` per key) | Rendah–Sedang (Filter in-memory / index) | Tinggi (Full SQL, JOIN, ORDER, LIMIT, WHERE) | Sangat Tinggi (SQL & Type-safe Dart Query Builder) |
| **Kebutuhan Relasi** | Tidak mendukung | Manual linking / foreign key manual | Didukung penuh via `FOREIGN KEY` & JOIN | Didukung penuh via relasi antar entitas |
| **Reaktivitas (Stream)** | Tidak ada bawaan (perlu wrapper/polling) | Tersedia (`ValueListenable`, watch box) | Manual (biasanya digabung Riverpod / StreamController) | Bawaan (`watch()` queries menghasilkan Stream) |
| **Type-Safety** | Lemah (berbasis key string) | Sedang (menggunakan TypeAdapter code-gen) | Lemah (Map<String, dynamic>, butuh parsing manual) | Sangat Tinggi (Dihasilkan otomatis dari skema tabel) |
| **Boilerplate & Setup** | Nol/Sangat Rendah (langsung pakai) | Rendah–Sedang (Registrasi adapter & Hive.init) | Sedang (Tulis raw SQL `CREATE TABLE`, `toMap/fromMap`) | Tinggi (Butuh `build_runner`, code generation, `drift_dev`) |
| **Kemudahan Testing** | Mudah (mock `SharedPreferences.setMockInitialValues`) | Mudah–Sedang (in-memory boxes) | Mudah (in-memory sqlite / abstraction via repository) | Mudah (in-memory sqlite via `NativeDatabase.memory()`) |
| **Performa 1000+ Catatan** | Sangat lambat jika serialisasi satu string JSON besar | Sangat cepat untuk read in-memory; write bertahap | Cepat, efisien memori berkat pagination (`LIMIT/OFFSET`) | Sangat cepat & efisien, optimasi query bawaan |

---

### B. Usulan Skema Tabel (1000+ Catatan)

#### 1. Skema SQLite / Drift (Relasional)
```sql
CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);

-- Index untuk mempercepat pengurutan dan filter catatan kotor (sync queue)
CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC);
CREATE INDEX idx_notes_dirty ON notes(dirty);
```

#### 2. Skema Hive Box (NoSQL Document)
```dart
@HiveType(typeId: 0)
class NoteHive extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String body;

  @HiveField(3)
  late DateTime updatedAt;

  @HiveField(4)
  late bool dirty;
}
```

---

## 3. AI Verification Checklist & Temuan Kritis

Berdasarkan rekomendasi dan skema yang diberikan oleh AI, dilakukan pengujian dan verifikasi mendalam:

- [x] **Apakah AI menempatkan daftar catatan di SharedPreferences?**  
  **Status: DITOLAK.** AI sempat menyarankan kemudahan SharedPreferences untuk MVP, tetapi menyimpan koleksi 1000+ catatan ke satu key JSON di SharedPreferences adalah anti-pattern berat. Parsing seluruh JSON setiap aplikasi membaca atau memperbarui satu item akan membebani thread UI dan boros memori.
  
- [x] **Apakah skema AI mendukung antrean sync (dirty flag / updated_at) atau hanya CRUD polos?**  
  **Status: DIVERIFIKASI & DISEMPURNAKAN.** Skema dasar yang diusulkan telah menyertakan `dirty` (integer 0 atau 1) dan `updated_at` (ISO 8601 string). Kami menambahkan index `idx_notes_dirty` dan `idx_notes_updated_at` untuk memastikan query antrean sync `SELECT COUNT(*) WHERE dirty = 1` tetap berkecepatan $O(1)$ meski data catatan mencapai ribuan.
  
- [x] **Apakah klaim "real-time" AI didukung stream (Drift/watch) atau hanya asumsi?**  
  **Status: DIVERIFIKASI.** Klaim bahwa Drift memiliki stream didukung oleh query `watch()`. Namun, pada stack `sqflite + Riverpod`, reaktivitas yang identik dapat dicapai secara bersih melalui `ref.invalidate(notesProvider)` tanpa overhead code-generation Drift.
  
- [x] **Apakah estimasi boilerplate AI masuk akal setelah instalasi riil?**  
  **Status: DIVERIFIKASI.** Estimasi AI terbukti akurat:
  - `sqflite`: Cukup menambahkan package `sqflite` dan `path`. Tidak membutuhkan waktu kompilasi code-gen tambahan.
  - `Drift`: Memerlukan `drift`, `sqlite3_flutter_libs`, `drift_dev`, `build_runner`. Kompilasi memakan waktu lebih lama dan menambah ukuran binary.

---

## 4. Keputusan Final & Justifikasi Teknis

Berdasarkan analisis trade-off dan pengujian kebutuhan modul:

1. **Untuk Preferensi Aplikasi (Tema Gelap, Timestamp Terakhir Dibuka):**
   * **Pilihan:** `SharedPreferences`.
   * **Alasan:** Data berupa nilai primitif skalar (`bool`, `String`). Akses sangat cepat, asynchronous, tanpa kebutuhan relasi maupun query kompleks.
2. **Untuk Manajemen Catatan (CRUD, Offline-First, Cache):**
   * **Pilihan:** `SQLite` via `sqflite`.
   * **Alasan:** 
     - Mendukung query terstruktur, filter parsial, dan pengurutan (`ORDER BY updated_at DESC`).
     - Menyediakan indexing untuk dirty flag (`dirty = 1`), sangat esensial untuk antrean sinkronisasi background.
     - Tidak memerlukan overhead `build_runner` seperti Drift, sehingga siklus pengembangan lebih cepat dan pemahaman konsep dasar SQL lebih kuat.
     - Mudah diuji dan diinjeksi (*Dependency Injection*) menggunakan pola `openDb` function callback / FakeRepository.
