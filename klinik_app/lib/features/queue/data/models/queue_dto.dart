class QueueDTO {
  final String id;
  final String patientName;
  final String patientId;
  final String poliName;
  final int queueNumber;
  final String status; // 'waiting', 'in_progress', 'completed', 'cancelled'
  final DateTime createdAt;

  QueueDTO({
    required this.id,
    required this.patientName,
    required this.patientId,
    required this.poliName,
    required this.queueNumber,
    required this.status,
    required this.createdAt,
  });

  factory QueueDTO.fromJson(Map<String, dynamic> json, String documentId) {
    return QueueDTO(
      id: documentId,
      patientName: json['patientName'] ?? '',
      patientId: json['patientId'] ?? '',
      poliName: json['poliName'] ?? '',
      queueNumber: json['queueNumber'] ?? 0,
      status: json['status'] ?? 'waiting',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientName': patientName,
      'patientId': patientId,
      'poliName': poliName,
      'queueNumber': queueNumber,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
