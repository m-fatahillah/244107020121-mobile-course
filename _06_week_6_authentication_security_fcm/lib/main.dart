import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi push service dan local notifications
  await PushService.instance.initialize();

  runApp(
    const ProviderScope(
      child: CampusNotifyApp(),
    ),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authStateProvider);
  final loggedIn = authAsync.value ?? false;

  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final goingLogin = state.matchedLocation == AppRoutes.login;

      // Jika belum terautentikasi dan tidak menuju login -> arahkan ke /login
      if (!loggedIn && !goingLogin) return AppRoutes.login;

      // Jika sudah terautentikasi dan berada di login -> arahkan ke / (home)
      if (loggedIn && goingLogin) return AppRoutes.home;

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.announcement,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '1';
          return AnnouncementPage(id: id);
        },
      ),
    ],
  );
});

class CampusNotifyApp extends ConsumerWidget {
  const CampusNotifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Campus Notify Polinema',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B4F6C),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      routerConfig: router,
    );
  }
}
