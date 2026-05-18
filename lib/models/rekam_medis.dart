class RekamMedis {
  final String id;
  final String pasienId;
  final String dokterId;
  final String keluhan;
  final String diagnosis;
  final String tindakan;
  final String? resep;
  final String? catatan;
  final bool aiAssisted;
  final bool approved;
  final DateTime tanggalKunjungan;
  final DateTime createdAt;
  final DateTime updatedAt;

  RekamMedis({
    required this.id,
    required this.pasienId,
    required this.dokterId,
    required this.keluhan,
    required this.diagnosis,
    required this.tindakan,
    this.resep,
    this.catatan,
    required this.aiAssisted,
    required this.approved,
    required this.tanggalKunjungan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RekamMedis.fromJson(Map<String, dynamic> json) {
    return RekamMedis(
      id: json['id'].toString(),
      pasienId: json['pasien_id'].toString(),
      dokterId: json['dokter_id'].toString(),
      keluhan: json['keluhan'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      tindakan: json['tindakan'] ?? '',
      resep: json['resep'],
      catatan: json['catatan'],
      aiAssisted: json['ai_assisted'] ?? false,
      approved: json['approved'] ?? false,
      tanggalKunjungan: DateTime.parse(
        json['tanggal_kunjungan'] ?? DateTime.now().toIso8601String(),
      ),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pasien_id': pasienId,
      'dokter_id': dokterId,
      'keluhan': keluhan,
      'diagnosis': diagnosis,
      'tindakan': tindakan,
      'resep': resep,
      'catatan': catatan,
      'ai_assisted': aiAssisted,
      'approved': approved,
      'tanggal_kunjungan': tanggalKunjungan.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  RekamMedis copyWith({
    String? id,
    String? pasienId,
    String? dokterId,
    String? keluhan,
    String? diagnosis,
    String? tindakan,
    String? resep,
    String? catatan,
    bool? aiAssisted,
    bool? approved,
    DateTime? tanggalKunjungan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RekamMedis(
      id: id ?? this.id,
      pasienId: pasienId ?? this.pasienId,
      dokterId: dokterId ?? this.dokterId,
      keluhan: keluhan ?? this.keluhan,
      diagnosis: diagnosis ?? this.diagnosis,
      tindakan: tindakan ?? this.tindakan,
      resep: resep ?? this.resep,
      catatan: catatan ?? this.catatan,
      aiAssisted: aiAssisted ?? this.aiAssisted,
      approved: approved ?? this.approved,
      tanggalKunjungan: tanggalKunjungan ?? this.tanggalKunjungan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
