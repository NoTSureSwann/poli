import 'package:flutter/material.dart';
import 'package:klinik_app/features/poli/data/models/poli_model.dart';
import 'package:klinik_app/services/firebase/firebase_service.dart';
import 'package:klinik_app/services/api/mock_api_service.dart';

class AntrianRealtimeScreen extends StatefulWidget {
  const AntrianRealtimeScreen({super.key});

  @override
  State<AntrianRealtimeScreen> createState() => _AntrianRealtimeScreenState();
}

class _AntrianRealtimeScreenState extends State<AntrianRealtimeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final MockApiService _mockService = MockApiService();

  List<PoliModel> _daftarPoli = [];
  String? _selectedPoliId;
  late String _todayStr;

  @override
  void initState() {
    super.initState();
    _todayStr = DateTime.now().toIso8601String().split('T')[0];
    _loadPoli();
  }

  void _loadPoli() async {
    try {
      _firebaseService.getPoliStream().listen((data) {
        if (data.isNotEmpty && mounted) {
          setState(() {
            _daftarPoli = data;
            _selectedPoliId ??= data.first.id;
          });
        }
      }, onError: (_) async {
        final mockData = await _mockService.getDaftarPoli();
        if (mounted) {
          setState(() {
            _daftarPoli = mockData;
            _selectedPoliId ??= mockData.first.id;
          });
        }
      });
    } catch (_) {
      final mockData = await _mockService.getDaftarPoli();
      if (mounted) {
        setState(() {
          _daftarPoli = mockData;
          _selectedPoliId ??= mockData.first.id;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📺 Antrian Live')),
      body: Column(
        children: [
          // Poli selector
          if (_daftarPoli.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Pilih Poli',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedPoliId,
                items: _daftarPoli.map((poli) {
                  return DropdownMenuItem(value: poli.id, child: Text(poli.namaPoli));
                }).toList(),
                onChanged: (val) => setState(() => _selectedPoliId = val),
              ),
            ),

          // Header info
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Tanggal: $_todayStr  •  Data real-time',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.w500),
            ),
          ),

          const SizedBox(height: 8),

          // Real-time antrian list
          Expanded(
            child: _selectedPoliId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _firebaseService.getAntrianStream(_selectedPoliId!, _todayStr),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                              const SizedBox(height: 12),
                              const Text('Firebase belum dikonfigurasi.'),
                              const SizedBox(height: 4),
                              Text('Error: ${snapshot.error}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final antrian = snapshot.data ?? [];
                      if (antrian.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_available, size: 48, color: Colors.green),
                              SizedBox(height: 12),
                              Text('Belum ada antrian hari ini.'),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: antrian.length,
                        itemBuilder: (context, index) {
                          final item = antrian[index];
                          final status = (item['status'] as String?) ?? 'menunggu';
                          final nomor = item['nomor_antrian'] ?? (index + 1);

                          Color cardColor = Colors.white;
                          IconData statusIcon = Icons.hourglass_empty;
                          if (status == 'dilayani') {
                            cardColor = Colors.green.shade50;
                            statusIcon = Icons.person;
                          } else if (status == 'selesai') {
                            cardColor = Colors.grey.shade100;
                            statusIcon = Icons.check_circle;
                          } else if (status == 'batal') {
                            cardColor = Colors.red.shade50;
                            statusIcon = Icons.cancel;
                          }

                          return Card(
                            color: cardColor,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: status == 'dilayani' ? Colors.green : Colors.blue,
                                child: Text(
                                  '$nomor',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text('Antrian #$nomor'),
                              subtitle: Text('Status: ${status.toUpperCase()}'),
                              trailing: Icon(statusIcon, color: status == 'dilayani' ? Colors.green : Colors.grey),
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
