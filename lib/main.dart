import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/api_constants.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://oofejhakgjaqprkzaext.supabase.co',
    anonKey: 'sb_publishable_ewBgnDMNaHfnWiJ9nC0wNg_Y0IRLI-P',
  );

  // Configure API host based on platform
  if (!kIsWeb) {
    // Only use emulator IP on Android; desktop uses localhost by default.
    if (Platform.isAndroid) {
      ApiConstants.useAndroidEmulator();
    }
  }

  // Read persisted theme preference
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('dark_mode') ?? false;

  runApp(KlinikApp(initialDarkMode: isDark));
}

class KlinikApp extends StatefulWidget {
  final bool initialDarkMode;

  const KlinikApp({super.key, required this.initialDarkMode});

  @override
  State<KlinikApp> createState() => _KlinikAppState();
}

class _KlinikAppState extends State<KlinikApp> {
  late bool _isDarkMode;
  bool _isLoggedIn = false;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authService = AuthService();
    final loggedIn = await authService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _isCheckingAuth = false;
      });
    }
  }

  void _toggleTheme(bool dark) async {
    setState(() => _isDarkMode = dark);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', dark);
  }

  void _onLoginSuccess() {
    setState(() => _isLoggedIn = true);
  }

  void _onLogout() {
    setState(() => _isLoggedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<VoidCallback>.value(value: _onLogout),
      ],
      child: MaterialApp(
        title: 'Klinik Merah Putih',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: _isCheckingAuth
            ? const _SplashScreen()
            : _isLoggedIn
                ? HomeScreen(
                    initialDarkMode: _isDarkMode,
                    onToggleTheme: _toggleTheme,
                  )
                : LoginScreen(onLoginSuccess: _onLoginSuccess),
      ),
    );
  }
}

/// A brief splash shown while checking auth status.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_hospital,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 18),
            Text(
              'Klinik Merah Putih',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
