import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:klinik_app/core/providers/auth_provider.dart';
import 'package:klinik_app/features/home/presentation/screens/home_screen.dart';
import 'package:klinik_app/features/ai_chat/presentation/screens/chat_ai_screen.dart';
import 'package:klinik_app/features/queue/presentation/screens/antrian_realtime_screen.dart';
import 'package:klinik_app/features/patient/presentation/screens/pendaftaran_screen.dart';
import 'package:klinik_app/features/patient/presentation/screens/riwayat_pasien_screen.dart';
import 'package:klinik_app/features/auth/presentation/screens/login_screen.dart';
import 'package:klinik_app/features/auth/presentation/screens/register_screen.dart';
import 'package:klinik_app/features/sipas/presentation/screens/dashboard_admin_sipas_screen.dart';
import 'package:klinik_app/features/sipas/presentation/screens/dashboard_dokter_sipas_screen.dart';
import 'package:klinik_app/features/sipas/presentation/screens/dashboard_farmasi_screen.dart';
import 'package:klinik_app/features/sipas/presentation/screens/dashboard_loket_screen.dart';
import 'main_layout.dart'; 

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthRoute = state.uri.path == '/login' || state.uri.path == '/register';
      final isLoggedIn = authState.user != null;

      if (authState.isLoading) {
        return null; // Wait for initialization (perhaps show a splash screen)
      }

      // If not logged in and not on auth route, redirect to login
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      // If logged in and on auth route, redirect to home
      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const DashboardAdminSipasScreen(),
      ),
      GoRoute(
        path: '/dokter',
        builder: (context, state) => const DashboardDokterSipasScreen(),
      ),
      GoRoute(
        path: '/farmasi',
        builder: (context, state) => const DashboardFarmasiScreen(),
      ),
      GoRoute(
        path: '/loket',
        builder: (context, state) => const DashboardLoketScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'pendaftaran',
                builder: (context, state) => const PendaftaranScreen(),
              ),
              GoRoute(
                path: 'antrian',
                builder: (context, state) => const AntrianRealtimeScreen(),
              ),
              GoRoute(
                path: 'riwayat',
                builder: (context, state) => const RiwayatPasienScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/payment',
            builder: (context, state) => const Scaffold(body: Center(child: Text('QRIS Payment Gateway'))),
          ),
          GoRoute(
            path: '/ai',
            builder: (context, state) => const ChatAiScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Patient Profile'))),
          ),
        ],
      ),
    ],
  );
});
