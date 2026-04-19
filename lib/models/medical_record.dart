class MedicalRecordModel {
  final String id;
  final String pasienId;
  final String pasienNama;
  final String doctorName;
  final String diagnosis;
  final String treatment;
  final DateTime timestamp;
  final bool isValid;

  MedicalRecordModel({
    required this.id,
    required this.pasienId,
    required this.pasienNama,
    required this.doctorName,
    required this.diagnosis,
    required this.treatment,
    required this.timestamp,
    this.isValid = true,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      id: json['id'] as String,
      pasienId: json['pasien_id'] as String,
      pasienNama: json['pasien_nama'] as String? ?? '',
      doctorName: json['doctor_name'] as String? ?? '',
      diagnosis: json['diagnosis'] as String,
      treatment: json['treatment'] as String,
      timestamp: json['timestamp'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int)
          : DateTime.parse(json['timestamp'] as String),
      isValid: json['is_valid'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pasien_id': pasienId,
      'pasien_nama': pasienNama,
      'doctor_name': doctorName,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'timestamp': timestamp.toIso8601String(),
      'is_valid': isValid,
    };
  }

  String get contentSummary => '$diagnosis | $treatment';
}
