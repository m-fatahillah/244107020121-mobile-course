import 'package:dio/dio.dart';
import 'auth_repository.dart';
import 'token_store.dart';

Dio buildApiClient(
  TokenStore store,
  AuthRepository auth, {
  void Function()? onForceLogout,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://example-campus-api.test',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccess();
        if (access != null && access.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          final refresh = await store.readRefresh();
          if (refresh == null || refresh.isEmpty) {
            await store.clear();
            onForceLogout?.call();
            return handler.next(e);
          }
          try {
            final renewed = await auth.refresh(refresh);
            await store.save(access: renewed, refresh: refresh);

            // Retry request satu kali dengan access token baru
            final retryOptions = e.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $renewed';

            final retry = await dio.fetch(retryOptions);
            return handler.resolve(retry);
          } catch (_) {
            // Refresh token gagal / kedaluwarsa -> bersihkan session dan paksa login ulang
            await store.clear();
            onForceLogout?.call();
          }
        }
        handler.next(e);
      },
    ),
  );

  return dio;
}
