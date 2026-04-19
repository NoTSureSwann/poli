import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/medical_record_bloc.dart';
import '../../models/medical_record.dart';
import '../../theme/app_theme.dart';
import '../../widgets/paginated_list.dart';
import '../../widgets/status_badge.dart';

class MedicalRecordListScreen extends StatefulWidget {
  const MedicalRecordListScreen({super.key});

  @override
  State<MedicalRecordListScreen> createState() =>
      _MedicalRecordListScreenState();
}

class _MedicalRecordListScreenState extends State<MedicalRecordListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MedicalRecordBloc>().add(LoadRecords());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicalRecordBloc, MedicalRecordState>(
      builder: (context, state) {
        if (state is RecordLoading) {
          return PaginatedListView<MedicalRecordModel>(
            items: const [],
            itemBuilder: (context, record, index) => const SizedBox(),
            isInitialLoading: true,
          );
        }

        if (state is RecordError) {
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
                      context.read<MedicalRecordBloc>().add(LoadRecords()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        List<MedicalRecordModel> records = [];
        bool hasReachedMax = false;
        bool isLoadingMore = false;
        int totalCount = 0;

        if (state is RecordLoaded) {
          records = state.records;
          hasReachedMax = state.hasReachedMax;
          totalCount = state.totalCount;
        } else if (state is RecordLoadingMore) {
          records = state.currentRecords;
          isLoadingMore = true;
        }

        return PaginatedListView<MedicalRecordModel>(
          items: records,
          hasReachedMax: hasReachedMax,
          isLoadingMore: isLoadingMore,
          onLoadMore: () =>
              context.read<MedicalRecordBloc>().add(LoadMoreRecords()),
          onRefresh: () async {
            context.read<MedicalRecordBloc>().add(LoadRecords());
          },
          headerWidget: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$totalCount rekam medis',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.security,
                          size: 14, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Data Terenkripsi',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          emptyWidget: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medical_information,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Belum ada rekam medis',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          itemBuilder: (context, record, index) {
            return _RecordCard(record: record);
          },
        );
      },
    );
  }
}

class _RecordCard extends StatelessWidget {
  final MedicalRecordModel record;

  const _RecordCard({required this.record});

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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    color: AppTheme.accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.diagnosis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.doctorName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge.validity(isValid: record.isValid),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tindakan:',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    record.treatment,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Pasien: ${record.pasienId}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                const Spacer(),
                const StatusBadge(
                  label: 'Digital Record',
                  backgroundColor: AppTheme.info,
                  icon: Icons.history_edu,
                ),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(record.timestamp),
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
}
