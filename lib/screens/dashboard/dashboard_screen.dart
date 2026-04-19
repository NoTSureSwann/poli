import 'package:flutter/material.dart';
import '../../services/patient_service.dart';
import '../../services/payment_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/stat_card.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalPatients = 0;
  Map<String, dynamic> _paymentSummary = {};
  bool _isLoading = true;
  final List<_ActivityItem> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final patientService = PatientService();
      final paymentService = PaymentService();

      final totalPatients = await patientService.getTotalPatientCount();
      final summary = await paymentService.getPaymentSummary();

      // Generate recent activities
      final activities = [
        _ActivityItem(
          icon: Icons.person_add,
          color: AppTheme.primary,
          title: 'Pasien baru terdaftar',
          subtitle: 'Ahmad Pratama - NIK 3201xxx',
          time: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        _ActivityItem(
          icon: Icons.payment,
          color: AppTheme.success,
          title: 'Pembayaran diterima',
          subtitle: 'Rp 150.000 (QRIS) - Siti Wijaya',
          time: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        _ActivityItem(
          icon: Icons.medical_services,
          color: AppTheme.accent,
          title: 'Rekam medis ditambahkan',
          subtitle: 'Diagnosis: ISPA - dr. Budi Santoso',
          time: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        _ActivityItem(
          icon: Icons.receipt_long,
          color: AppTheme.info,
          title: 'Sesi konsultasi selesai',
          subtitle: 'Pasien: Budi Santoso - Selesai',
          time: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        _ActivityItem(
          icon: Icons.payment,
          color: AppTheme.warning,
          title: 'Pembayaran Baru',
          subtitle: 'Rp 75.000 (Tunai) - Joko Permana',
          time: DateTime.now().subtract(const Duration(hours: 4)),
        ),
      ];

      if (mounted) {
        setState(() {
          _totalPatients = totalPatients;
          _paymentSummary = summary;
          _recentActivities.addAll(activities);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Stats Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                final aspect = constraints.maxWidth > 600 ? 1.4 : 1.2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: aspect,
                  children: [
                    StatCard(
                      title: 'Total Pasien',
                      value: _totalPatients.toString(),
                      icon: Icons.people,
                      color: AppTheme.primary,
                      subtitle: 'Terdaftar aktif',
                    ),
                    StatCard(
                      title: 'Total Transaksi',
                      value: '${_paymentSummary['total_transaksi'] ?? 0}',
                      icon: Icons.receipt_long,
                      color: AppTheme.success,
                      subtitle: 'Pembayaran tercatat',
                    ),
                    StatCard(
                      title: 'Debit',
                      value: _formatCurrency(_paymentSummary['total_debit'] ?? 0),
                      icon: Icons.credit_card,
                      color: AppTheme.info,
                      subtitle: 'Bank Transfer/Debit',
                    ),
                    StatCard(
                      title: 'QRIS/Tunai',
                      value: _formatCurrency((_paymentSummary['total_qris'] ?? 0) + (_paymentSummary['total_cash'] ?? 0)),
                      icon: Icons.payments,
                      color: AppTheme.warning,
                      subtitle: 'QRIS & Cash',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Aksi Cepat',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _QuickAction(
                    icon: Icons.person_add,
                    label: 'Pasien Baru',
                    color: AppTheme.primary,
                    onTap: () {},
                  ),
                  _QuickAction(
                    icon: Icons.payment,
                    label: 'Pembayaran',
                    color: AppTheme.success,
                    onTap: () {},
                  ),
                  _QuickAction(
                    icon: Icons.medical_services,
                    label: 'Rekam Medis',
                    color: AppTheme.accent,
                    onTap: () {},
                  ),
                  _QuickAction(
                    icon: Icons.history,
                    label: 'Riwayat',
                    color: AppTheme.info,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Activities
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aktivitas Terkini',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._recentActivities.map((activity) => _ActivityTile(item: activity)),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(dynamic value) {
    final num amount = value is num ? value : 0;
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final DateTime time;

  _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

class _ActivityTile extends StatelessWidget {
  final _ActivityItem item;

  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(50),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            timeFormat.format(item.time),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
