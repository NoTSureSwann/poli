import 'package:flutter/material.dart';
import '../models/poli_model.dart';
import '../services/mock_api_service.dart';

class DaftarPoliScreen extends StatefulWidget {
  const DaftarPoliScreen({super.key});

  @override
  State<DaftarPoliScreen> createState() => _DaftarPoliScreenState();
}

class _DaftarPoliScreenState extends State<DaftarPoliScreen> {
  final MockApiService _apiService = MockApiService();
  late Future<List<PoliModel>> _futurePoli;
  List<PoliModel> _allPoli = [];
  List<PoliModel> _filteredPoli = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    _futurePoli = _apiService.getDaftarPoli();
    _futurePoli.then((data) {
      setState(() {
        _allPoli = data;
        _filteredPoli = data;
      });
    });
  }

  void _filterPoli(String query) {
    setState(() {
      _filteredPoli = _allPoli
          .where((poli) => poli.namaPoli.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Poli')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterPoli,
              decoration: InputDecoration(
                hintText: 'Cari Poli...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<PoliModel>>(
              future: _futurePoli,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Gagal memuat data.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada poli tersedia.'));
                }

                return ListView.builder(
                  itemCount: _filteredPoli.length,
                  itemBuilder: (context, index) {
                    final poli = _filteredPoli[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(child: Icon(Icons.local_hospital)),
                        title: Text(poli.namaPoli, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${poli.deskripsi}\nBuka: ${poli.jamBuka} - ${poli.jamTutup}'),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
