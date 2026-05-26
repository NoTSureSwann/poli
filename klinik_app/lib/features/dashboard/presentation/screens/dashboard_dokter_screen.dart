import 'package:flutter/material.dart';

class DashboardDokterScreen extends StatelessWidget {
  const DashboardDokterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Dokter Spesialis')),
      body: const Center(
        child: Text('Selamat datang, Dokter! (Fitur segera hadir)'),
      ),
    );
  }
}
