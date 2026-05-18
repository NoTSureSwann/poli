import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegisterSuccess;

  const RegisterScreen({super.key, required this.onRegisterSuccess});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
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

  Future<void> _handleRegister() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua bidang wajib diisi')));
      return;
    }

    setState(() => _isLoading = true);

    final auth = context.read<AuthService>();
    try {
      await auth.register(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passCtrl.text,
        _selectedRole,
      );

      if (!mounted) {
        return;
      }

      setState(() => _isLoading = false);
      widget.onRegisterSuccess();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi gagal, coba lagi.')),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun Baru')),
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
                      offset: const Offset(0, 8),
                      color: Colors.black.withAlpha(14),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.app_registration,
                      size: 66,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Buat Akun Klinik',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Lengkapi data berikut untuk mengaktifkan akun.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Daftar Akun'),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Dengan mendaftar, Anda menyetujui ',
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
