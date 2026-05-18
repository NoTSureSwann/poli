import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/auth_service.dart';
import 'regulation_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onToggleTheme;

  const ProfileScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool _isDarkMode;

  Future<void> _openExternalLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  Future<void> _resetTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('terms_accepted');
    await prefs.remove('privacy_accepted');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data onboarding direset. Restart app.'),
          backgroundColor: AppTheme.warning,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<AuthService>().logout();
    }
  }

  Future<void> _exportMLData() async {
    final auth = context.read<AuthService>();
    final token = await auth.getAccessToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/ml/export?token=$token');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengekspor data: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary.withAlpha(40),
                  AppTheme.accent.withAlpha(20),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primary.withAlpha(50),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Admin Klinik',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Klinik Merah Putih',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Compliance & Regulations
          _SectionCard(
            title: 'Kepatuhan & Regulasi',
            children: [
              ListTile(
                leading: const Icon(Icons.description, color: AppTheme.primary),
                title: const Text('PMK No. 269/2008'),
                subtitle: const Text('Standar Rekam Medis Indonesia'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegulationDetailScreen(
                      title: 'Regulasi Rekam Medis',
                      assetPath: 'assets/regulations/pmk_269_2008.md',
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.gavel, color: AppTheme.primary),
                title: const Text('UU Kesehatan 17/2023'),
                subtitle: const Text('Transformasi Digital Kesehatan'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegulationDetailScreen(
                      title: 'UU Kesehatan (RME)',
                      assetPath: 'assets/regulations/uu_kesehatan_17_2023.md',
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip, color: AppTheme.primary),
                title: const Text('UU PDP 27/2022'),
                subtitle: const Text('Pelindungan Data Pribadi Pasien'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegulationDetailScreen(
                      title: 'UU Pelindungan Data',
                      assetPath: 'assets/regulations/uu_pdp_27_2022.md',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Settings
          _SectionCard(
            title: 'Pengaturan',
            children: [
              ListTile(
                leading: Icon(
                  _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: AppTheme.primary,
                ),
                title: const Text('Mode Gelap'),
                trailing: Switch(
                  value: _isDarkMode,
                  onChanged: (val) {
                    setState(() => _isDarkMode = val);
                    widget.onToggleTheme(val);
                  },
                  activeTrackColor: AppTheme.primary,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.restart_alt, color: AppTheme.warning),
                title: const Text('Reset Onboarding'),
                subtitle: const Text('Tampilkan ulang terms & conditions'),
                onTap: _resetTerms,
              ),
              ListTile(
                leading: const Icon(
                  Icons.description_outlined,
                  color: AppTheme.primary,
                ),
                title: const Text('Terms of Agreement'),
                subtitle: const Text('Buka syarat dan ketentuan terbaru'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () =>
                    _openExternalLink('https://klinik-merah-putih.com/terms'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ML Tools
          _SectionCard(
            title: 'Manajemen Data & ML',
            children: [
              ListTile(
                leading: const Icon(Icons.analytics, color: AppTheme.primary),
                title: const Text('Ekspor Dataset (CSV)'),
                subtitle: const Text(
                  'Unduh data klinis untuk Machine Learning',
                ),
                trailing: const Icon(Icons.download),
                onTap: _exportMLData,
              ),
              ListTile(
                leading: const Icon(Icons.storage, color: AppTheme.primary),
                title: const Text('Database SQL'),
                subtitle: const Text('Data tersimpan di SQLite lokal'),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Logout
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Keluar Akun',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: _handleLogout,
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),

          // App info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withAlpha(40),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.health_and_safety,
                  size: 32,
                  color: AppTheme.primary,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Klinik Merah Putih',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'v1.0.0 • Sistem Manajemen Klinik',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kesehatan Anda, Prioritas Kami',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
