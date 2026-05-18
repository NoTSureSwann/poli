import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

/// Dio singleton untuk akses API.
/// - BaseURL mengikuti `ApiConstants.baseUrl`
/// - Token diambil dari `SharedPreferences` key `current_user` (AuthService)
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(_AuthInterceptor());
  }

  static final ApiClient instance = ApiClient._internal();

  late final Dio _dio;

  Dio get dio => _dio;

  /// Akses Dio langsung (agar tidak banyak ubah kode lama).
  Dio get client => _dio;
}

class _AuthInterceptor extends Interceptor {
  Future<String?> _readToken() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson == null) return null;

    // AuthService menyimpan token di field `token` (string).
    // Karena kita tidak ingin tarik dependency jsonDecode di sini berkali-kali,
    // lakukan parsing minimal.
    try {
      final decoded = userJson.contains('"token"') ? userJson : userJson;

      // Parse sangat sederhana via regex agar bebas dari import dart:convert.
      // (Tetap aman karena format disimpan dari aplikasi sendiri.)
      final match = RegExp(r'"token"\s*:\s*"([^"]+)"').firstMatch(decoded);
      return match?.group(1);
    } catch (_) {
      return null;
    }
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
