import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeAsync = ref.watch(darkModeProvider);
    final lastOpenedAsync = ref.watch(lastOpenedProvider);
    final isForceOffline = ref.watch(forceOfflineProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan & Preferensi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Tampilan & Tema (SharedPreferences)',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    darkModeAsync.value == true
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: darkModeAsync.value == true
                        ? Colors.amber
                        : Colors.orange,
                  ),
                  title: const Text('Mode Gelap (Dark Mode)'),
                  subtitle: const Text('Tersimpan di SharedPreferences lokal'),
                  value: darkModeAsync.value ?? false,
                  onChanged: (val) {
                    ref.read(darkModeProvider.notifier).toggle();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history_rounded),
                  title: const Text('Waktu Terakhir Dibuka'),
                  subtitle: lastOpenedAsync.when(
                    data: (timestamp) {
                      if (timestamp == null) {
                        return const Text('Baru pertama kali dibuka');
                      }
                      final dt = DateTime.tryParse(timestamp);
                      if (dt == null) return Text(timestamp);
                      return Text(
                        DateFormat('dd MMMM yyyy, HH:mm:ss').format(dt.toLocal()),
                      );
                    },
                    loading: () => const Text('Memuat riwayat...'),
                    error: (error, stack) => const Text('Gagal memuat'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Simulasi Offline-First',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SwitchListTile(
              secondary: Icon(
                isForceOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                color: isForceOffline ? Colors.deepOrange : Colors.green,
              ),
              title: const Text('Paksa Mode Offline (forceOffline)'),
              subtitle: const Text(
                'Simulasi deterministik tanpa tergantung status Wi-Fi/koneksi perangkat',
              ),
              value: isForceOffline,
              onChanged: (val) {
                ref.read(forceOfflineProvider.notifier).toggle();
              },
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Informasi Praktikum',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modul 05 — Local Storage & Offline First',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(height: 8),
                  Text('Nama: Muhammad Fatahillah Athabrani'),
                  SizedBox(height: 4),
                  Text('NIM: 244107020121'),
                  SizedBox(height: 4),
                  Text('Kelas: TI 3F / D4 Teknik Informatika'),
                  SizedBox(height: 4),
                  Text('Teknologi: Riverpod 3 + SQLite (sqflite) + SharedPreferences'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
