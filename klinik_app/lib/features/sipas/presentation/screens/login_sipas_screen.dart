import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:klinik_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:klinik_app/features/sipas/presentation/screens/dashboard_loket_screen.dart';
import 'package:klinik_app/features/sipas/presentation/screens/dashboard_dokter_sipas_screen.dart';
import 'package:klinik_app/features/sipas/presentation/screens/dashboard_farmasi_screen.dart';
import 'package:klinik_app/features/sipas/presentation/screens/dashboard_admin_sipas_screen.dart';

class LoginSipasScreen extends StatefulWidget {
  const LoginSipasScreen({super.key});

  @override
  State<LoginSipasScreen> createState() => _LoginSipasScreenState();
}

class _LoginSipasScreenState extends State<LoginSipasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authRepo = AuthRepositoryImpl(Supabase.instance.client);
      final response = await authRepo.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted || response.user == null) return;

      // [SEC-03 FIX]: Role ditentukan oleh SERVER, bukan oleh dropdown user.
      final role = await authRepo.getUserRole(response.user!.id);

      Widget destination;
      switch (role) {
        case 'loket':
          destination = const DashboardLoketScreen();
          break;
        case 'dokter':
          destination = const DashboardDokterSipasScreen();
          break;
        case 'farmasi':
          destination = const DashboardFarmasiScreen();
          break;
        case 'admin':
          destination = const DashboardAdminSipasScreen();
          break;
        default:
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Akun Anda tidak memiliki akses ke SIPAS. Hubungi admin.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isLoading = false);
          return;
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        String errorMessage = e.message;
        if (e.message.toLowerCase().contains('email not confirmed')) {
          errorMessage = 'Email belum dikonfirmasi. Periksa kotak masuk/spam Anda, atau hubungi Admin.';
        } else if (e.message.toLowerCase().contains('invalid login credentials')) {
          errorMessage = 'Email atau password salah.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Gagal: $errorMessage'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        // [SEC-11 FIX]: Jangan expose detail error ke user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan. Silakan coba lagi.'), backgroundColor: Colors.red),
        );
        debugPrint('SIPAS Login Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_hospital, size: 80, color: Color(0xFF2563EB)),
                const SizedBox(height: 16),
                const Text(
                  'Klinik App Login',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'SIPAS — Sistem Informasi Pelayanan',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Petugas',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val == null || val.isEmpty || !val.contains('@')
                      ? 'Masukkan email yang valid'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (val) => val == null || val.length < 6
                      ? 'Password minimal 6 karakter'
                      : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('MASUK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
