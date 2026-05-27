import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:klinik_app/features/sipas/presentation/screens/form_pendaftaran_sipas_screen.dart';
import 'package:klinik_app/core/utils/security_utils.dart';

class DashboardLoketScreen extends StatelessWidget {
  const DashboardLoketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String todayDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());
    final String petugasName = "Petugas Loket";

    // Dummy Data
    final List<Map<String, dynamic>> dummyAntrian = [
      {'no': 'A-001', 'nama': 'Budi Santoso', 'nik': '3201123456780001', 'poli': 'Umum', 'status': 'Selesai'},
      {'no': 'A-002', 'nama': 'Siti Aminah', 'nik': '3201123456780002', 'poli': 'Gigi', 'status': 'Sedang Dilayani'},
      {'no': 'A-003', 'nama': 'Andi Pratama', 'nik': '3201123456780003', 'poli': 'Umum', 'status': 'Menunggu'},
      {'no': 'A-004', 'nama': 'Ratna Sari', 'nik': '3201123456780004', 'poli': 'KIA/KB', 'status': 'Menunggu'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Loket - $petugasName'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(todayDate, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 4 Stat Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: [
                _buildStatCard('Total Pasien', '45', Colors.blue, FontAwesomeIcons.users),
                _buildStatCard('Pasien Baru', '12', Colors.green, FontAwesomeIcons.userPlus),
                _buildStatCard('Pasien BPJS', '30', Colors.teal, FontAwesomeIcons.idCard),
                _buildStatCard('Pasien Umum', '15', Colors.orange, FontAwesomeIcons.wallet),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Daftar Antrian Hari Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // List / Table Antrian
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dummyAntrian.length,
              itemBuilder: (context, index) {
                final item = dummyAntrian[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(item['no'], style: const TextStyle(fontSize: 12, color: Colors.blue)),
                    ),
                    title: Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('NIK: ${SecurityUtils.maskNik(item['nik'])} | Poli: ${item['poli']}'),
                    trailing: _buildStatusBadge(item['status']),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FormPendaftaranSipasScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Daftarkan Pasien Baru'),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, dynamic icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            FaIcon(icon, size: 32, color: color.withValues(alpha: 0.7)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    if (status == 'Menunggu') {
      bgColor = Colors.amber;
    } else if (status == 'Sedang Dilayani') {
      bgColor = Colors.blue;
    } else {
      bgColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
