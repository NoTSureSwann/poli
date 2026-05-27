import 'package:flutter/material.dart';
import 'package:klinik_app/features/poli/data/models/poli_model.dart';
import 'package:klinik_app/services/firebase/firebase_service.dart';
import 'package:klinik_app/services/api/mock_api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:klinik_app/core/utils/security_utils.dart';

class PendaftaranScreen extends StatefulWidget {
  final String? initialPoliId;

  const PendaftaranScreen({super.key, this.initialPoliId});

  @override
  State<PendaftaranScreen> createState() => _PendaftaranScreenState();
}

class _PendaftaranScreenState extends State<PendaftaranScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();
  final MockApiService _mockService = MockApiService();

  List<PoliModel> _daftarPoli = [];
  String? _selectedPoliId;
  DateTime? _selectedDate;
  final TextEditingController _keluhanController = TextEditingController();
  bool _isLoading = false;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    _selectedPoliId = widget.initialPoliId;
    _loadPoli();
  }

  void _loadPoli() async {
    // Coba ambil dari Firebase stream, jika gagal gunakan MockAPI
    try {
      _firebaseService.getPoliStream().listen((data) {
        if (data.isNotEmpty && mounted) {
          setState(() => _daftarPoli = data);
        }
      }, onError: (_) async {
        final mockData = await _mockService.getDaftarPoli();
        if (mounted) setState(() => _daftarPoli = mockData);
      });
    } catch (e) {
      final mockData = await _mockService.getDaftarPoli();
      if (mounted) setState(() => _daftarPoli = mockData);
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null || _selectedPoliId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua data termasuk tanggal kunjungan.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _isValidating = true;
    });

    final tanggalStr = _selectedDate!.toIso8601String().split('T')[0];

    // ─── VALIDASI REAL-TIME ────────────────────────────────
    // 1. Validasi poli masih ada di database
    final poliValid = await _firebaseService.validatePoli(_selectedPoliId!);
    if (!poliValid) {
      if (!mounted) return;
      setState(() { _isLoading = false; _isValidating = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠ Poli tidak ditemukan atau sudah dihapus.'), backgroundColor: Colors.red),
      );
      return;
    }

    // 2. Validasi slot antrian tersedia
    final slotAvailable = await _firebaseService.validateAntrianSlot(_selectedPoliId!, tanggalStr);
    if (!slotAvailable) {
      if (!mounted) return;
      setState(() { _isLoading = false; _isValidating = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠ Slot antrian penuh untuk tanggal ini.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isValidating = false);

    // [SEC-05 FIX]: Enforce login wajib sebelum daftar antrian
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      if (!mounted) return;
      setState(() { _isLoading = false; _isValidating = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠ Anda harus login terlebih dahulu untuk mendaftar antrian.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final pasienId = currentUser.id;

    // ─── INSERT ANTRIAN ────────────────────────────────────
    // [SEC-14 FIX]: Sanitasi input keluhan untuk mencegah XSS/injection
    final sanitizedKeluhan = SecurityUtils.sanitizeInput(_keluhanController.text);
    
    final nomorAntrian = await _firebaseService.daftarAntrian(
      pasienId: pasienId,
      poliId: _selectedPoliId!,
      keluhan: sanitizedKeluhan,
      tanggal: tanggalStr,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (nomorAntrian > 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('✅ Pendaftaran Berhasil!'),
          content: Text(
            'Nomor antrian Anda: $nomorAntrian\n'
            'Tanggal: $tanggalStr\n\n'
            'Silakan datang 15 menit sebelum jadwal.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mendaftarkan antrian. Silakan coba lagi.')),
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
                      initialValue: _selectedPoliId,
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
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                                const SizedBox(width: 12),
                                Text(_isValidating ? 'Memvalidasi...' : 'Mendaftar...'),
                              ],
                            )
                          : const Text('Daftar Antrian', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
