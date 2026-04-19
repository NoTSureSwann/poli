import 'dart:math';
import '../models/payment.dart';
import '../services/patient_service.dart';

/// Payment service for handling medical transactions.
class PaymentService {
  static final List<PaymentModel> _mockPayments = _generateMockPayments();

  PaymentService();

  /// Get paginated payments
  Future<PaginatedResult<PaymentModel>> getPayments({
    int page = 1,
    int limit = 20,
    PaymentType? filterType,
    String? pasienId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var filtered = _mockPayments;

    if (filterType != null) {
      filtered = filtered.where((p) => p.paymentType == filterType).toList();
    }
    if (pasienId != null) {
      filtered = filtered.where((p) => p.pasienId == pasienId).toList();
    }

    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit > filtered.length
        ? filtered.length
        : startIndex + limit;

    if (startIndex >= filtered.length) {
      return PaginatedResult(
        items: [],
        totalCount: filtered.length,
        currentPage: page,
        pageSize: limit,
        hasMore: false,
      );
    }

    return PaginatedResult(
      items: filtered.sublist(startIndex, endIndex),
      totalCount: filtered.length,
      currentPage: page,
      pageSize: limit,
      hasMore: endIndex < filtered.length,
    );
  }

  /// Submit a new payment
  Future<PaymentModel> submitPayment({
    required String pasienId,
    required String pasienNama,
    required double amount,
    required PaymentType paymentType,
    String? description,
  }) async {
    final payment = PaymentModel(
      id: 'PAY${DateTime.now().millisecondsSinceEpoch}',
      pasienId: pasienId,
      pasienNama: pasienNama,
      amount: amount,
      paymentType: paymentType,
      processedBy: 'Admin Klinik',
      timestamp: DateTime.now(),
      description: description,
    );

    _mockPayments.insert(0, payment);
    return payment;
  }

  /// Get total payments summary
  Future<Map<String, dynamic>> getPaymentSummary() async {
    await Future.delayed(const Duration(milliseconds: 300));

    double totalDebit = 0;
    double totalQRIS = 0;
    double totalCash = 0;

    for (final p in _mockPayments) {
      switch (p.paymentType) {
        case PaymentType.debit:
          totalDebit += p.amount;
          break;
        case PaymentType.qris:
          totalQRIS += p.amount;
          break;
        case PaymentType.cash:
          totalCash += p.amount;
          break;
      }
    }

    return {
      'total_transaksi': _mockPayments.length,
      'total_debit': totalDebit,
      'total_qris': totalQRIS,
      'total_cash': totalCash,
      'total_keseluruhan': totalDebit + totalQRIS + totalCash,
    };
  }

  // ─── Mock Data ─────────────────────────────────────────────────

  static List<PaymentModel> _generateMockPayments() {
    final random = Random(99);
    final names = [
      'Ahmad Pratama', 'Siti Wijaya', 'Budi Susanto', 'Dewi Hidayat',
      'Andi Saputra', 'Rina Kusuma', 'Joko Permana', 'Nurhaliza Purnomo',
      'Agus Santoso', 'Lestari Wibowo', 'Bambang Utami', 'Wulandari Rahardjo',
    ];
    final descriptions = [
      'Pemeriksaan umum',
      'Konsultasi dokter spesialis',
      'Laboratorium darah lengkap',
      'Rontgen thorax',
      'USG abdomen',
      'Rawat jalan poli umum',
      'Fisioterapi',
      'Pemeriksaan gigi',
      'Vaksinasi',
      'Rawat inap kelas III',
    ];

    return List.generate(120, (i) {
      final type = PaymentType.values[random.nextInt(PaymentType.values.length)];
      final amounts = [25000, 50000, 75000, 100000, 150000, 200000, 350000, 500000];

      return PaymentModel(
        id: 'PAY${(i + 1).toString().padLeft(4, '0')}',
        pasienId: 'P${(random.nextInt(50) + 1).toString().padLeft(4, '0')}',
        pasienNama: names[random.nextInt(names.length)],
        amount: amounts[random.nextInt(amounts.length)].toDouble(),
        paymentType: type,
        processedBy: 'Admin Klinik',
        timestamp: DateTime.now().subtract(Duration(
          days: random.nextInt(90),
          hours: random.nextInt(24),
        )),
        description: descriptions[random.nextInt(descriptions.length)],
      );
    })..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
