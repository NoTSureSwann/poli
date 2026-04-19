import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/patient_bloc.dart';
import '../../models/patient.dart';
import '../../theme/app_theme.dart';
import '../../widgets/paginated_list.dart';
import '../../widgets/status_badge.dart';
import 'patient_detail_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    context.read<PatientBloc>().add(LoadPatients());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (query.isEmpty) {
        context.read<PatientBloc>().add(ClearSearch());
      } else {
        context.read<PatientBloc>().add(SearchPatients(query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari pasien (nama, NIK, No BPJS)...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<PatientBloc>().add(ClearSearch());
                      },
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),

        // Patient list
        Expanded(
          child: BlocBuilder<PatientBloc, PatientState>(
            builder: (context, state) {
              if (state is PatientLoading) {
                return PaginatedListView<Patient>(
                  items: const [],
                  itemBuilder: (context, patient, index) => const SizedBox(),
                  isInitialLoading: true,
                );
              }

              if (state is PatientError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: AppTheme.error),
                      const SizedBox(height: 16),
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.read<PatientBloc>().add(LoadPatients()),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }

              List<Patient> patients = [];
              bool hasReachedMax = false;
              bool isLoadingMore = false;
              int totalCount = 0;

              if (state is PatientLoaded) {
                patients = state.patients;
                hasReachedMax = state.hasReachedMax;
                totalCount = state.totalCount;
              } else if (state is PatientLoadingMore) {
                patients = state.currentPatients;
                isLoadingMore = true;
                totalCount = state.totalCount;
              }

              return PaginatedListView<Patient>(
                items: patients,
                hasReachedMax: hasReachedMax,
                isLoadingMore: isLoadingMore,
                onLoadMore: () =>
                    context.read<PatientBloc>().add(LoadMorePatients()),
                onRefresh: () async {
                  context.read<PatientBloc>().add(LoadPatients());
                },
                headerWidget: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '$totalCount pasien ditemukan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                emptyWidget: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_search,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada pasien ditemukan',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                itemBuilder: (context, patient, index) {
                  return _PatientCard(
                    patient: patient,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PatientDetailScreen(patient: patient),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;

  const _PatientCard({
    required this.patient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primary.withAlpha(30),
                child: Text(
                  patient.nama.isNotEmpty
                      ? patient.nama[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${patient.jenisKelamin} • ${patient.age}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              // BPJS badge
              if (patient.hasBPJS)
                const StatusBadge(
                  label: 'BPJS',
                  backgroundColor: AppTheme.success,
                  icon: Icons.verified,
                ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
