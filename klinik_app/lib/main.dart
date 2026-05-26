import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'features/dashboard/presentation/screens/landing_page_screen.dart';

// Clean Architecture Dependency Imports untuk Automation
import 'features/automation/data/datasources/automation_remote_data_source.dart';
import 'features/automation/data/repositories/automation_repository_impl.dart';
import 'features/automation/domain/usecases/send_ai_prompt_usecase.dart';
import 'features/automation/presentation/providers/automation_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── FIREBASE ────────────────────────────────────────────
  // Inisialisasi Firebase. 
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init gagal (belum dikonfigurasi?): $e');
  }

  // ─── SUPABASE ────────────────────────────────────────────
  await Supabase.initialize(
    url: 'https://jxamnlnxkleljndsbkda.supabase.co',
    anonKey: 'sb_publishable_5MYlPv0U9VT3rLs8uZSZzA_0UgE4cX_',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AutomationProvider(
            sendAiPromptUseCase: SendAiPromptUseCase(
              AutomationRepositoryImpl(
                remoteDataSource: AutomationRemoteDataSourceImpl(),
              ),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Klinik App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const LandingPageScreen(),
      ),
    );
  }
}
