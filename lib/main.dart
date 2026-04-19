import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding/terms_screen.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Load .env config
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    debugPrint('[Main] .env not found, using defaults');
  }

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('is_dark_mode') ?? false;
  final termsAccepted = prefs.getBool('terms_accepted') ?? false;

  final authService = AuthService();
  await authService.initialize();

  runApp(
    ChangeNotifierProvider<AuthService>.value(
      value: authService,
      child: MyApp(
        initialDarkMode: isDarkMode,
        termsAccepted: termsAccepted,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool initialDarkMode;
  final bool termsAccepted;

  const MyApp({
    super.key,
    required this.initialDarkMode,
    required this.termsAccepted,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;
  late bool _termsAccepted;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialDarkMode ? ThemeMode.dark : ThemeMode.light;
    _termsAccepted = widget.termsAccepted;
  }

  Future<void> _acceptTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('terms_accepted', true);
    await prefs.setBool('privacy_accepted', true);
    setState(() {
      _termsAccepted = true;
    });
  }

  void toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('is_dark_mode', isDark);
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Klinik Merah Putih',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: _buildHome(context),
    );
  }

  Widget _buildHome(BuildContext context) {
    if (!_termsAccepted) {
      return TermsScreen(onTermsAccepted: _acceptTerms);
    }
    
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        if (!auth.isAuthenticated) {
          return LoginScreen(
            onLoginSuccess: () {
              // The Consumer will rebuild and show HomeScreen automatically if authenticated
            },
          );
        }
        
        return HomeScreen(
          initialDarkMode: _themeMode == ThemeMode.dark,
          onToggleTheme: toggleTheme,
        );
      },
    );
  }
}
