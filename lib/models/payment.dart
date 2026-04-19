enum PaymentType { debit, qris, cash }

extension PaymentTypeExtension on PaymentType {
  String get label {
    switch (this) {
      case PaymentType.debit:
        return 'DEBIT';
      case PaymentType.qris:
        return 'QRIS';
      case PaymentType.cash:
        return 'TUNAI';
    }
  }

  static PaymentType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'DEBIT':
        return PaymentType.debit;
      case 'QRIS':
        return PaymentType.qris;
      case 'TUNAI':
      case 'CASH':
        return PaymentType.cash;
      default:
        return PaymentType.cash;
    }
  }
}

class PaymentModel {
  final String id;
  final String pasienId;
  final String pasienNama;
  final double amount;
  final PaymentType paymentType;
  final String processedBy;
  final DateTime timestamp;
  final String? description;

  PaymentModel({
    required this.id,
    required this.pasienId,
    required this.pasienNama,
    required this.amount,
    required this.paymentType,
    required this.processedBy,
    required this.timestamp,
    this.description,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      pasienId: json['pasien_id'] as String,
      pasienNama: json['pasien_nama'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      paymentType: PaymentTypeExtension.fromString(json['payment_type'] as String),
      processedBy: json['processed_by'] as String,
      timestamp: json['timestamp'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int)
          : DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pasien_id': pasienId,
      'pasien_nama': pasienNama,
      'amount': amount,
      'payment_type': paymentType.label,
      'processed_by': processedBy,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
    };
  }

  String get formattedAmount {
    final parts = amount.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(parts[i]);
    }
    return 'Rp $buffer';
  }
}
