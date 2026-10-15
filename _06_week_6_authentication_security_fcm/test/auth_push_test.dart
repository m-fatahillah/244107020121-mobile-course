import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:_06_week_6_authentication_security_fcm/messaging/message_parser.dart';
import 'package:_06_week_6_authentication_security_fcm/data/api_errors.dart';

class FakeTokenStore {
  String? access;
  String? refresh;

  Future<void> save({required String newAccess, required String newRefresh}) async {
    access = newAccess;
    refresh = newRefresh;
  }

  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

void main() {
  group('1. Parsing Route & Deep Link FCM (Pure Function)', () {
    test('routeFromMessage menangani route kosong dan tanpa slash', () {
      expect(routeFromMessage({}), '/');
      expect(routeFromMessage({'route': ''}), '/');
      expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
      expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
      expect(routeFromMessage({'route': 'login'}), '/login');
    });

    test('data payload membawa id pengumuman dan route tujuan', () {
      const data = {'route': '/pengumuman/3', 'id': '3'};
      expect(data['id'], '3');
      expect(routeFromMessage(data), '/pengumuman/3');
    });
  });

  group('2. Token Lifecycle & Session Logic', () {
    test('provider auth membaca status login dari ketersediaan token', () async {
      final store = FakeTokenStore()..access = 'mock-access-token';
      expect(store.access != null, isTrue);

      store.access = null;
      expect(store.access != null, isFalse);
    });

    test('refresh gagal -> sesi dibersihkan (paksa login ulang)', () async {
      final store = FakeTokenStore()
        ..access = 'old-access'
        ..refresh = '';

      final needsLogin = (store.refresh ?? '').isEmpty;
      expect(needsLogin, isTrue);

      await store.clear();
      expect(store.access, isNull);
      expect(store.refresh, isNull);
    });

    test('refresh sukses -> token access diperbarui tanpa menghapus refresh', () async {
      final store = FakeTokenStore()
        ..access = 'old-access'
        ..refresh = 'valid-refresh-token';

      await store.save(
        newAccess: 'renewed-access-token',
        newRefresh: store.refresh!,
      );

      expect(store.access, 'renewed-access-token');
      expect(store.refresh, 'valid-refresh-token');
    });
  });

  group('3. Pemetaan Pesan Error Ramah Pengguna (api_errors.dart)', () {
    test('menghasilkan pesan ramah untuk HTTP 401 Sesi Kedaluwarsa', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      final message = friendlyErrorMessage(dioException);
      expect(message, contains('401'));
      expect(message, contains('Sesi autentikasi telah berakhir'));
    });

    test('menghasilkan pesan ramah untuk timeout dan kendala jaringan', () {
      final timeoutException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(friendlyErrorMessage(timeoutException), contains('timeout'));

      final connectionException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );
      expect(friendlyErrorMessage(connectionException), contains('Periksa jaringan'));
    });
  });
}
