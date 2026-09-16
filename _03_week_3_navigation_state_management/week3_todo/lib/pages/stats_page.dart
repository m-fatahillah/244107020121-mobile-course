import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';

/// StatsPage mengimplementasikan ConsumerWidget untuk membaca state dari Riverpod.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ATURAN 1: ref.watch HANYA digunakan di dalam method build untuk mendengarkan perubahan state secara reaktif.
    final AsyncValue<List<StatItem>> statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Statistik'),
        centerTitle: true,
      ),
      // ATURAN 2: Menggunakan .when() untuk memastikan ketiga state (loading, error, data) ditangani dengan lengkap.
      body: statsAsync.when(
        // 1. STATE LOADING: Menampilkan spinner (CircularProgressIndicator)
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Mengambil data statistik (delay 2 detik)...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        // 2. STATE ERROR: Menampilkan pesan error dan tombol 'Coba Lagi' (Retry)
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  error.toString().replaceFirst('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // ATURAN 3: ref.read digunakan di dalam event callback (onPressed),
                    // bukan ref.watch, untuk memanggil method aksi pada notifier.
                    ref.read(statsProvider.notifier).retry();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),

        // 3. STATE DATA (SUCCESS): Menampilkan ListView dengan 3 item statistik
        data: (statsList) => RefreshIndicator(
          onRefresh: () => ref.read(statsProvider.notifier).retry(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: statsList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final stat = statsList[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  title: Text(
                    stat.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    stat.value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
