import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/interceptors/error_interceptor.dart';
import '../../core/network/token_storage.dart';

class AuthService {
  AuthService({DioClient? dioClient, TokenStorage? tokenStorage})
    : _dioClient = dioClient ?? DioClient.instance,
      _tokenStorage = tokenStorage ?? TokenStorage();

  final DioClient _dioClient;
  final TokenStorage _tokenStorage;

  Future<void> login({required String email, required String password}) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.authLogin,
        data: {'email': email, 'password': password},
      );

      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;

      final accessToken = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;

      if (accessToken == null || refreshToken == null) {
        throw AppException('Respons login tidak valid dari server.');
      }

      await _tokenStorage.saveAccessToken(accessToken);
      await _tokenStorage.saveRefreshToken(refreshToken);
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<void> refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw AppException(
          'Refresh token tidak tersedia. Silakan login ulang.',
        );
      }

      final response = await _dioClient.dio.post(
        ApiConstants.authRefresh,
        data: {'refresh_token': refreshToken},
      );

      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;

      final accessToken = data['access_token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;

      if (accessToken == null || newRefreshToken == null) {
        throw AppException('Respons refresh token tidak valid.');
      }

      await _tokenStorage.saveAccessToken(accessToken);
      await _tokenStorage.saveRefreshToken(newRefreshToken);
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.authMe);
      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw AppException('Respons pengguna tidak valid.');
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }

  AppException _parseDioException(DioException error) {
    if (error.error is AppException) {
      return error.error as AppException;
    }
    return AppException(
      error.message ?? 'Terjadi kesalahan saat menghubungi server.',
    );
  }
}
