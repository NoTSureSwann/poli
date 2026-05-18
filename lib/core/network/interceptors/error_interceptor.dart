import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = _mapDioError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        error: appException,
        type: err.type,
      ),
    );
  }

  AppException _mapDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return AppException(
        'Waktu koneksi habis. Periksa koneksi internet Anda.',
      );
    }

    if (error.type == DioExceptionType.badResponse && error.response != null) {
      final statusCode = error.response!.statusCode;
      final responseData = error.response!.data;

      if (statusCode == 401) {
        return AppException(
          'Autentikasi gagal. Silakan login ulang.',
          statusCode: statusCode,
        );
      }

      if (statusCode != null && statusCode >= 500) {
        return AppException(
          'Server sedang sibuk. Coba lagi nanti.',
          statusCode: statusCode,
        );
      }

      if (statusCode != null && statusCode >= 400) {
        final message =
            _extractMessage(responseData) ??
            'Terjadi kesalahan pada permintaan Anda.';
        return AppException(message, statusCode: statusCode);
      }
    }

    if (error.type == DioExceptionType.cancel) {
      return AppException('Permintaan dibatalkan oleh pengguna.');
    }

    if (error.type == DioExceptionType.unknown) {
      return AppException(
        'Tidak dapat terhubung ke server. Periksa jaringan Anda.',
      );
    }

    return AppException('Terjadi kesalahan tidak terduga. Silakan coba lagi.');
  }

  String? _extractMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData['message'] is String) {
        return responseData['message'] as String;
      }
      if (responseData['errors'] is String) {
        return responseData['errors'] as String;
      }
      if (responseData['errors'] is Map) {
        return (responseData['errors'] as Map).values.join(' ');
      }
    }
    return null;
  }
}
