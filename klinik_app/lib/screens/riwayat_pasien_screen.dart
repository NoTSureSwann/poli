import 'package:flutter/material.dart';
import '../services/mock_api_service.dart';

class RiwayatPasienScreen extends StatefulWidget {
  const RiwayatPasienScreen({super.key});

  @override
  State<RiwayatPasienScreen> createState() => _RiwayatPasienScreenState();
}

class _RiwayatPasienScreenState extends State<RiwayatPasienScreen> {
  final MockApiService _apiService = MockApiService();
  late Future<List<Map<String, dynamic>>> _futureRiwayat;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureRiwayat = _apiService.getRiwayatPasien();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Kunjungan')),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureRiwayat,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Belum ada riwayat kunjungan.'));
            }

            final data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                final status = item['status'] as String;
                
                Color statusColor = Colors.grey;
                if (status == 'selesai') statusColor = Colors.green;
                if (status == 'menunggu') statusColor = Colors.orange;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('Tanggal: ${item['tanggal']}'),
                    subtitle: Text('Poli: ${item['poli']['nama_poli']}\nKeluhan: ${item['keluhan']}'),
                    isThreeLine: true,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
