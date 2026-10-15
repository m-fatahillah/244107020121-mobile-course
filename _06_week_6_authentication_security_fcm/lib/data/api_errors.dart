import 'package:dio/dio.dart';

String friendlyErrorMessage(dynamic error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 401) {
          return 'Sesi autentikasi telah berakhir (401). Silakan login kembali.';
        } else if (code == 403) {
          return 'Akses ditolak (403). Anda tidak memiliki izin.';
        } else if (code == 404) {
          return 'Data pengumuman tidak ditemukan di server (404).';
        } else if (code != null && code >= 500) {
          return 'Server kampus mengalami gangguan ($code). Coba beberapa saat lagi.';
        }
        return 'Permintaan gagal dengan status code $code.';

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi ke server kampus batas waktu habis (timeout).';

      case DioExceptionType.connectionError:
        return 'Gagal terhubung ke server. Periksa jaringan internet Anda.';

      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';

      default:
        return 'Terjadi kendala jaringan (${error.message ?? 'Unknown'}).';
    }
  }

  if (error is Exception) {
    final msg = error.toString();
    return msg.startsWith('Exception: ') ? msg.substring(11) : msg;
  }

  return error?.toString() ?? 'Terjadi kesalahan tidak terduga.';
}
