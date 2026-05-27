import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:klinik_app/features/auth/data/repositories/auth_repository_impl.dart';

// State model
class AuthState {
  final bool isLoading;
  final User? user;
  final String? role;

  AuthState({this.isLoading = true, this.user, this.role});

  AuthState copyWith({bool? isLoading, User? user, String? role}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      role: role ?? this.role,
    );
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final _supabase = Supabase.instance.client;
  late final AuthRepositoryImpl _authRepo;

  AuthNotifier() : super(AuthState(isLoading: true)) {
    _authRepo = AuthRepositoryImpl(_supabase);
    _init();
  }

  void _init() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        final role = await _authRepo.getUserRole(session.user.id);
        state = state.copyWith(isLoading: false, user: session.user, role: role);
      } else {
        state = state.copyWith(isLoading: false, user: null, role: null);
      }
    });
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
