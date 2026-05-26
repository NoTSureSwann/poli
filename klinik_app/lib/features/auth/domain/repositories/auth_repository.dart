import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<AuthResponse> signIn({required String email, required String password});
  Future<AuthResponse> signUp({required String email, required String password, required String role});
  Future<void> signOut();
  User? getCurrentUser();
  Future<String?> getUserRole(String userId);
}
