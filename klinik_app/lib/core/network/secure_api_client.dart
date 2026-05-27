import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/token_storage_service.dart';

class SecureApiClient {
  final Dio _dio;
  final TokenStorageService _storageService = TokenStorageService();

  SecureApiClient(String baseUrl)
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.addAll([
      _authInterceptor(),
      if (kDebugMode) _loggingInterceptor(),
    ]);
  }

  Dio get client => _dio;

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storageService.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Trigger force logout or token refresh logic here
          await _storageService.deleteToken();
          // EventBus / Provider call to reset app state
        }
        return handler.next(e);
      },
    );
  }

  Interceptor _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('🌍 [API REQUEST]: ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('✅ [API RESPONSE]: ${response.statusCode} - ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint('❌ [API ERROR]: ${e.response?.statusCode} - ${e.requestOptions.uri}');
        debugPrint('❌ [API ERROR MSG]: ${e.message}');
        return handler.next(e);
      },
    );
  }
}
