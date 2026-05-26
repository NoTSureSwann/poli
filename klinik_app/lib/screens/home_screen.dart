import 'package:flutter/material.dart';
import '../features/poli/presentation/screens/daftar_poli_screen.dart';
import 'pendaftaran_screen.dart';
import 'riwayat_pasien_screen.dart';
import 'chat_ai_screen.dart';
import 'antrian_realtime_screen.dart';
import '../services/firebase_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Klinik Sehat Bersama'),
        actions: [
          IconButton(
            tooltip: 'Isi Data Dummy (Firebase)',
            icon: const Icon(Icons.cloud_upload),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menambahkan data awal poli...')),
              );
              await FirebaseService().seedPoliData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data berhasil ditambahkan! Coba cek "Daftar Poli" atau "Pendaftaran"')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Profil
            },
          )
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildMenuCard(context, 'Daftar Poli', Icons.local_hospital, Colors.blue, const DaftarPoliScreen()),
          _buildMenuCard(context, 'Pendaftaran', Icons.assignment, Colors.green, const PendaftaranScreen()),
          _buildMenuCard(context, 'Antrian Live', Icons.live_tv, Colors.red, const AntrianRealtimeScreen()),
          _buildMenuCard(context, 'Riwayat', Icons.history, Colors.orange, const RiwayatPasienScreen()),
          _buildMenuCard(context, 'Tanya AI', Icons.chat, Colors.purple, const ChatAiScreen()),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, Widget destination) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
