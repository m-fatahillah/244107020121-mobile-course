import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/api_client.dart';
import '../data/auth_repository.dart';
import '../data/token_store.dart';
import '../messaging/push_service.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final apiClientProvider = Provider<Dio>((ref) {
  final store = ref.watch(tokenStoreProvider);
  final auth = ref.watch(authRepositoryProvider);
  return buildApiClient(
    store,
    auth,
    onForceLogout: () {
      ref.read(authStateProvider.notifier).forceLogout();
    },
  );
});

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(tokenStoreProvider).readAccess();
    return token != null && token.isNotEmpty;
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref
          .read(tokenStoreProvider)
          .save(access: session.access, refresh: session.refresh);
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    ref.invalidateSelf();
  }

  void forceLogout() {
    state = const AsyncData(false);
  }
}

class BackendDeviceRegistration {
  const BackendDeviceRegistration({
    required this.token,
    required this.platform,
    required this.lastSyncedAt,
    required this.isSuccess,
  });

  final String token;
  final String platform;
  final DateTime lastSyncedAt;
  final bool isSuccess;
}

final deviceRegistrationProvider =
    NotifierProvider<DeviceRegistrationNotifier, BackendDeviceRegistration?>(
  DeviceRegistrationNotifier.new,
);

class DeviceRegistrationNotifier extends Notifier<BackendDeviceRegistration?> {
  @override
  BackendDeviceRegistration? build() => null;

  Future<void> registerDevice(String token) async {
    // Simulasi POST /devices ke backend kampus
    state = BackendDeviceRegistration(
      token: token,
      platform: 'android',
      lastSyncedAt: DateTime.now(),
      isSuccess: true,
    );
  }
}

final topicsProvider =
    NotifierProvider<TopicsNotifier, Set<String>>(TopicsNotifier.new);

class TopicsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return {'pengumuman-kampus'};
  }

  Future<void> toggle(String topic) async {
    if (state.contains(topic)) {
      state = {...state}..remove(topic);
      await PushService.instance.unsubscribeFromTopic(topic);
    } else {
      state = {...state, topic};
      await PushService.instance.subscribeToTopic(topic);
    }
  }
}
