import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../screens/home_screen.dart';
import '../../../sipas/presentation/screens/dashboard_admin_sipas_screen.dart';
import '../../../sipas/presentation/screens/dashboard_dokter_sipas_screen.dart';
import '../../../sipas/presentation/screens/dashboard_loket_screen.dart';
import '../../../sipas/presentation/screens/dashboard_farmasi_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final authRepo = AuthRepositoryImpl(Supabase.instance.client);
      final response = await authRepo.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      if (mounted && response.user != null) {
        final role = await authRepo.getUserRole(response.user!.id);
        
        Widget nextScreen;
        if (role == 'admin') {
          nextScreen = const DashboardAdminSipasScreen();
        } else if (role == 'dokter') {
          nextScreen = const DashboardDokterSipasScreen();
        } else if (role == 'farmasi') {
          nextScreen = const DashboardFarmasiScreen();
        } else if (role == 'pasien' || role == 'loket') {
          nextScreen = const DashboardLoketScreen(); // Atau arahkan ke HomeScreen pasien
        } else {
          nextScreen = const HomeScreen();
        }

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => nextScreen),
            (route) => false,
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login Gagal: ${e.message}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val == null || val.isEmpty || !val.contains('@') ? 'Format email salah' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
                validator: (val) => val == null || val.length < 6 ? 'Password minimal 6 karakter' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _login,
                        child: const Text('Login'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
