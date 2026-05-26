import 'package:flutter/material.dart';

class DashboardAdminScreen extends StatelessWidget {
  const DashboardAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Admin')),
      body: const Center(
        child: Text('Selamat datang, Admin! (Fitur segera hadir)'),
      ),
    );
  }
}
