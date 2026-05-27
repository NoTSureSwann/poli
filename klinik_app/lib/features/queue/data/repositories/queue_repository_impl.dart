import '../models/queue_dto.dart';
import '../datasources/queue_remote_data_source.dart';
import '../../domain/repositories/queue_repository.dart';

class QueueRepositoryImpl implements QueueRepository {
  final QueueRemoteDataSource remoteDataSource;

  QueueRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> registerQueue(QueueDTO queue) async {
    return await remoteDataSource.createQueue(queue);
  }

  @override
  Future<void> processQueue(String queueId) async {
    return await remoteDataSource.updateQueueStatus(queueId, 'in_progress');
  }

  @override
  Future<void> completeQueue(String queueId) async {
    return await remoteDataSource.updateQueueStatus(queueId, 'completed');
  }

  @override
  Stream<List<QueueDTO>> watchQueueByPoli(String poliName) {
    return remoteDataSource.getRealtimeQueueByPoli(poliName);
  }

  @override
  Stream<List<QueueDTO>> watchPatientQueue(String patientId) {
    return remoteDataSource.getPatientQueue(patientId);
  }
}
