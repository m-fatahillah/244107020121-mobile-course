# AI Challenge & Technical Verification Document
**Modul 06 — Authentication, Security & FCM**  
**Nama Mahasiswa:** Muhammad Fatahillah Athabrani  
**NIM:** 244107020121  
**Kelas:** TI 3F  

---

## 1. AI Prompt Challenge
Sesuai arahan praktikum, prompt berikut digunakan untuk menghasilkan fondasi arsitektur Push Service dan Autentikasi:

```text
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

---

## 2. Analisis Draf Awal AI & Evaluasi Kritis

Meskipun model AI mampu menghasilkan kerangka kerja awal dengan cepat, audit kode secara manual menemukan beberapa kelemahan kritis yang berisiko fatal jika langsung diterapkan ke lingkungan produksi:

### ⚠️ Temuan 1: Akses `BuildContext` & Provider dalam Isolate Latar Belakang
* **Kesalahan AI:** Draf awal AI mencoba memanggil `context.go()` atau mengakses Riverpod container di dalam fungsi `firebaseMessagingBackgroundHandler`.
* **Koreksi Manual:** `firebaseMessagingBackgroundHandler` dideklarasikan dengan anotasi `@pragma('vm:entry-point')` dan berjalan pada **isolate Dart terpisah** yang terisolasi dari UI engine. Mengakses `BuildContext` di sana akan memicu runtime crash. Penanganan navigasi wajib dipisahkan dan didelegasikan ke `onMessageOpenedApp` (background click) atau `getInitialMessage` (terminated startup) saat aplikasi berada di main isolate.

### ⚠️ Temuan 2: Kerentanan Keamanan Token (Logging & Storage)
* **Kesalahan AI:** Kode AI mencetak token secara gamblang menggunakan `print('FCM Token: $token')` dan merekomendasikan `SharedPreferences` untuk token sementara.
* **Koreksi Manual:** Sesuai prinsip **OWASP Mobile Top 10**, token otentikasi (JWT) dan token perangkat FCM tidak boleh dicetak ke log produksi atau disimpan dalam SharedPreferences (karena XML SharedPreferences tersimpan tanpa enkripsi di storage perangkat Android). Seluruh token disimpan di **`flutter_secure_storage`** (Android Keystore / iOS Keychain), dan antarmuka UI hanya menampilkan token terpotong (*masked token*, e.g. `c7x9a8f10b2e...7890`).

### ⚠️ Temuan 3: Ketiadaan Penanganan Izin Notifikasi Android 13+ (API 33)
* **Kesalahan AI:** AI hanya memanggil `FirebaseMessaging.instance.requestPermission()`.
* **Koreksi Manual:** Mulai Android 13 (Tiramisu, API 33), izin runtime `android.permission.POST_NOTIFICATIONS` wajib diminta secara eksplisit melalui plugin lokal (`flutter_local_notifications`), bukan hanya Firebase core. Jika tidak diminta, banner notifikasi lokal foreground tidak akan pernah tampil ke pengguna.

### ⚠️ Temuan 4: Risiko Infinite Loop pada 401 Interceptor Dio
* **Kesalahan AI:** Interceptor Dio mencoba me-refresh token tanpa mekanisme deteksi kegagalan refresh token.
* **Koreksi Manual:** Menambahkan blok pengaman: jika refresh token bernilai kosong, hilang, atau kadaluwarsa, sesi langsung dibersihkan (`await store.clear()`), `onForceLogout()` dipanggil, dan user dipaksa diarahkan kembali ke `/login` tanpa melakukan perulangan request tak terbatas.

### ⚠️ Temuan 5: Inkonsistensi Format Route Deep Link
* **Kesalahan AI:** AI langsung mengoper `message.data['route']` ke GoRouter. Jika payload backend tidak menyertakan leading slash (`pengumuman/3`), GoRouter akan melempar exception `Invalid location format`.
* **Koreksi Manual:** Mengekstrak parser murni `routeFromMessage(Map<String, dynamic> data)` yang menjamin string selalu diawali dengan slash `/` dan mengembalikan rute fallback default `/` jika data bernilai kosong atau null.

---

## 3. Matriks Perbedaan Platform (Android vs iOS)

| Aspek | Android | iOS |
| :--- | :--- | :--- |
| **Izin Notifikasi Runtime** | Wajib mulai Android 13 (API 33) via `POST_NOTIFICATIONS`. | Wajib sejak iOS 10 via `UNUserNotificationCenter` (`requestPermission`). |
| **Notification Channel** | Wajib dibuatkan `AndroidNotificationChannel` (id, nama, importance: high) agar banner muncul. | Menggunakan konfigurasi kategori dan `DarwinNotificationDetails`. |
| **Push Gateway** | Firebase Cloud Messaging (Google Play Services). | Apple Push Notification service (APNs) yang dijembatani oleh FCM. |
| **Penyimpanan Kredensial Aman** | Disimpan di Android Keystore dengan AES enkripsi. | Disimpan di iOS Keychain Services. |

---

## 4. AI Verification Checklist

- [x] **Secure Storage Only:** Seluruh token (access & refresh) disimpan via `flutter_secure_storage`.
- [x] **No Token Leakage:** Token tidak pernah dicetak utuh di konsol debug produksi atau antarmuka UI.
- [x] **Automated Token Refresh:** Dio interceptor mengulang request tepat 1 kali saat menerima 401, dan memaksa logout jika refresh token mati.
- [x] **Three App States Verified:** Pengujian terverifikasi pada state Foreground, Background, dan Terminated.
- [x] **Pure Route Parser:** Fungsi `routeFromMessage` berdiri sendiri dan lulus 100% unit test.
- [x] **Code Quality:** `dart analyze` bersih (`No issues found!`) dan `flutter test` lulus tanpa error.
