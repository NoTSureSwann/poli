import 'package:flutter/material.dart';
import 'package:klinik_app/services/firebase/log_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

// Clean Architecture Dependency Imports untuk Automation
import 'features/automation/data/datasources/automation_remote_data_source.dart';
import 'features/automation/data/repositories/automation_repository_impl.dart';
import 'features/automation/domain/usecases/send_ai_prompt_usecase.dart';
import 'features/automation/presentation/providers/automation_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── LOAD ENV VARIABLES ──────────────────────────────────
  await dotenv.load(fileName: ".env");

  // ─── FIREBASE ────────────────────────────────────────────
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init gagal (belum dikonfigurasi?): $e');
  }

  // ─── SUPABASE ────────────────────────────────────────────
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final LogService _logService = LogService();
  String _currentSessionId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startLogSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_currentSessionId.isNotEmpty) {
      _logService.endSession(_currentSessionId);
    }
    super.dispose();
  }

  void _startLogSession() async {
    _currentSessionId = await _logService.startSession();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startLogSession();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      if (_currentSessionId.isNotEmpty) {
        _logService.endSession(_currentSessionId);
        _currentSessionId = '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return legacy_provider.MultiProvider(
      providers: [
        legacy_provider.ChangeNotifierProvider(
          create: (_) => AutomationProvider(
            sendAiPromptUseCase: SendAiPromptUseCase(
              AutomationRepositoryImpl(
                remoteDataSource: AutomationRemoteDataSourceImpl(),
              ),
            ),
          ),
        ),
      ],
      child: Consumer(
        builder: (context, ref, child) {
          final router = ref.watch(routerProvider);
          return MaterialApp.router(
            title: 'Klinik App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
