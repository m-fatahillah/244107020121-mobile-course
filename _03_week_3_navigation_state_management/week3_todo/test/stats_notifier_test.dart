import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_todo/providers/stats_provider.dart';

void main() {
  group('StatsNotifier Unit Tests', () {
    test('State awal notifier harus berupa AsyncLoading', () {
      final container = ProviderContainer();

      // State harus AsyncLoading saat pertama kali provider dibaca
      final state = container.read(statsProvider);
      expect(state, isA<AsyncLoading<List<StatItem>>>());
    });

    test('Panggilan retry() mengubah state menjadi AsyncLoading kembali', () {
      final container = ProviderContainer();

      // Panggil fungsi retry() tanpa menunggunya (fire and forget untuk unit test statis)
      container.read(statsProvider.notifier).retry();

      // State harus langsung beralih ke AsyncLoading
      expect(container.read(statsProvider), isA<AsyncLoading<List<StatItem>>>());
    });
  });
}
