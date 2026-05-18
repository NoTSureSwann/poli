import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/patient.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

class PatientDetailScreen extends StatelessWidget {
  final Patient patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pasien'),
        actions: [IconButton(icon: const Icon(Icons.edit), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
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
                border: Border.all(color: AppTheme.primary.withAlpha(50)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primary.withAlpha(50),
                    child: Text(
                      patient.nama.isNotEmpty
                          ? patient.nama[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    patient.nama,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${patient.id}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StatusBadge(
                        label: patient.hasBPJS ? 'Peserta BPJS' : 'Pasien Umum',
                        backgroundColor: patient.hasBPJS
                            ? AppTheme.success
                            : AppTheme.info,
                        icon: patient.hasBPJS ? Icons.verified : Icons.person,
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(
                        label: patient.genderLabel,
                        backgroundColor:
                            patient.jenisKelamin.toUpperCase() == 'L'
                            ? AppTheme.info
                            : AppTheme.accent,
                        icon: patient.jenisKelamin.toUpperCase() == 'L'
                            ? Icons.male
                            : Icons.female,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Info Cards
            _InfoSection(
              title: 'Informasi Pribadi',
              items: [
                _InfoRow(icon: Icons.badge, label: 'NIK', value: patient.nik),
                _InfoRow(
                  icon: Icons.cake,
                  label: 'Tanggal Lahir',
                  value:
                      '${dateFormat.format(patient.tanggalLahir)} (${patient.age})',
                ),
                _InfoRow(
                  icon: Icons.location_on,
                  label: 'Alamat',
                  value: patient.alamat,
                ),
                if (patient.phoneNumber != null)
                  _InfoRow(
                    icon: Icons.phone,
                    label: 'Telepon',
                    value: patient.phoneNumber!,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (patient.hasBPJS)
              _InfoSection(
                title: 'Informasi BPJS',
                items: [
                  _InfoRow(
                    icon: Icons.verified,
                    label: 'No. BPJS',
                    value: patient.noBPJS!,
                  ),
                  const _InfoRow(
                    icon: Icons.check_circle,
                    label: 'Status',
                    value: 'Aktif',
                  ),
                ],
              ),
            const SizedBox(height: 16),

            _InfoSection(
              title: 'Metadata',
              items: [
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Terdaftar Sejak',
                  value: dateFormat.format(patient.createdAt),
                ),
                _InfoRow(
                  icon: Icons.update,
                  label: 'Terakhir Diperbarui',
                  value: dateFormat.format(DateTime.now()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<_InfoRow> items;

  const _InfoSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: item,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
