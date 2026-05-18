import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../core/network/token_storage.dart';
import '../models/user.dart';

class AuthService {
  final Dio _dio = DioClient.instance.dio;
  final TokenStorage _tokenStorage = TokenStorage();

  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final responseData = response.data;
      final data = responseData['data'];
      final user = User.fromJson(data['user']);
      final token = data['token'] as String;

      // Store tokens securely
      await _tokenStorage.saveAccessToken(token);
      await _tokenStorage.saveRefreshToken(token);

      return user.copyWith(token: token);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Login gagal');
    }
  }

  Future<User> register(String nama, String email, String password, UserRole role) async {
    try {
      await _dio.post(
        '/auth/register',
        data: {
          'nama': nama,
          'email': email,
          'password': password,
          'role': role.name,
        },
      );

      // Backend register returns only { success: true },
      // so auto-login to get the token and user data.
      return await login(email, password);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Registrasi gagal');
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal mendapatkan data user');
    }
  }

  Future<void> logout() async {
    try {
      await _tokenStorage.clearTokens();
    } catch (e) {
      // Continue with logout even if clearing tokens fails
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _tokenStorage.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getAccessToken() async {
    return await _tokenStorage.readAccessToken();
  }
}
