import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../models/pasien.dart';
import 'auth_service.dart';
import 'pasien_service.dart';
import 'rekam_medis_service.dart';
import 'antrian_service.dart';
import 'resep_service.dart';
import 'stok_obat_service.dart';
import 'pembayaran_service.dart';

// Service Providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final pasienServiceProvider = Provider<PasienService>((ref) => PasienService());

final rekamMedisServiceProvider = Provider<RekamMedisService>(
  (ref) => RekamMedisService(),
);

final antrianServiceProvider = Provider<AntrianService>(
  (ref) => AntrianService(),
);

final resepServiceProvider = Provider<ResepService>((ref) => ResepService());

final stokObatServiceProvider = Provider<StokObatService>(
  (ref) => StokObatService(),
);

final pembayaranServiceProvider = Provider<PembayaranService>(
  (ref) => PembayaranService(),
);

// Auth State Providers
final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<bool>>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    return AuthNotifier(authService);
  },
);

class AuthNotifier extends StateNotifier<AsyncValue<bool>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = const AsyncValue.loading();
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      state = AsyncValue.data(isLoggedIn);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authService.login(email, password);
      state = const AsyncValue.data(true);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> register(
    String nama,
    String email,
    String password,
    UserRole role,
  ) async {
    state = const AsyncValue.loading();
    try {
      await _authService.register(nama, email, password, role);
      state = const AsyncValue.data(true);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _authService.logout();
      state = const AsyncValue.data(false);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Pasien State Providers
final pasienListProvider =
    StateNotifierProvider<PasienNotifier, AsyncValue<List<Pasien>>>((ref) {
      final pasienService = ref.watch(pasienServiceProvider);
      return PasienNotifier(pasienService);
    });

class PasienNotifier extends StateNotifier<AsyncValue<List<Pasien>>> {
  final PasienService _pasienService;

  PasienNotifier(this._pasienService) : super(const AsyncValue.loading()) {
    loadPasien();
  }

  Future<void> loadPasien({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    state = const AsyncValue.loading();
    try {
      final pasien = await _pasienService.getAllPasien(
        page: page,
        limit: limit,
        search: search,
      );
      state = AsyncValue.data(pasien);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addPasien(Pasien pasien) async {
    state = state.maybeWhen(
      data: (currentList) => AsyncValue.data([...currentList, pasien]),
      orElse: () => state,
    );
  }

  Future<void> updatePasien(Pasien updatedPasien) async {
    state = state.maybeWhen(
      data: (currentList) => AsyncValue.data(
        currentList
            .map((p) => p.id == updatedPasien.id ? updatedPasien : p)
            .toList(),
      ),
      orElse: () => state,
    );
  }

  Future<void> removePasien(String id) async {
    state = state.maybeWhen(
      data: (currentList) =>
          AsyncValue.data(currentList.where((p) => p.id != id).toList()),
      orElse: () => state,
    );
  }
}

// Current User Provider
final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, AsyncValue<User?>>((ref) {
      final authService = ref.watch(authServiceProvider);
      return CurrentUserNotifier(authService);
    });

class CurrentUserNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  CurrentUserNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> loadCurrentUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void clearUser() {
    state = const AsyncValue.data(null);
  }
}
