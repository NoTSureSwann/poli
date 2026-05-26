import 'package:flutter/material.dart';
import '../../data/models/poli_model.dart';
import '../../../../services/firebase_service.dart';
import '../../../../services/mock_api_service.dart';
import '../../../../screens/pendaftaran_screen.dart';

class DaftarPoliScreen extends StatefulWidget {
  const DaftarPoliScreen({super.key});

  @override
  State<DaftarPoliScreen> createState() => _DaftarPoliScreenState();
}

class _DaftarPoliScreenState extends State<DaftarPoliScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final MockApiService _mockService = MockApiService();
  String _searchQuery = '';

  /// Gunakan Firebase stream jika tersedia, fallback ke MockAPI.
  late Stream<List<PoliModel>> _poliStream;
  bool _useFirebase = true;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    try {
      _poliStream = _firebaseService.getPoliStream();
    } catch (e) {
      _useFirebase = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Poli')),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Cari Poli...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          // Real-time list
          Expanded(
            child: _useFirebase
                ? _buildFirebaseList()
                : _buildMockList(),
          ),
        ],
      ),
    );
  }

  /// StreamBuilder: real-time dari Cloud Firestore.
  Widget _buildFirebaseList() {
    return StreamBuilder<List<PoliModel>>(
      stream: _poliStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allPoli = snapshot.data ?? [];
        // Jika Firestore kosong, fallback ke mock
        if (allPoli.isEmpty) {
          return _buildMockList();
        }
        return _buildPoliListView(_filterPoli(allPoli));
      },
    );
  }

  /// FutureBuilder fallback: data dummy dari MockAPI.
  Widget _buildMockList() {
    return FutureBuilder<List<PoliModel>>(
      future: _mockService.getDaftarPoli(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data ?? [];
        return _buildPoliListView(_filterPoli(data));
      },
    );
  }

  List<PoliModel> _filterPoli(List<PoliModel> poli) {
    if (_searchQuery.isEmpty) return poli;
    return poli
        .where((p) => p.namaPoli.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Widget _buildPoliListView(List<PoliModel> poli) {
    if (poli.isEmpty) {
      return const Center(child: Text('Tidak ada poli ditemukan.'));
    }
    
    // Group by kategori
    final Map<String, List<PoliModel>> groupedPoli = {};
    for (var p in poli) {
      groupedPoli.putIfAbsent(p.kategori, () => []).add(p);
    }

    return ListView.builder(
      itemCount: groupedPoli.length,
      itemBuilder: (context, index) {
        final kategori = groupedPoli.keys.elementAt(index);
        final subPoliList = groupedPoli[kategori]!;

        return ExpansionTile(
          title: Text(
            'Kategori: $kategori', 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          initiallyExpanded: true,
          children: subPoliList.map((item) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.local_hospital)),
                title: Text(item.namaPoli, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${item.deskripsi}\nBuka: ${item.jamBuka} - ${item.jamTutup}'),
                isThreeLine: true,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PendaftaranScreen(initialPoliId: item.id),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
