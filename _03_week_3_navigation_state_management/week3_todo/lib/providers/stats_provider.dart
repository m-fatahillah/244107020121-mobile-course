import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model sederhana untuk merepresentasikan satu item statistik.
/// Bersifat immutable (semua field bersifat final).
class StatItem {
  final String title;
  final String value;

  const StatItem({required this.title, required this.value});
}

/// AsyncNotifier untuk mengelola state data statistik secara asinkron.
/// Menggunakan pola Riverpod 2.x/3.x yang modern dan aman (anti-pattern StateNotifier dihindari).
class StatsNotifier extends AsyncNotifier<List<StatItem>> {
  @override
  Future<List<StatItem>> build() async {
    // Dipanggil otomatis saat provider pertama kali diinisialisasi
    return _fetchData();
  }

  /// Fungsi privat untuk mensimulasikan pemanggilan API / server
  Future<List<StatItem>> _fetchData() async {
    // 1. Simulasi delay jaringan selama 2 detik
    await Future.delayed(const Duration(seconds: 2));

    // 2. Simulasi kemungkinan gagal sebesar 30%
    // Random().nextInt(10) menghasilkan angka 0..9. Angka 0, 1, 2 = 30% probabilitas.
    final random = Random();
    if (random.nextInt(10) < 3) {
      throw Exception('Gagal memuat statistik jaringan (Simulasi Error 30%)');
    }

    // 3. Mengembalikan list baru berisi 3 item data statistik (Immutable list)
    return const [
      StatItem(title: 'Total Pengguna', value: '12.450'),
      StatItem(title: 'Penjualan Hari Ini', value: 'Rp 8.750.000'),
      StatItem(title: 'Tugas Selesai', value: '94%'),
    ];
  }

  /// Fungsi untuk mencoba kembali (retry) pengambilan data
  /// Biasa dipanggil dari callback tombol 'Coba Lagi' di UI
  Future<void> retry() async {
    // Set state ke loading secara immutable tanpa memutasi data lama langsung
    state = const AsyncLoading();

    // AsyncValue.guard otomatis menangkap error dan mengonversinya menjadi AsyncError,
    // atau jika sukses akan menjadi AsyncData.
    state = await AsyncValue.guard(() => _fetchData());
  }
}

/// Deklarasi provider dengan tipe eksplisit agar type-safe dan mudah di-refactor.
final statsProvider = AsyncNotifierProvider<StatsNotifier, List<StatItem>>(
  StatsNotifier.new,
);
