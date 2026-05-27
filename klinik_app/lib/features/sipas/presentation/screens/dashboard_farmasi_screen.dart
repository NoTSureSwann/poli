import 'package:flutter/material.dart';
import 'package:klinik_app/core/utils/pdf_service.dart';
import 'package:intl/intl.dart';

class DashboardFarmasiScreen extends StatefulWidget {
  const DashboardFarmasiScreen({super.key});

  @override
  State<DashboardFarmasiScreen> createState() => _DashboardFarmasiScreenState();
}

class _DashboardFarmasiScreenState extends State<DashboardFarmasiScreen> {
  // Dummy data resep
  List<Map<String, dynamic>> resepList = [
    {
      'id': 'RSP-001', 'nama': 'Budi Santoso', 'nik': '3201123456780001', 'jenis': 'BPJS',
      'jam': '09:00', 'status': 'MENUNGGU',
      'items': [
        {'nama_obat': 'Paracetamol 500mg', 'dosis': '500mg', 'qty': '10', 'aturan': '3x1'}
      ]
    },
    {
      'id': 'RSP-002', 'nama': 'Siti Aminah', 'nik': '3201123456780002', 'jenis': 'Umum',
      'jam': '09:15', 'status': 'MENUNGGU',
      'total': 45000,
      'items': [
        {'nama_obat': 'Amoxicillin', 'dosis': '500mg', 'qty': '15', 'aturan': '3x1'}
      ]
    },
    {
      'id': 'RSP-003', 'nama': 'Andi Pratama', 'nik': '3201123456780003', 'jenis': 'BPJS',
      'jam': '08:45', 'status': 'DIPROSES',
      'items': [
        {'nama_obat': 'Vitamin C', 'dosis': '50mg', 'qty': '30', 'aturan': '1x1'}
      ]
    },
    {
      'id': 'RSP-004', 'nama': 'Ratna Sari', 'nik': '3201123456780004', 'jenis': 'Umum',
      'jam': '08:00', 'status': 'SELESAI',
      'total': 25000,
      'items': [
        {'nama_obat': 'Ibuprofen', 'dosis': '400mg', 'qty': '10', 'aturan': 'PRN'}
      ]
    },
  ];

  void _prosesResep(int index, String statusSekarang) {
    setState(() {
      if (statusSekarang == 'MENUNGGU') {
        resepList[index]['status'] = 'DIPROSES';
      } else if (statusSekarang == 'DIPROSES') {
        resepList[index]['status'] = 'SELESAI';
      }
    });
  }

  Future<void> _cetakResep(Map<String, dynamic> resep) async {
    resep['tanggal'] = DateFormat('dd/MM/yyyy').format(DateTime.now());
    resep['dokter'] = 'dr. Dummy';
    await PdfService().generateStrukPDF(resep);
  }

  @override
  Widget build(BuildContext context) {
    final menunggu = resepList.where((e) => e['status'] == 'MENUNGGU').toList();
    final diproses = resepList.where((e) => e['status'] == 'DIPROSES').toList();
    final selesai = resepList.where((e) => e['status'] == 'SELESAI').toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Farmasi (Kanban)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildKanbanColumn('MENUNGGU', Colors.amber, menunggu)),
            const SizedBox(width: 16),
            Expanded(child: _buildKanbanColumn('DIPROSES', Colors.blue, diproses)),
            const SizedBox(width: 16),
            Expanded(child: _buildKanbanColumn('SELESAI', Colors.green, selesai)),
          ],
        ),
      ),
    );
  }

  Widget _buildKanbanColumn(String title, Color color, List<Map<String, dynamic>> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color.withValues(alpha: 0.8))),
                CircleAvatar(radius: 12, backgroundColor: color, child: Text('${data.length}', style: const TextStyle(fontSize: 12, color: Colors.white))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                final realIndex = resepList.indexOf(item);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item['id'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: item['jenis'] == 'BPJS' ? Colors.teal : Colors.orange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(item['jenis'], style: const TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Jml Obat: ${(item['items'] as List).length} item | Jam: ${item['jam']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (item['status'] != 'SELESAI')
                              TextButton(
                                onPressed: () => _prosesResep(realIndex, item['status']),
                                child: Text(item['status'] == 'MENUNGGU' ? 'Proses' : 'Selesaikan'),
                              ),
                            IconButton(
                              icon: const Icon(Icons.print, color: Colors.grey),
                              onPressed: () => _cetakResep(item),
                              tooltip: 'Cetak PDF',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
