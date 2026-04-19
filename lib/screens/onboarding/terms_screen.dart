import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';

class TermsScreen extends StatefulWidget {
  final VoidCallback onTermsAccepted;

  const TermsScreen({super.key, required this.onTermsAccepted});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _isLoading = false;

  Future<void> _acceptTerms() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('terms_accepted', true);
    await prefs.setBool('privacy_accepted', true);

    if (mounted) {
      widget.onTermsAccepted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Center(
              child: Icon(
                Icons.health_and_safety,
                size: 80,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Selamat Datang di Klinik Merah Putih',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Sistem manajemen kesehatan terpadu untuk keamanan data medis Anda.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            CheckboxListTile(
              value: _termsAccepted,
              onChanged: (val) => setState(() => _termsAccepted = val ?? false),
              title: const Text('Saya menyetujui Syarat & Ketentuan'),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppTheme.primary,
            ),
            CheckboxListTile(
              value: _privacyAccepted,
              onChanged: (val) =>
                  setState(() => _privacyAccepted = val ?? false),
              title: const Text('Saya menyetujui Kebijakan Privasi'),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppTheme.primary,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_termsAccepted && _privacyAccepted && !_isLoading)
                    ? _acceptTerms
                    : null,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Lanjutkan', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
