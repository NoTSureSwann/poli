import 'dart:async';

import 'package:dio/dio.dart';

import '../token_storage.dart';
import '../../constants/api_constants.dart';

typedef LogoutCallback = void Function();

class AuthInterceptor extends Interceptor {
  AuthInterceptor();

  static LogoutCallback? onLogout;

  final TokenStorage _tokenStorage = TokenStorage();
  final Dio _refreshDio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.timeout,
      receiveTimeout: ApiConstants.timeout,
      contentType: 'application/json',
      responseType: ResponseType.json,
    ),
  );

  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final alreadyRetried = err.requestOptions.extra['retry'] == true;

    if (statusCode == 401 && !alreadyRetried) {
      final refreshSuccess = await _refreshToken();
      if (refreshSuccess) {
        final newAccessToken = await _tokenStorage.readAccessToken();
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          requestOptions.extra['retry'] = true;

          try {
            final response = await _refreshDio.fetch(requestOptions);
            return handler.resolve(response);
          } catch (retryError) {
            await _handleRefreshFailure();
            return handler.next(err);
          }
        }
      }

      await _handleRefreshFailure();
      return handler.next(err);
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    if (_isRefreshing) {
      await _refreshCompleter?.future;
      return !_isRefreshing;
    }

    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<void>();

    try {
      final response = await _refreshDio.post(
        ApiConstants.authRefresh,
        data: {'refresh_token': refreshToken},
      );

      final data = response.data is Map
          ? response.data['data'] ?? response.data
          : response.data;
      final accessToken = data['access_token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;

      if (accessToken == null || newRefreshToken == null) {
        return false;
      }

      await _tokenStorage.saveAccessToken(accessToken);
      await _tokenStorage.saveRefreshToken(newRefreshToken);
      return true;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter?.complete();
      _refreshCompleter = null;
    }
  }

  Future<void> _handleRefreshFailure() async {
    await _tokenStorage.clearTokens();
    if (onLogout != null) {
      onLogout!();
    }
  }
}
