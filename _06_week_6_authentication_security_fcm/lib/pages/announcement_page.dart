import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes.dart';

class CampusAnnouncement {
  const CampusAnnouncement({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.date,
    required this.author,
  });

  final String id;
  final String title;
  final String body;
  final String category;
  final String date;
  final String author;
}

final Map<String, CampusAnnouncement> mockAnnouncements = {
  '1': const CampusAnnouncement(
    id: '1',
    title: 'Perubahan Jadwal Kuliah Pemrograman Mobile',
    body:
        'Diberitahukan kepada seluruh mahasiswa TI-3F bahwa perkuliahan Pemrograman Mobile hari Kamis dipindahkan ke Ruang Smart Classroom Lt. 7 Gedung Sipil jam 13.00 WIB.',
    category: 'Akademik',
    date: '15 Oktober 2026, 08:30 WIB',
    author: 'Bagian Akademik JTI',
  ),
  '2': const CampusAnnouncement(
    id: '2',
    title: 'Sosialisasi Beasiswa Prestasi & Unggulan 2026',
    body:
        'Pendaftaran Beasiswa Prestasi periode Ganjil 2026 telah dibuka. Mahasiswa yang memenuhi kriteria IPK min. 3.50 dapat mengunggah berkas portofolio melalui portal beasiswa kampus.',
    category: 'Beasiswa',
    date: '14 Oktober 2026, 14:15 WIB',
    author: 'Kemahasiswaan Polinema',
  ),
  '3': const CampusAnnouncement(
    id: '3',
    title: 'Workshop Cloud Messaging & Mobile Security',
    body:
        'Jurusan Teknologi Informasi mengadakan workshop implementasi Firebase Cloud Messaging dan Secure Storage pada aplikasi Flutter tingkat lanjut dengan narasumber dari industri.',
    category: 'Workshop',
    date: '12 Oktober 2026, 10:00 WIB',
    author: 'Laboratorium Mobile JTI',
  ),
};

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final item = mockAnnouncements[id] ??
        CampusAnnouncement(
          id: id,
          title: 'Pengumuman Kampus #$id',
          body:
              'Detail informasi resmi kampus untuk nomor pengumuman $id. Pastikan Anda membaca ketentuan yang berlaku di jurusan.',
          category: 'Pengumuman',
          date: '15 Oktober 2026',
          author: 'Pusat Informasi Kampus',
        );

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengumuman'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 18,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.category,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: theme.colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  item.date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.person_outline,
                    size: 14, color: theme.colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  item.author,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              item.body,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Verifikasi Deep Link GoRouter',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rute target: /pengumuman/$id\nNavigasi berhasil ditangani melalui GoRouter path parameter dari data payload FCM {route: /pengumuman/$id}.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Kembali ke Dashboard'),
                onPressed: () => context.go(AppRoutes.home),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
