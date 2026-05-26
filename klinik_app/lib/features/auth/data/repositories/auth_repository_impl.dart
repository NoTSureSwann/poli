import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;

  AuthRepositoryImpl(this._supabase);

  @override
  Future<AuthResponse> signIn({required String email, required String password}) async {
    return await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<AuthResponse> signUp({required String email, required String password, required String role}) async {
    // Register user
    final response = await _supabase.auth.signUp(email: email, password: password);
    
    // Insert role to profiles table if registration is successful
    if (response.user != null) {
      try {
        await _supabase.from('profiles').insert({
          'id': response.user!.id,
          'role': role,
        });
      } catch (e) {
        // Log error but don't fail the sign up, 
        // ideally handled by a trigger in Supabase
        log('Error inserting role: $e');
      }
    }
    
    return response;
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  @override
  Future<String?> getUserRole(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();
      return response['role'] as String?;
    } catch (e) {
      log('Error getting user role: $e');
      return null;
    }
  }
}
