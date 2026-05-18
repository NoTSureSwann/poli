import 'package:flutter/material.dart';
import 'dokter_publik_view.dart';
import '../publik/tarif_view.dart';

class PasienHomeView extends StatelessWidget {
  const PasienHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pasien Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DokterPublikView())),
              child: const Text('Daftar Dokter'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TarifView())),
              child: const Text('Tarif Klinik'),
            ),
          ],
        ),
      ),
    );
  }
}
