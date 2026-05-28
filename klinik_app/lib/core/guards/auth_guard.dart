import '../storage/token_storage_service.dart';

class AuthGuard {
  static final TokenStorageService _storageService = TokenStorageService();

  static Future<bool> isAuthenticated() async {
    final token = await _storageService.getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<String?> getUserRole() async {
    return await _storageService.getRole();
  }

  static Future<bool> hasPermission(String requiredRole) async {
    final currentRole = await getUserRole();
    if (currentRole == null) return false;
    if (currentRole == 'admin') return true; // admin can access anything if needed, though role_guard might handle it better
    return currentRole == requiredRole;
  }
}
