import 'package:flutter/material.dart';
import 'package:klinik_app/core/utils/pdf_service.dart';
import 'package:intl/intl.dart';

class FormPendaftaranSipasScreen extends StatefulWidget {
  const FormPendaftaranSipasScreen({super.key});

  @override
  State<FormPendaftaranSipasScreen> createState() => _FormPendaftaranSipasScreenState();
}

class _FormPendaftaranSipasScreenState extends State<FormPendaftaranSipasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  final _keluhanController = TextEditingController();
  
  String? _selectedPoli;
  String _jenisPasien = 'Umum';
  Map<String, dynamic>? _patientInfo;
  
  final List<Map<String, dynamic>> _dummyPatients = [
    {'nik': '3201123456780001', 'nama': 'Budi Santoso', 'tgl_lahir': '1990-05-12', 'alergi': 'Amoxicillin'},
    {'nik': '3201123456780002', 'nama': 'Siti Aminah', 'tgl_lahir': '1985-11-20', 'alergi': 'Tidak ada'},
  ];

  void _searchPasien() {
    final nik = _nikController.text;
    final found = _dummyPatients.firstWhere((p) => p['nik'] == nik, orElse: () => {});
    
    setState(() {
      if (found.isNotEmpty) {
        _patientInfo = found;
      } else {
        _patientInfo = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pasien tidak ditemukan, silakan isi data baru.')),
        );
      }
    });
  }

  void _simpanDanCetak() async {
    if (!_formKey.currentState!.validate() || _selectedPoli == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap lengkapi semua data')));
      return;
    }

    final String noAntrian = 'A-${DateTime.now().millisecondsSinceEpoch.toString().substring(10)}';
    
    final resepData = {
      'nama': _patientInfo?['nama'] ?? 'Pasien Baru',
      'nik': _nikController.text,
      'tanggal': DateFormat('dd/MM/yyyy').format(DateTime.now()),
      'dokter': '-', // Belum ditentukan di loket
      'no_antrian': noAntrian,
      'jenis': _jenisPasien,
      'total': 0, // Hanya struk antrian
    };

    await PdfService().generateStrukPDF(resepData);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Berhasil mendaftar. No Antrian: $noAntrian')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Pendaftaran Pasien Klinik App')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search NIK
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nikController,
                      decoration: const InputDecoration(
                        labelText: 'NIK / No. BPJS',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'NIK harus diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _searchPasien,
                    icon: const Icon(Icons.search),
                    label: const Text('Cari'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (_patientInfo != null)
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nama: ${_patientInfo!['nama']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Tgl Lahir: ${_patientInfo!['tgl_lahir']}'),
                        Text('Alergi: ${_patientInfo!['alergi']}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              else if (_nikController.text.isNotEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Data pasien baru. Harap lengkapi identitas di sistem rekam medis utama (Dummy).'),
                  ),
                ),

              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Poli Tujuan', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Umum', child: Text('Umum')),
                  DropdownMenuItem(value: 'Gigi', child: Text('Gigi')),
                  DropdownMenuItem(value: 'KIA/KB', child: Text('KIA/KB')),
                  DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
                ],
                onChanged: (val) => setState(() => _selectedPoli = val),
              ),
              const SizedBox(height: 16),
              
              // Jenis Pasien
              const Text('Jenis Penjamin', style: TextStyle(fontWeight: FontWeight.bold)),
              RadioGroup<String>(
                groupValue: _jenisPasien,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _jenisPasien = val);
                  }
                },
                child: Row(
                  children: [
                    Radio<String>(
                      value: 'Umum',
                    ),
                    const Text('Umum'),
                    const SizedBox(width: 24),
                    Radio<String>(
                      value: 'BPJS',
                    ),
                    const Text('BPJS'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _keluhanController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Keluhan Pasien',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.length < 10 ? 'Keluhan minimal 10 karakter' : null,
              ),
              
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _simpanDanCetak,
                icon: const Icon(Icons.print),
                label: const Text('Simpan & Cetak Antrian', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
