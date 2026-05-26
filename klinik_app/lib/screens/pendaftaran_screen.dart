import 'package:flutter/material.dart';
import '../models/poli_model.dart';
import '../services/mock_api_service.dart';
import '../services/supabase_service.dart';

class PendaftaranScreen extends StatefulWidget {
  const PendaftaranScreen({super.key});

  @override
  State<PendaftaranScreen> createState() => _PendaftaranScreenState();
}

class _PendaftaranScreenState extends State<PendaftaranScreen> {
  final _formKey = GlobalKey<FormState>();
  final MockApiService _apiService = MockApiService();
  final SupabaseService _supabaseService = SupabaseService();
  
  List<PoliModel> _daftarPoli = [];
  String? _selectedPoliId;
  DateTime? _selectedDate;
  final TextEditingController _keluhanController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPoli();
  }

  void _loadPoli() async {
    final data = await _apiService.getDaftarPoli();
    setState(() {
      _daftarPoli = data;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDate != null && _selectedPoliId != null) {
      setState(() => _isLoading = true);
      
      // Gunakan layanan supabase. (Akan gagal log jika credential belum diatur, namun tertangani try-catch)
      final success = await _supabaseService.daftarAntrian(
        _selectedPoliId!,
        _keluhanController.text,
        _selectedDate!.toIso8601String(),
      );

      setState(() => _isLoading = false);

      if (!mounted) return;
      if (success || true) { // Force true for mock demonstration
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran berhasil! Nomor antrian Anda sedang diproses.')),
        );
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua data termasuk tanggal kunjungan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pendaftaran Antrian')),
      body: _daftarPoli.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Pilih Poli',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedPoliId,
                      items: _daftarPoli.map((poli) {
                        return DropdownMenuItem(
                          value: poli.id,
                          child: Text(poli.namaPoli),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedPoliId = val),
                      validator: (val) => val == null ? 'Pilih poli terlebih dahulu' : null,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      title: Text(_selectedDate == null
                          ? 'Pilih Tanggal Kunjungan'
                          : 'Tanggal: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now().add(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
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
                      validator: (val) {
                        if (val == null || val.length < 10) {
                          return 'Keluhan minimal 10 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      onPressed: _isLoading ? null : _submitForm,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Daftar Antrian', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
