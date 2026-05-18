import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../bloc/payment_bloc.dart';
import '../../models/payment.dart';
import '../../theme/app_theme.dart';

class PaymentFormScreen extends StatefulWidget {
  const PaymentFormScreen({super.key});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pasienIdController = TextEditingController();
  final _pasienNamaController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rekeningDebitController = TextEditingController();

  PaymentType _selectedType = PaymentType.debit;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pasienIdController.dispose();
    _pasienNamaController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _rekeningDebitController.dispose();
    super.dispose();
  }

  /// Generate QRIS payload string from form fields
  String _generateQrisData() {
    final pasienId = _pasienIdController.text.isNotEmpty
        ? _pasienIdController.text
        : 'N/A';
    final nama = _pasienNamaController.text.isNotEmpty
        ? _pasienNamaController.text
        : 'N/A';
    final amount = _amountController.text.isNotEmpty
        ? _amountController.text
        : '0';
    // Standard-like QRIS payload (simplified for clinic use)
    return 'QRIS-KMP|ID:$pasienId|NAMA:$nama|AMT:$amount|TS:${DateTime.now().millisecondsSinceEpoch}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final qrisCode =
        _selectedType == PaymentType.qris ? _generateQrisData() : null;
    final rekeningDebit = _selectedType == PaymentType.debit
        ? _rekeningDebitController.text
        : null;

    context.read<PaymentBloc>().add(SubmitPayment(
          pasienId: _pasienIdController.text,
          pasienNama: _pasienNamaController.text,
          amount: double.parse(_amountController.text.replaceAll('.', '')),
          paymentType: _selectedType,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          rekeningDebit: rekeningDebit,
          qrisCode: qrisCode,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran Baru')),
      body: BlocListener<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSubmitted) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Pembayaran berhasil dicatat'),
                    ),
                  ],
                ),
                backgroundColor: AppTheme.success,
                duration: const Duration(seconds: 4),
              ),
            );
            Navigator.pop(context, true);
          } else if (state is PaymentError) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          } else if (state is PaymentSubmitting) {
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
                const SizedBox(height: 8),

                // ─── Payment Type Selector ──────────────────────
                Text(
                  'Tipe Pembayaran',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Row(
                  children: PaymentType.values.map((type) {
                    final isSelected = _selectedType == type;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _getTypeColor(type).withAlpha(30)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? _getTypeColor(type)
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _getTypeIcon(type),
                                color: isSelected
                                    ? _getTypeColor(type)
                                    : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                type.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? _getTypeColor(type)
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // ─── Core Form Fields ───────────────────────────
                TextFormField(
                  controller: _pasienIdController,
                  decoration: _inputDecoration(
                    label: 'ID Pasien',
                    icon: Icons.badge,
                    hint: 'Contoh: P0001',
                  ),
                  onChanged: (_) => _rebuildQris(),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'ID Pasien wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pasienNamaController,
                  decoration: _inputDecoration(
                    label: 'Nama Pasien',
                    icon: Icons.person,
                    hint: 'Masukkan nama lengkap',
                  ),
                  onChanged: (_) => _rebuildQris(),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    label: 'Jumlah (Rp)',
                    icon: Icons.attach_money,
                    hint: 'Contoh: 150000',
                  ),
                  onChanged: (_) => _rebuildQris(),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Jumlah wajib diisi';
                    }
                    final amount = double.tryParse(v.replaceAll('.', ''));
                    if (amount == null || amount <= 0) {
                      return 'Masukkan jumlah yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: _inputDecoration(
                    label: 'Keterangan',
                    icon: Icons.description,
                    hint: 'Contoh: Pemeriksaan umum',
                  ),
                ),
                const SizedBox(height: 16),

                // ─── DEBIT: Rekening Debit Field ────────────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _selectedType == PaymentType.debit
                      ? _buildRekeningDebitSection()
                      : const SizedBox.shrink(),
                ),

                // ─── QRIS: Barcode Section ──────────────────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _selectedType == PaymentType.qris
                      ? _buildQrisSection()
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 24),

                // ─── Submit Button ──────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      _isSubmitting
                          ? 'Memproses...'
                          : 'Simpan Pembayaran',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
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

  // ─── Rekening Debit Section ──────────────────────────────────────

  Widget _buildRekeningDebitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.info.withAlpha(15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.info.withAlpha(60)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance, color: AppTheme.info, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Informasi Rekening Debit',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rekeningDebitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'No. Rekening Debit',
                  hintText: 'Contoh: 1234567890',
                  prefixIcon: const Icon(Icons.credit_card),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.info.withAlpha(80)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.info, width: 2),
                  ),
                ),
                validator: (v) {
                  if (_selectedType == PaymentType.debit &&
                      (v == null || v.isEmpty)) {
                    return 'No. rekening wajib diisi untuk pembayaran debit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Masukkan nomor rekening debit pasien untuk proses pendebitan.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ─── QRIS QR Code Section ────────────────────────────────────────

  Widget _buildQrisSection() {
    final qrisData = _generateQrisData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.accent.withAlpha(20),
                AppTheme.accent.withAlpha(8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.accent.withAlpha(60)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_2, color: AppTheme.accent, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'QRIS Payment Code',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // QR Code container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withAlpha(20),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrisData,
                  version: QrVersions.auto,
                  size: 200,
                  gapless: true,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.circle,
                    color: Color(0xFF7C3AED),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.circle,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // QRIS label
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 14, color: AppTheme.accent),
                    const SizedBox(width: 4),
                    Text(
                      'Klinik Merah Putih — QRIS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Scan kode QR di atas untuk melakukan pembayaran.\nKode akan di-update otomatis sesuai data pasien.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Force rebuild to regenerate QR code when fields change
  void _rebuildQris() {
    if (_selectedType == PaymentType.qris) {
      setState(() {});
    }
  }

  // ─── Shared Helpers ──────────────────────────────────────────────

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
      ),
    );
  }

  Color _getTypeColor(PaymentType type) {
    switch (type) {
      case PaymentType.debit:
        return AppTheme.info;
      case PaymentType.qris:
        return AppTheme.accent;
      case PaymentType.cash:
        return AppTheme.success;
    }
  }

  IconData _getTypeIcon(PaymentType type) {
    switch (type) {
      case PaymentType.debit:
        return Icons.credit_card;
      case PaymentType.qris:
        return Icons.qr_code_scanner;
      case PaymentType.cash:
        return Icons.payments;
    }
  }
}
