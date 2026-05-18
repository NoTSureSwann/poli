import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  UserRole _selectedRole = UserRole.pasien;
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _launchLegalUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _handleLogin() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan kata sandi wajib diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final auth = context.read<AuthService>();
    try {
      await auth.login(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );

      if (!mounted) {
        return;
      }

      setState(() => _isLoading = false);
      widget.onLoginSuccess();
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Login gagal. Periksa kembali email dan password Anda.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                      color: Colors.black.withAlpha(16),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.local_hospital,
                      size: 68,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Klinik Merah Putih',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Masuk untuk melanjutkan manajemen pasien.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 22),
                    SegmentedButton<UserRole>(
                      segments: const [
                        ButtonSegment<UserRole>(
                          value: UserRole.pasien,
                          label: Text('Pasien'),
                          icon: Icon(Icons.person_outline),
                        ),
                        ButtonSegment<UserRole>(
                          value: UserRole.admin,
                          label: Text('Admin'),
                          icon: Icon(Icons.admin_panel_settings_outlined),
                        ),
                      ],
                      selected: {_selectedRole},
                      onSelectionChanged: (value) {
                        setState(() => _selectedRole = value.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                      ),
                      onFieldSubmitted: (_) => _handleLogin(),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Masuk'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegisterScreen(
                              onRegisterSuccess: widget.onLoginSuccess,
                            ),
                          ),
                        );
                      },
                      child: const Text('Belum punya akun? Daftar sekarang'),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Dengan masuk, Anda setuju pada ',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        TextButton(
                          onPressed: () => _launchLegalUrl(
                            'https://klinik-merah-putih.com/terms',
                          ),
                          child: const Text('Terms of Agreement'),
                        ),
                        Text(
                          ' dan ',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        TextButton(
                          onPressed: () => _launchLegalUrl(
                            'https://klinik-merah-putih.com/privacy',
                          ),
                          child: const Text('Kebijakan Privasi'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
