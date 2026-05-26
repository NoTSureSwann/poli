import 'package:flutter/material.dart';
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
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Loket';
  bool _obscurePassword = true;

  void _login() {
    Widget destination;
    switch (_selectedRole) {
      case 'Loket':
        destination = const DashboardLoketScreen();
        break;
      case 'Dokter':
        destination = const DashboardDokterSipasScreen();
        break;
      case 'Farmasi':
        destination = const DashboardFarmasiScreen();
        break;
      case 'Admin':
      default:
        destination = const DashboardAdminSipasScreen();
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_hospital, size: 80, color: Color(0xFF2563EB)),
              const SizedBox(height: 16),
              const Text(
                'Klinik App Login',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username / NIK Petugas',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
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
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Pilih Role',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                items: const [
                  DropdownMenuItem(value: 'Loket', child: Text('Loket')),
                  DropdownMenuItem(value: 'Dokter', child: Text('Dokter')),
                  DropdownMenuItem(value: 'Farmasi', child: Text('Farmasi')),
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('MASUK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
