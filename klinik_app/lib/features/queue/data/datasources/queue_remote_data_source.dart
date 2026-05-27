import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/queue_dto.dart';

abstract class QueueRemoteDataSource {
  Future<void> createQueue(QueueDTO queue);
  Future<void> updateQueueStatus(String id, String status);
  Stream<List<QueueDTO>> getRealtimeQueueByPoli(String poliName);
  Stream<List<QueueDTO>> getPatientQueue(String patientId);
}

class QueueRemoteDataSourceImpl implements QueueRemoteDataSource {
  final FirebaseFirestore _firestore;

  QueueRemoteDataSourceImpl(this._firestore);

  @override
  Future<void> createQueue(QueueDTO queue) async {
    await _firestore.collection('queues').doc(queue.id).set(queue.toJson());
  }

  @override
  Future<void> updateQueueStatus(String id, String status) async {
    await _firestore.collection('queues').doc(id).update({'status': status});
  }

  @override
  Stream<List<QueueDTO>> getRealtimeQueueByPoli(String poliName) {
    return _firestore
        .collection('queues')
        .where('poliName', isEqualTo: poliName)
        .where('status', whereIn: ['waiting', 'in_progress'])
        .orderBy('queueNumber')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QueueDTO.fromJson(doc.data(), doc.id))
            .toList());
  }

  @override
  Stream<List<QueueDTO>> getPatientQueue(String patientId) {
    return _firestore
        .collection('queues')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QueueDTO.fromJson(doc.data(), doc.id))
            .toList());
  }
}
