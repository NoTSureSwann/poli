import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/medical_record.dart';

// ─── Events ──────────────────────────────────────────────────────

abstract class MedicalRecordEvent {}

class LoadRecords extends MedicalRecordEvent {
  final String? pasienId;
  LoadRecords({this.pasienId});
}

class LoadMoreRecords extends MedicalRecordEvent {}

// ─── States ──────────────────────────────────────────────────────

abstract class MedicalRecordState {}

class RecordInitial extends MedicalRecordState {}

class RecordLoading extends MedicalRecordState {}

class RecordLoaded extends MedicalRecordState {
  final List<MedicalRecordModel> records;
  final bool hasReachedMax;
  final int currentPage;
  final int totalCount;
  final String? pasienId;

  RecordLoaded({
    required this.records,
    required this.hasReachedMax,
    required this.currentPage,
    required this.totalCount,
    this.pasienId,
  });
}

class RecordLoadingMore extends MedicalRecordState {
  final List<MedicalRecordModel> currentRecords;
  RecordLoadingMore({required this.currentRecords});
}

class RecordError extends MedicalRecordState {
  final String message;
  RecordError(this.message);
}

// ─── BLoC ────────────────────────────────────────────────────────

class MedicalRecordBloc extends Bloc<MedicalRecordEvent, MedicalRecordState> {
  static const int _pageSize = 20;
  String? _currentPasienId;

  // Mock data
  static final List<MedicalRecordModel> _allRecords = _generateMockRecords();

  MedicalRecordBloc() : super(RecordInitial()) {
    on<LoadRecords>(_onLoadRecords);
    on<LoadMoreRecords>(_onLoadMoreRecords);
  }

  Future<void> _onLoadRecords(
    LoadRecords event,
    Emitter<MedicalRecordState> emit,
  ) async {
    emit(RecordLoading());
    _currentPasienId = event.pasienId;

    await Future.delayed(const Duration(milliseconds: 600));

    try {
      var filtered = _allRecords;
      if (event.pasienId != null) {
        filtered = _allRecords.where((r) => r.pasienId == event.pasienId).toList();
      }

      final endIndex = _pageSize > filtered.length ? filtered.length : _pageSize;

      emit(RecordLoaded(
        records: filtered.sublist(0, endIndex),
        hasReachedMax: endIndex >= filtered.length,
        currentPage: 1,
        totalCount: filtered.length,
        pasienId: event.pasienId,
      ));
    } catch (e) {
      emit(RecordError('Gagal memuat rekam medis: $e'));
    }
  }

  Future<void> _onLoadMoreRecords(
    LoadMoreRecords event,
    Emitter<MedicalRecordState> emit,
  ) async {
    final currentState = state;
    if (currentState is RecordLoaded && !currentState.hasReachedMax) {
      emit(RecordLoadingMore(currentRecords: currentState.records));

      await Future.delayed(const Duration(milliseconds: 400));

      try {
        var filtered = _allRecords;
        if (_currentPasienId != null) {
          filtered = _allRecords.where((r) => r.pasienId == _currentPasienId).toList();
        }

        final nextPage = currentState.currentPage + 1;
        final startIndex = (nextPage - 1) * _pageSize;
        final endIndex = startIndex + _pageSize > filtered.length
            ? filtered.length
            : startIndex + _pageSize;

        if (startIndex >= filtered.length) {
          emit(RecordLoaded(
            records: currentState.records,
            hasReachedMax: true,
            currentPage: currentState.currentPage,
            totalCount: filtered.length,
            pasienId: _currentPasienId,
          ));
          return;
        }

        emit(RecordLoaded(
          records: [...currentState.records, ...filtered.sublist(startIndex, endIndex)],
          hasReachedMax: endIndex >= filtered.length,
          currentPage: nextPage,
          totalCount: filtered.length,
          pasienId: _currentPasienId,
        ));
      } catch (e) {
        emit(RecordLoaded(
          records: currentState.records,
          hasReachedMax: currentState.hasReachedMax,
          currentPage: currentState.currentPage,
          totalCount: currentState.totalCount,
          pasienId: _currentPasienId,
        ));
      }
    }
  }

  static List<MedicalRecordModel> _generateMockRecords() {
    final random = Random(77);
    final diagnoses = [
      'Demam berdarah dengue', 'ISPA', 'Hipertensi grade I',
      'Diabetes mellitus tipe 2', 'Gastritis akut', 'Migrain',
      'Dermatitis kontak', 'Asma bronkial', 'Otitis media',
      'Vertigo perifer', 'Anemia defisiensi besi', 'Arthritis gout',
    ];
    final treatments = [
      'Pemberian cairan infus + paracetamol', 'Antibiotik amoxicillin 3x500mg',
      'Amlodipine 1x5mg + diet rendah garam', 'Metformin 2x500mg + edukasi diet',
      'Omeprazole 2x20mg + antasida', 'Sumatriptan 50mg PRN',
      'Krim kortikosteroid topikal', 'Salbutamol inhaler PRN',
      'Amoxicillin tetes telinga', 'Betahistine 3x6mg',
      'Tablet besi 1x1 + vitamin C', 'Colchicine 2x0.5mg + allopurinol',
    ];
    final doctorNames = [
      'dr. Andi Wijaya, Sp.PD', 'dr. Siti Rahayu, Sp.A',
      'dr. Budi Santoso, Sp.JP', 'dr. Maya Kusuma, Sp.OG',
      'dr. Heri Purnomo', 'dr. Rina Sari',
    ];

    return List.generate(100, (i) {
      final diagIdx = random.nextInt(diagnoses.length);
      return MedicalRecordModel(
        id: 'REC${(i + 1).toString().padLeft(4, '0')}',
        pasienId: 'P${(random.nextInt(50) + 1).toString().padLeft(4, '0')}',
        pasienNama: 'Pasien ${random.nextInt(50) + 1}',
        doctorName: doctorNames[random.nextInt(doctorNames.length)],
        diagnosis: diagnoses[diagIdx],
        treatment: treatments[diagIdx],
        timestamp: DateTime.now().subtract(Duration(
          days: random.nextInt(180),
          hours: random.nextInt(24),
        )),
        isValid: random.nextDouble() > 0.05,
      );
    })..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
