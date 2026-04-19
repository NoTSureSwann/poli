import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  PaymentType _selectedType = PaymentType.debit;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pasienIdController.dispose();
    _pasienNamaController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<PaymentBloc>().add(SubmitPayment(
          pasienId: _pasienIdController.text,
          pasienNama: _pasienNamaController.text,
          amount: double.parse(_amountController.text.replaceAll('.', '')),
          paymentType: _selectedType,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
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
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Pembayaran berhasil dicatat',
                      ),
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
                const SizedBox(height: 24),

                // Payment Type selector
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
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
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

                // Form fields
                TextFormField(
                  controller: _pasienIdController,
                  decoration: _inputDecoration(
                    label: 'ID Pasien',
                    icon: Icons.badge,
                    hint: 'Contoh: P0001',
                  ),
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
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Jumlah wajib diisi';
                    }
                    final amount =
                        double.tryParse(v.replaceAll('.', ''));
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

                const SizedBox(height: 16),

                const SizedBox(height: 24),

                // Submit button
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
                        : const Icon(
                            Icons.save,
                          ),
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
