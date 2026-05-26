import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:klinik_app/features/automation/presentation/providers/automation_provider.dart';

class DashboardDokterSipasScreen extends StatefulWidget {
  const DashboardDokterSipasScreen({super.key});

  @override
  State<DashboardDokterSipasScreen> createState() => _DashboardDokterSipasScreenState();
}

class _DashboardDokterSipasScreenState extends State<DashboardDokterSipasScreen> {
  final List<Map<String, dynamic>> _obatList = [];
  final _catatanController = TextEditingController();

  Future<void> _mintaSaranAI() async {
    // Asumsi data dummy pasien
    final namaPasien = 'Budi Santoso';
    final keluhan = 'Demam dan sakit kepala sejak 3 hari yang lalu, pasien riwayat mag.';
    
    final sukses = await context.read<AutomationProvider>().sendPrompt(
      namaPasien: namaPasien,
      keluhan: keluhan,
      catatanDokter: _catatanController.text,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(sukses ? 'Prompt berhasil dikirim ke Zapier/n8n!' : 'Gagal mengirim prompt ke webhook.'),
          backgroundColor: sukses ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _tambahObat() {
    setState(() {
      _obatList.add({
        'nama_obat': 'Paracetamol 500mg',
        'dosis': '',
        'qty': '',
        'aturan': '',
      });
    });
  }

  void _hapusObat(int index) {
    setState(() {
      _obatList.removeAt(index);
    });
  }

  void _kirimKeFarmasi() {
    if (_obatList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tambahkan minimal 1 obat')));
      return;
    }
    
    // Logika kirim resep dummy
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resep berhasil dikirim ke Farmasi')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Dokter (E-Prescribing)')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            // Wide Screen Layout (Desktop/Tablet)
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _buildPanelPasien()),
                const VerticalDivider(width: 1),
                Expanded(flex: 2, child: _buildPanelResep()),
              ],
            );
          } else {
            // Narrow Screen Layout (Mobile)
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildPanelPasien(),
                  const Divider(height: 1),
                  _buildPanelResep(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildPanelPasien() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PASIEN SAAT INI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('No. Antrian', style: TextStyle(color: Colors.grey)),
                  const Text('A-001', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const Divider(height: 24),
                  _infoRow('Nama', 'Budi Santoso'),
                  _infoRow('NIK', '3201123456780001'),
                  _infoRow('Tgl Lahir', '1990-05-12'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, color: Colors.red, size: 16),
                        SizedBox(width: 8),
                        Text('Alergi: Amoxicillin', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPanelResep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('E-PRESCRIBING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          
          // List Obat Dynamic
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _obatList.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<String>(
                          initialValue: _obatList[index]['nama_obat'],
                          decoration: const InputDecoration(labelText: 'Nama Obat', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'Paracetamol 500mg', child: Text('Paracetamol 500mg')),
                            DropdownMenuItem(value: 'Ibuprofen 400mg', child: Text('Ibuprofen 400mg')),
                            DropdownMenuItem(value: 'Vitamin C', child: Text('Vitamin C')),
                          ],
                          onChanged: (val) => setState(() => _obatList[index]['nama_obat'] = val!),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          initialValue: _obatList[index]['dosis'],
                          decoration: const InputDecoration(labelText: 'Dosis', border: OutlineInputBorder()),
                          onChanged: (val) => _obatList[index]['dosis'] = val,
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          initialValue: _obatList[index]['qty'],
                          decoration: const InputDecoration(labelText: 'Qty', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          onChanged: (val) => _obatList[index]['qty'] = val,
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: TextFormField(
                          initialValue: _obatList[index]['aturan'],
                          decoration: const InputDecoration(labelText: 'Aturan Pakai', border: OutlineInputBorder()),
                          onChanged: (val) => _obatList[index]['aturan'] = val,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _hapusObat(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _tambahObat,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Obat'),
          ),
          
          const SizedBox(height: 32),
          TextFormField(
            controller: _catatanController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Catatan Dokter',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Consumer<AutomationProvider>(
              builder: (context, automation, child) {
                return ElevatedButton.icon(
                  onPressed: automation.isLoading ? null : _mintaSaranAI,
                  icon: automation.isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.auto_awesome),
                  label: Text(automation.isLoading ? 'Memproses...' : 'Minta Saran AI (n8n/Zapier)', style: const TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _kirimKeFarmasi,
              icon: const Icon(Icons.send),
              label: const Text('Kirim ke Farmasi', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
