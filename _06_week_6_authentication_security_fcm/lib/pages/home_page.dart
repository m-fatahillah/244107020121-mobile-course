import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';
import 'announcement_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _maskedToken = 'Memuat token...';

  @override
  void initState() {
    super.initState();
    _setupPushService();
  }

  Future<void> _setupPushService() async {
    // 1. Request permission
    await PushService.instance.requestNotificationPermission();

    // 2. Init FCM Token & Register to backend
    await PushService.instance.initFcmToken(
      onToken: (token) async {
        await ref.read(deviceRegistrationProvider.notifier).registerDevice(token);
        if (mounted) {
          setState(() {
            _maskedToken = _maskToken(token);
          });
        }
      },
    );

    // 3. Listen foreground
    PushService.instance.listenForeground((route) {
      if (mounted) context.go(route);
    });

    // 4. Handle terminated
    PushService.instance.handleTerminated((route) {
      if (mounted) context.go(route);
    });
  }

  String _maskToken(String token) {
    if (token.length <= 16) return token;
    return '${token.substring(0, 12)}...${token.substring(token.length - 4)}';
  }

  void _showFeedback(String msg, {bool isSuccess = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? Colors.green.shade800 : Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _simulateRotateToken() async {
    await PushService.instance.simulateTokenRefresh(
      onToken: (newToken) async {
        await ref
            .read(deviceRegistrationProvider.notifier)
            .registerDevice(newToken);
        if (mounted) {
          setState(() {
            _maskedToken = _maskToken(newToken);
          });
          _showFeedback(
              'onTokenRefresh berhasil: Token baru terdaftar ke backend!');
        }
      },
    );
  }

  Future<void> _testForegroundNotification() async {
    await PushService.instance.showLocalNotification(
      title: 'Jadwal Kuliah Berubah (Foreground)',
      body: 'Kelas Pemrograman Mobile pindah ke Ruang A2 jam 13.00',
      route: AppRoutes.announcementPath('1'),
    );
    _showFeedback('Notifikasi foreground dikirim! Periksa banner lokal.');
  }

  Future<void> _testBackgroundNotification() async {
    _showFeedback('Notifikasi akan muncul dalam 3 detik. Tekan tombol HOME sekarang!');
    Future.delayed(const Duration(seconds: 3), () async {
      await PushService.instance.showLocalNotification(
        title: 'Pengumuman Beasiswa (Background)',
        body: 'Sosialisasi Beasiswa Prestasi 2026. Klik untuk detail.',
        route: AppRoutes.announcementPath('2'),
      );
    });
  }

  Future<void> _testDioTokenRefresh() async {
    try {
      final store = ref.read(tokenStoreProvider);
      final auth = ref.read(authRepositoryProvider);
      final refresh = await store.readRefresh() ?? '';
      final newAccess = await auth.refresh(refresh);
      await store.save(access: newAccess, refresh: refresh);
      _showFeedback(
          'Simulasi 401 sukses: Access token berhasil diperbarui otomatis via Dio Interceptor!');
    } catch (e) {
      _showFeedback('Refresh token gagal: $e', isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reg = ref.watch(deviceRegistrationProvider);
    final subscribedTopics = ref.watch(topicsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Student Info Profile Card
          Card(
            elevation: 0,
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: theme.colorScheme.primary,
                    child: const Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Muhammad Fatahillah Athabrani',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'NIM: 244107020121 • Kelas TI 3F',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.security, size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              'Secure Storage: Token Terenkripsi',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // FCM Token & Backend Device Registration
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.phone_android,
                          size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Device FCM Token Lifecycle',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.vpn_key_outlined, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _maskedToken,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Masked',
                            style: TextStyle(
                              color: Colors.green.shade900,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        reg != null ? Icons.cloud_done : Icons.cloud_queue,
                        size: 16,
                        color: reg != null ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        reg != null
                            ? 'POST /devices terkirim (Platform: ${reg.platform})'
                            : 'Mendaftarkan ke backend...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: reg != null
                              ? Colors.green.shade800
                              : theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.sync_outlined, size: 16),
                      label: const Text('Simulasi onTokenRefresh (Rotasi Token)'),
                      onPressed: _simulateRotateToken,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Topic Messaging Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.topic_outlined,
                          size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Langganan Topik Kampus',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Topic messaging digunakan untuk broadcast massal mahasiswa tanpa menyimpan token perorangan.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const Divider(height: 20),
                  _buildTopicTile(
                    title: 'pengumuman-kampus',
                    subtitle: 'Broadcast seluruh civitas akademika Polinema',
                    topic: 'pengumuman-kampus',
                    isSubscribed: subscribedTopics.contains('pengumuman-kampus'),
                  ),
                  _buildTopicTile(
                    title: 'ti-3f',
                    subtitle: 'Broadcast khusus mahasiswa kelas TI 3F',
                    topic: 'ti-3f',
                    isSubscribed: subscribedTopics.contains('ti-3f'),
                  ),
                  _buildTopicTile(
                    title: 'beasiswa',
                    subtitle: 'Info pembukaan beasiswa dan hibah kompetisi',
                    topic: 'beasiswa',
                    isSubscribed: subscribedTopics.contains('beasiswa'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Uji 3 App State & Refresh Interceptor Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.science_outlined,
                          size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Pengujian 3 App State & Interceptor',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        icon: const Icon(Icons.fullscreen, size: 16),
                        label: const Text('1. Uji Foreground'),
                        onPressed: _testForegroundNotification,
                      ),
                      FilledButton.tonalIcon(
                        icon: const Icon(Icons.minimize, size: 16),
                        label: const Text('2. Uji Background (3s)'),
                        onPressed: _testBackgroundNotification,
                      ),
                      FilledButton.tonalIcon(
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('3. Uji 401 & Dio Refresh'),
                        onPressed: _testDioTokenRefresh,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Announcements Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Pengumuman Kampus',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Deep link ready',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ...mockAnnouncements.values.map(
            (item) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    item.id,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${item.category} • ${item.date}',
                  style: TextStyle(color: theme.colorScheme.outline),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(AppRoutes.announcementPath(item.id)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTopicTile({
    required String title,
    required String subtitle,
    required String topic,
    required bool isSubscribed,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: isSubscribed,
      onChanged: (val) {
        ref.read(topicsProvider.notifier).toggle(topic);
        _showFeedback(
          val
              ? 'Berhasil berlangganan topik "$topic"'
              : 'Berhenti berlangganan topik "$topic"',
        );
      },
    );
  }
}
