import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'message_parser.dart';

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

String? pendingDeepLink;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Top-level isolate handler: jangan akses BuildContext atau Riverpod di sini.
  // Menyimpan payload atau log terenkripsi bila diperlukan.
  debugPrint('FCM Background message received: ${message.messageId}');
}

class PushService {
  PushService._();
  static final PushService instance = PushService._();

  bool _isFirebaseAvailable = false;
  String _currentToken = 'c7x9a8f10b2e3d4c5b6a7890';
  final _tokenRefreshController = StreamController<String>.broadcast();
  final Set<String> _subscribedTopics = {'pengumuman-kampus'};

  String get currentToken => _currentToken;
  bool get isFirebaseAvailable => _isFirebaseAvailable;
  Set<String> get subscribedTopics => Set.unmodifiable(_subscribedTopics);

  Stream<String> get onTokenRefreshStream => _tokenRefreshController.stream;

  Future<void> initialize({void Function(String route)? onSelectNotification}) async {
    await _initLocalNotifications(onSelectNotification);

    try {
      if (Firebase.apps.isNotEmpty) {
        _isFirebaseAvailable = true;
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      }
    } catch (e) {
      debugPrint('Firebase not available or not configured: $e');
      _isFirebaseAvailable = false;
    }
  }

  Future<void> _initLocalNotifications(void Function(String route)? onSelectNotification) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          pendingDeepLink = payload;
          onSelectNotification?.call(payload);
        }
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'pengumuman',
          'Pengumuman Kampus',
          description: 'Notifikasi pengumuman resmi akademik dan kampus',
          importance: Importance.high,
        ),
      );
    }
  }

  Future<bool> requestNotificationPermission() async {
    bool granted = false;
    if (_isFirebaseAvailable) {
      try {
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          announcement: false,
          carPlay: false,
          criticalAlert: false,
        );
        granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
      } catch (_) {
        granted = false;
      }
    }

    // Android 13+ local notification permission
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final localGranted =
          await androidPlugin.requestNotificationsPermission() ?? false;
      granted = granted || localGranted;
    }

    return granted;
  }

  Future<void> initFcmToken({
    required Future<void> Function(String token) onToken,
  }) async {
    if (_isFirebaseAvailable) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          _currentToken = token;
          await onToken(token);
        }
        FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
          _currentToken = token;
          _tokenRefreshController.add(token);
          await onToken(token);
        });
        await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
        return;
      } catch (e) {
        debugPrint('FCM token fetch failed, using fallback simulated token: $e');
      }
    }

    // Fallback simulated lifecycle
    await onToken(_currentToken);
    onTokenRefreshStream.listen((token) async {
      await onToken(token);
    });
  }

  Future<void> simulateTokenRefresh({
    Future<void> Function(String token)? onToken,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _currentToken = 'fcm_${timestamp}_${_currentToken.substring(0, 8)}';
    _tokenRefreshController.add(_currentToken);
    if (onToken != null) {
      await onToken(_currentToken);
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    _subscribedTopics.add(topic);
    if (_isFirebaseAvailable) {
      try {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
      } catch (_) {}
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    _subscribedTopics.remove(topic);
    if (_isFirebaseAvailable) {
      try {
        await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      } catch (_) {}
    }
  }

  void listenForeground(void Function(String route) go) {
    if (_isFirebaseAvailable) {
      FirebaseMessaging.onMessage.listen((message) async {
        final route = routeFromMessage(message.data);
        await showLocalNotification(
          title: message.notification?.title ?? 'Pengumuman Kampus',
          body: message.notification?.body ?? '',
          route: route,
        );
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        final route = routeFromMessage(message.data);
        go(route);
      });
    }
  }

  Future<void> handleTerminated(void Function(String route) go) async {
    if (_isFirebaseAvailable) {
      try {
        final initial = await FirebaseMessaging.instance.getInitialMessage();
        if (initial != null) {
          go(routeFromMessage(initial.data));
          return;
        }
      } catch (_) {}
    }

    if (pendingDeepLink != null) {
      final route = pendingDeepLink!;
      pendingDeepLink = null;
      go(route);
    }
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    required String route,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'pengumuman',
      'Pengumuman Kampus',
      channelDescription: 'Notifikasi pengumuman resmi akademik dan kampus',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: route,
    );
  }
}
