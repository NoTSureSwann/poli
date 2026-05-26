import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── FIREBASE ────────────────────────────────────────────
  // Inisialisasi Firebase. Jika firebase_options.dart belum ada,
  // jalankan: dart pub global activate flutterfire_cli && flutterfire configure
  try {
    await Firebase.initializeApp();
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
    return MaterialApp(
      title: 'Klinik App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
