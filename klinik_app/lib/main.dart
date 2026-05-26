import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // URL Supabase Anda. Pastikan untuk mengganti 'public-anon-key' dengan kunci asli Anda.
  await Supabase.initialize(
    url: 'https://jxamnlnxkleljndsbkda.supabase.co',
    anonKey: 'public-anon-key', // TODO: Ganti dengan anon key Anda
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Klinik App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

