import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../theme/app_theme.dart';

/// Color-coded status badge for payment types and general statuses
class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    this.textColor = const Color.fromARGB(255, 255, 255, 255),
    this.icon,
  });

  /// Factory for payment type badges
  factory StatusBadge.paymentType(PaymentType type) {
    switch (type) {
      case PaymentType.debit:
        return const StatusBadge(
          label: 'DEBIT',
          backgroundColor: AppTheme.info,
          icon: Icons.credit_card,
        );
      case PaymentType.qris:
        return const StatusBadge(
          label: 'QRIS',
          backgroundColor: AppTheme.accent,
          icon: Icons.qr_code_scanner,
        );
      case PaymentType.cash:
        return const StatusBadge(
          label: 'TUNAI',
          backgroundColor: AppTheme.success,
          icon: Icons.payments,
        );
    }
  }

  /// Factory for record validity badge
  factory StatusBadge.validity({required bool isValid}) {
    return StatusBadge(
      label: isValid ? 'Valid' : 'Invalid',
      backgroundColor: isValid ? AppTheme.success : AppTheme.error,
      icon: isValid ? Icons.check_circle : Icons.cancel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: backgroundColor.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: backgroundColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: backgroundColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
