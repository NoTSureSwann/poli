import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/patient_bloc.dart';
import '../../models/patient.dart';
import '../../theme/app_theme.dart';

class PatientFormScreen extends StatefulWidget {
  final Patient? patient;
  const PatientFormScreen({super.key, this.patient});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _nikController;
  late TextEditingController _alamatController;
  late TextEditingController _noBpjsController;
  late TextEditingController _phoneController;
  
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 365 * 25));
  String _selectedGender = 'L';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.patient?.nama);
    _nikController = TextEditingController(text: widget.patient?.nik);
    _alamatController = TextEditingController(text: widget.patient?.alamat);
    _noBpjsController = TextEditingController(text: widget.patient?.noBPJS);
    _phoneController = TextEditingController(text: widget.patient?.phoneNumber);
    
    if (widget.patient != null) {
      _selectedDate = widget.patient!.tanggalLahir;
      _selectedGender = widget.patient!.jenisKelamin;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _alamatController.dispose();
    _noBpjsController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final patient = Patient(
      id: widget.patient?.id ?? '',
      nama: _namaController.text,
      nik: _nikController.text,
      tanggalLahir: _selectedDate,
      alamat: _alamatController.text,
      jenisKelamin: _selectedGender,
      noBPJS: _noBpjsController.text.isNotEmpty ? _noBpjsController.text : null,
      phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
    );

    context.read<PatientBloc>().add(CreatePatient(patient));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient == null ? 'Registrasi Pasien Baru' : 'Edit Pasien'),
      ),
      body: BlocListener<PatientBloc, PatientState>(
        listener: (context, state) {
          if (state is PatientSubmitted) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data pasien berhasil disimpan'),
                backgroundColor: AppTheme.success,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is PatientError) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          } else if (state is PatientSubmitting) {
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
                _buildHeader('Informasi Dasar'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _namaController,
                  decoration: _inputDecoration(
                    label: 'Nama Lengkap',
                    icon: Icons.person,
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nikController,
                  decoration: _inputDecoration(
                    label: 'NIK (16 Digit)',
                    icon: Icons.badge,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'NIK wajib diisi';
                    if (v.length != 16) return 'NIK harus 16 digit';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: _inputDecorator(
                          label: 'Tanggal Lahir',
                          icon: Icons.calendar_today,
                          value: DateFormat('dd/MM/yyyy').format(_selectedDate),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jenis Kelamin', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedGender,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                                  DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                                ],
                                onChanged: (v) => setState(() => _selectedGender = v!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                _buildHeader('Kontak & Alamat'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: _inputDecoration(
                    label: 'Nomor Telepon',
                    icon: Icons.phone,
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _alamatController,
                  maxLines: 3,
                  decoration: _inputDecoration(
                    label: 'Alamat Tinggal',
                    icon: Icons.home,
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Alamat wajib diisi' : null,
                ),
                
                const SizedBox(height: 24),
                _buildHeader('Asuransi (Opsional)'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noBpjsController,
                  decoration: _inputDecoration(
                    label: 'Nomor BPJS',
                    icon: Icons.credit_card,
                  ),
                  keyboardType: TextInputType.number,
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
                        : Text(
                            widget.patient == null ? 'Daftar Pasien' : 'Simpan Perubahan',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
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
            color: AppTheme.primary,
          ),
        ),
        Container(
          height: 2,
          width: 40,
          margin: const EdgeInsets.only(top: 4),
          color: AppTheme.accent,
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

  Widget _inputDecorator({required String label, required IconData icon, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}
