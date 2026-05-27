import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _keyJwtToken = 'jwt_token';
  static const String _keyUserRole = 'user_role';
  static const String _keyLastActive = 'last_active_timestamp';

  // --- JWT Token ---
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyJwtToken, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyJwtToken);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _keyJwtToken);
  }

  // --- User Role ---
  Future<void> saveRole(String role) async {
    await _secureStorage.write(key: _keyUserRole, value: role);
  }

  Future<String?> getRole() async {
    return await _secureStorage.read(key: _keyUserRole);
  }

  // --- Session Management ---
  Future<void> saveLastActive(DateTime timestamp) async {
    await _secureStorage.write(key: _keyLastActive, value: timestamp.toIso8601String());
  }

  Future<DateTime?> getLastActive() async {
    final timestampString = await _secureStorage.read(key: _keyLastActive);
    if (timestampString != null) {
      return DateTime.tryParse(timestampString);
    }
    return null;
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
