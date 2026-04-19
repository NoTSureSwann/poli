import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/payment_bloc.dart';
import '../../models/payment.dart';
import '../../theme/app_theme.dart';
import '../../widgets/paginated_list.dart';
import '../../widgets/status_badge.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  PaymentType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(LoadPayments());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter chips
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'Semua',
                  isSelected: _selectedFilter == null,
                  onTap: () {
                    setState(() => _selectedFilter = null);
                    context.read<PaymentBloc>().add(LoadPayments());
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'DEBIT',
                  isSelected: _selectedFilter == PaymentType.debit,
                  color: AppTheme.info,
                  onTap: () {
                    setState(() => _selectedFilter = PaymentType.debit);
                    context.read<PaymentBloc>().add(
                        LoadPayments(filterType: PaymentType.debit));
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'QRIS',
                  isSelected: _selectedFilter == PaymentType.qris,
                  color: AppTheme.accent,
                  onTap: () {
                    setState(() => _selectedFilter = PaymentType.qris);
                    context.read<PaymentBloc>().add(
                        LoadPayments(filterType: PaymentType.qris));
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'TUNAI',
                  isSelected: _selectedFilter == PaymentType.cash,
                  color: AppTheme.success,
                  onTap: () {
                    setState(() => _selectedFilter = PaymentType.cash);
                    context.read<PaymentBloc>().add(
                        LoadPayments(filterType: PaymentType.cash));
                  },
                ),
              ],
            ),
          ),
        ),

        // Payment list
        Expanded(
          child: BlocConsumer<PaymentBloc, PaymentState>(
            listener: (context, state) {
              if (state is PaymentSubmitted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Pembayaran berhasil dicatat',
                    ),
                    backgroundColor: AppTheme.success,
                  ),
                );
                context.read<PaymentBloc>().add(LoadPayments());
              }
            },
            builder: (context, state) {
              if (state is PaymentLoading) {
                return PaginatedListView<PaymentModel>(
                  items: const [],
                  itemBuilder: (context, payment, index) => const SizedBox(),
                  isInitialLoading: true,
                );
              }

              if (state is PaymentError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppTheme.error),
                      const SizedBox(height: 16),
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.read<PaymentBloc>().add(LoadPayments()),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }

              List<PaymentModel> payments = [];
              bool hasReachedMax = false;
              bool isLoadingMore = false;
              int totalCount = 0;

              if (state is PaymentLoaded) {
                payments = state.payments;
                hasReachedMax = state.hasReachedMax;
                totalCount = state.totalCount;
              } else if (state is PaymentLoadingMore) {
                payments = state.currentPayments;
                isLoadingMore = true;
              }

              return PaginatedListView<PaymentModel>(
                items: payments,
                hasReachedMax: hasReachedMax,
                isLoadingMore: isLoadingMore,
                onLoadMore: () =>
                    context.read<PaymentBloc>().add(LoadMorePayments()),
                onRefresh: () async {
                  context.read<PaymentBloc>().add(
                      LoadPayments(filterType: _selectedFilter));
                },
                headerWidget: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '$totalCount transaksi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
                itemBuilder: (context, payment, index) {
                  return _PaymentCard(payment: payment);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? chipColor : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final PaymentModel payment;

  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Payment type icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getTypeColor().withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.payment,
                    color: _getTypeColor(),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.pasienNama,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        payment.description ?? 'Pembayaran medis',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  payment.formattedAmount,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _getTypeColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                StatusBadge.paymentType(payment.paymentType),
                const Spacer(),
                Text(
                  dateFormat.format(payment.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (payment.paymentType) {
      case PaymentType.debit:
        return AppTheme.info;
      case PaymentType.qris:
        return AppTheme.accent;
      case PaymentType.cash:
        return AppTheme.success;
    }
  }
}
