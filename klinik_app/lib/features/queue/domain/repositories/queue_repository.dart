import '../../data/models/queue_dto.dart';

abstract class QueueRepository {
  Future<void> registerQueue(QueueDTO queue);
  Future<void> processQueue(String queueId);
  Future<void> completeQueue(String queueId);
  Stream<List<QueueDTO>> watchQueueByPoli(String poliName);
  Stream<List<QueueDTO>> watchPatientQueue(String patientId);
}
