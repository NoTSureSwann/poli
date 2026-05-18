import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/medical_record_bloc.dart';
import '../../models/medical_record.dart';
import '../../theme/app_theme.dart';

class MedicalRecordFormScreen extends StatefulWidget {
  final String? initialPasienId;
  const MedicalRecordFormScreen({super.key, this.initialPasienId});

  @override
  State<MedicalRecordFormScreen> createState() => _MedicalRecordFormScreenState();
}

class _MedicalRecordFormScreenState extends State<MedicalRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _pasienIdController;
  late TextEditingController _doctorNameController;
  late TextEditingController _diagnosisController;
  late TextEditingController _treatmentController;
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _pasienIdController = TextEditingController(text: widget.initialPasienId);
    _doctorNameController = TextEditingController(text: 'dr. Budi Santoso'); // Default for demo
    _diagnosisController = TextEditingController();
    _treatmentController = TextEditingController();
  }

  @override
  void dispose() {
    _pasienIdController.dispose();
    _doctorNameController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final record = MedicalRecordModel(
      id: 'REC${DateTime.now().millisecondsSinceEpoch.toString().substring(10)}',
      pasienId: _pasienIdController.text,
      pasienNama: 'Pasien...', // In real app, look up from ID
      doctorName: _doctorNameController.text,
      diagnosis: _diagnosisController.text,
      treatment: _treatmentController.text,
      timestamp: DateTime.now(),
    );

    context.read<MedicalRecordBloc>().add(CreateRecord(record));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rekam Medis Baru')),
      body: BlocListener<MedicalRecordBloc, MedicalRecordState>(
        listener: (context, state) {
          if (state is RecordSubmitted) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rekam medis berhasil disimpan'),
                backgroundColor: AppTheme.success,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is RecordError) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          } else if (state is RecordSubmitting) {
            setState(() => _isSubmitting = true);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader('Informasi Pemeriksaan'),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _pasienIdController,
                  decoration: _inputDecoration(
                    label: 'ID Pasien',
                    icon: Icons.person_search,
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'ID Pasien wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _doctorNameController,
                  decoration: _inputDecoration(
                    label: 'Nama Dokter',
                    icon: Icons.medical_services,
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Nama dokter wajib diisi' : null,
                ),
                const SizedBox(height: 24),
                _buildHeader('Hasil Diagnosa'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _diagnosisController,
                  maxLines: 2,
                  decoration: _inputDecoration(
                    label: 'Diagnosa',
                    icon: Icons.assignment,
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Diagnosa wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _treatmentController,
                  maxLines: 4,
                  decoration: _inputDecoration(
                    label: 'Tindakan / Terapi',
                    icon: Icons.healing,
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Tindakan wajib diisi' : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Simpan Rekam Medis',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.accent,
          ),
        ),
        Container(
          height: 2,
          width: 40,
          margin: const EdgeInsets.only(top: 4),
          color: AppTheme.accent.withAlpha(50),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
