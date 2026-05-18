import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/dokter_viewmodel.dart';
import '../../../data/models/dokter_model.dart';

class DokterFormView extends StatefulWidget {
  final DokterModel? dokter;

  const DokterFormView({super.key, this.dokter});

  @override
  State<DokterFormView> createState() => _DokterFormViewState();
}

class _DokterFormViewState extends State<DokterFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaCtrl;
  late TextEditingController _spesialisasiCtrl;
  late TextEditingController _hargaCtrl;
  late TextEditingController _jadwalCtrl;

  String _tipe = 'umum';
  bool _statusAktif = true;
  // Hardcoded for now. In a real app, fetch from PoliViewModel
  int? _poliId = 1;

  @override
  void initState() {
    super.initState();
    final d = widget.dokter;
    _namaCtrl = TextEditingController(text: d?.nama ?? '');
    _spesialisasiCtrl = TextEditingController(text: d?.spesialisasi ?? '');
    _hargaCtrl = TextEditingController(
      text: d?.hargaKonsultasi.toString() ?? '50000',
    );
    _jadwalCtrl = TextEditingController(text: d?.jadwal ?? '');

    if (d != null) {
      _tipe = d.tipe;
      _statusAktif = d.statusAktif;
      _poliId = d.poliId;
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _spesialisasiCtrl.dispose();
    _hargaCtrl.dispose();
    _jadwalCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'nama': _namaCtrl.text,
        'tipe': _tipe,
        'spesialisasi': _tipe != 'umum' ? _spesialisasiCtrl.text : null,
        'poli_id': _poliId,
        'harga_konsultasi': int.tryParse(_hargaCtrl.text) ?? 50000,
        'jadwal': _jadwalCtrl.text,
        'status_aktif': _statusAktif ? 1 : 0,
      };

      final vm = context.read<DokterViewModel>();
      bool success;
      if (widget.dokter == null) {
        success = await vm.tambahDokter(data);
      } else {
        success = await vm.editDokter(widget.dokter!.id, data);
      }

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil menyimpan dokter')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: ${vm.errorMsg}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dokter == null ? 'Tambah Dokter' : 'Edit Dokter'),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _namaCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Dokter',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _tipe,
              decoration: const InputDecoration(
                labelText: 'Tipe',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'umum', child: Text('Umum')),
                DropdownMenuItem(value: 'poli', child: Text('Poli')),
                DropdownMenuItem(value: 'spesialis', child: Text('Spesialis')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _tipe = val);
              },
            ),
            if (_tipe != 'umum') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _spesialisasiCtrl,
                decoration: const InputDecoration(
                  labelText: 'Spesialisasi',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _hargaCtrl,
              decoration: const InputDecoration(
                labelText: 'Harga Konsultasi',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jadwalCtrl,
              decoration: const InputDecoration(
                labelText: 'Jadwal Praktek',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Status Aktif'),
              value: _statusAktif,
              onChanged: (val) => setState(() => _statusAktif = val),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _submit,
              child: const Text('SIMPAN'),
            ),
          ],
        ),
      ),
    );
  }
}
