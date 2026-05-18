import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/payment.dart';
import '../services/payment_service.dart';

// ─── Events ──────────────────────────────────────────────────────

abstract class PaymentEvent {}

class LoadPayments extends PaymentEvent {
  final PaymentType? filterType;
  LoadPayments({this.filterType});
}

class LoadMorePayments extends PaymentEvent {}

class SubmitPayment extends PaymentEvent {
  final String pasienId;
  final String pasienNama;
  final double amount;
  final PaymentType paymentType;
  final String? description;
  final String? rekeningDebit;
  final String? qrisCode;

  SubmitPayment({
    required this.pasienId,
    required this.pasienNama,
    required this.amount,
    required this.paymentType,
    this.description,
    this.rekeningDebit,
    this.qrisCode,
  });
}

class FilterPayments extends PaymentEvent {
  final PaymentType? filterType;
  FilterPayments(this.filterType);
}

// ─── States ──────────────────────────────────────────────────────

abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final List<PaymentModel> payments;
  final bool hasReachedMax;
  final int currentPage;
  final int totalCount;
  final PaymentType? filterType;

  PaymentLoaded({
    required this.payments,
    required this.hasReachedMax,
    required this.currentPage,
    required this.totalCount,
    this.filterType,
  });
}

class PaymentLoadingMore extends PaymentState {
  final List<PaymentModel> currentPayments;

  PaymentLoadingMore({required this.currentPayments});
}

class PaymentSubmitting extends PaymentState {}

class PaymentSubmitted extends PaymentState {
  final PaymentModel payment;
  PaymentSubmitted(this.payment);
}

class PaymentError extends PaymentState {
  final String message;
  PaymentError(this.message);
}

// ─── BLoC ────────────────────────────────────────────────────────

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentService _paymentService;
  static const int _pageSize = 20;
  PaymentType? _currentFilter;

  PaymentBloc({PaymentService? paymentService})
      : _paymentService = paymentService ?? PaymentService(),
        super(PaymentInitial()) {
    on<LoadPayments>(_onLoadPayments);
    on<LoadMorePayments>(_onLoadMorePayments);
    on<SubmitPayment>(_onSubmitPayment);
    on<FilterPayments>(_onFilterPayments);
  }

  Future<void> _onLoadPayments(
    LoadPayments event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    _currentFilter = event.filterType;
    try {
      final result = await _paymentService.getPayments(
        page: 1,
        limit: _pageSize,
        filterType: _currentFilter,
      );
      emit(PaymentLoaded(
        payments: result.items,
        hasReachedMax: !result.hasMore,
        currentPage: 1,
        totalCount: result.totalCount,
        filterType: _currentFilter,
      ));
    } catch (e) {
      emit(PaymentError('Gagal memuat pembayaran: $e'));
    }
  }

  Future<void> _onLoadMorePayments(
    LoadMorePayments event,
    Emitter<PaymentState> emit,
  ) async {
    final currentState = state;
    if (currentState is PaymentLoaded && !currentState.hasReachedMax) {
      final nextPage = currentState.currentPage + 1;

      emit(PaymentLoadingMore(currentPayments: currentState.payments));

      try {
        final result = await _paymentService.getPayments(
          page: nextPage,
          limit: _pageSize,
          filterType: _currentFilter,
        );

        emit(PaymentLoaded(
          payments: [...currentState.payments, ...result.items],
          hasReachedMax: !result.hasMore,
          currentPage: nextPage,
          totalCount: result.totalCount,
          filterType: _currentFilter,
        ));
      } catch (e) {
        emit(PaymentLoaded(
          payments: currentState.payments,
          hasReachedMax: currentState.hasReachedMax,
          currentPage: currentState.currentPage,
          totalCount: currentState.totalCount,
          filterType: _currentFilter,
        ));
      }
    }
  }

  Future<void> _onSubmitPayment(
    SubmitPayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentSubmitting());
    try {
      final payment = await _paymentService.submitPayment(
        pasienId: event.pasienId,
        pasienNama: event.pasienNama,
        amount: event.amount,
        paymentType: event.paymentType,
        description: event.description,
        rekeningDebit: event.rekeningDebit,
        qrisCode: event.qrisCode,
      );
      emit(PaymentSubmitted(payment));
    } catch (e) {
      emit(PaymentError('Gagal mengajukan pembayaran: $e'));
    }
  }

  Future<void> _onFilterPayments(
    FilterPayments event,
    Emitter<PaymentState> emit,
  ) async {
    add(LoadPayments(filterType: event.filterType));
  }
}
