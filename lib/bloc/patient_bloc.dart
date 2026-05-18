import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/patient.dart';
import '../services/patient_service.dart';

// ─── Events ──────────────────────────────────────────────────────

abstract class PatientEvent {}

class LoadPatients extends PatientEvent {}

class LoadMorePatients extends PatientEvent {}

class SearchPatients extends PatientEvent {
  final String query;
  SearchPatients(this.query);
}

class CreatePatient extends PatientEvent {
  final Patient patient;
  CreatePatient(this.patient);
}

class ClearSearch extends PatientEvent {}

// ─── States ──────────────────────────────────────────────────────

abstract class PatientState {}

class PatientInitial extends PatientState {}

class PatientLoading extends PatientState {}

class PatientSubmitting extends PatientState {}

class PatientSubmitted extends PatientState {
  final Patient patient;
  PatientSubmitted(this.patient);
}

class PatientLoaded extends PatientState {
  final List<Patient> patients;
  final bool hasReachedMax;
  final int currentPage;
  final int totalCount;
  final String? searchQuery;

  PatientLoaded({
    required this.patients,
    required this.hasReachedMax,
    required this.currentPage,
    required this.totalCount,
    this.searchQuery,
  });

  PatientLoaded copyWith({
    List<Patient>? patients,
    bool? hasReachedMax,
    int? currentPage,
    int? totalCount,
    String? searchQuery,
  }) {
    return PatientLoaded(
      patients: patients ?? this.patients,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class PatientLoadingMore extends PatientState {
  final List<Patient> currentPatients;
  final int currentPage;
  final int totalCount;

  PatientLoadingMore({
    required this.currentPatients,
    required this.currentPage,
    required this.totalCount,
  });
}

class PatientError extends PatientState {
  final String message;
  PatientError(this.message);
}

// ─── BLoC ────────────────────────────────────────────────────────

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final PatientService _patientService;
  static const int _pageSize = 20;

  PatientBloc({PatientService? patientService})
      : _patientService = patientService ?? PatientService(),
        super(PatientInitial()) {
    on<LoadPatients>(_onLoadPatients);
    on<LoadMorePatients>(_onLoadMorePatients);
    on<SearchPatients>(_onSearchPatients);
    on<CreatePatient>(_onCreatePatient);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onCreatePatient(
    CreatePatient event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientSubmitting());
    try {
      final patient = await _patientService.createPatient(event.patient);
      emit(PatientSubmitted(patient));
    } catch (e) {
      emit(PatientError('Gagal menambah pasien: $e'));
    }
  }

  Future<void> _onLoadPatients(
    LoadPatients event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientLoading());
    try {
      final result = await _patientService.getPatients(
        page: 1,
        limit: _pageSize,
      );
      emit(PatientLoaded(
        patients: result.items,
        hasReachedMax: !result.hasMore,
        currentPage: 1,
        totalCount: result.totalCount,
      ));
    } catch (e) {
      emit(PatientError('Gagal memuat data pasien: $e'));
    }
  }

  Future<void> _onLoadMorePatients(
    LoadMorePatients event,
    Emitter<PatientState> emit,
  ) async {
    final currentState = state;
    if (currentState is PatientLoaded && !currentState.hasReachedMax) {
      final nextPage = currentState.currentPage + 1;

      emit(PatientLoadingMore(
        currentPatients: currentState.patients,
        currentPage: currentState.currentPage,
        totalCount: currentState.totalCount,
      ));

      try {
        final result = await _patientService.getPatients(
          page: nextPage,
          limit: _pageSize,
          searchQuery: currentState.searchQuery,
        );

        emit(PatientLoaded(
          patients: [...currentState.patients, ...result.items],
          hasReachedMax: !result.hasMore,
          currentPage: nextPage,
          totalCount: result.totalCount,
          searchQuery: currentState.searchQuery,
        ));
      } catch (e) {
        emit(PatientLoaded(
          patients: currentState.patients,
          hasReachedMax: currentState.hasReachedMax,
          currentPage: currentState.currentPage,
          totalCount: currentState.totalCount,
          searchQuery: currentState.searchQuery,
        ));
      }
    }
  }

  Future<void> _onSearchPatients(
    SearchPatients event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientLoading());
    try {
      final result = await _patientService.getPatients(
        page: 1,
        limit: _pageSize,
        searchQuery: event.query,
      );
      emit(PatientLoaded(
        patients: result.items,
        hasReachedMax: !result.hasMore,
        currentPage: 1,
        totalCount: result.totalCount,
        searchQuery: event.query,
      ));
    } catch (e) {
      emit(PatientError('Gagal mencari pasien: $e'));
    }
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<PatientState> emit,
  ) async {
    add(LoadPatients());
  }
}
