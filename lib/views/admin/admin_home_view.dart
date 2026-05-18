import 'package:flutter/material.dart';
import 'dokter/dokter_list_view.dart';
import 'pembayaran/struk_preview_view.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DokterListView())),
              child: const Text('Kelola Dokter'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StrukPreviewView(pembayaranId: 1))),
              child: const Text('Preview Struk Pembayaran 1'),
            ),
          ],
        ),
      ),
    );
  }
}
