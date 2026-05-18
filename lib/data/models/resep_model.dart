class ResepModel {
  final int? id;
  final int rekamMedisId;
  final int pasienId;
  final String? catatanDokter;
  final List<Map<String, dynamic>>? items;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  ResepModel({
    this.id,
    required this.rekamMedisId,
    required this.pasienId,
    this.catatanDokter,
    this.items,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ResepModel.fromJson(Map<String, dynamic> json) {
    final itemsData = json['items'];
    final parsedItems = <Map<String, dynamic>>[];

    if (itemsData is List) {
      for (final item in itemsData) {
        if (item is Map<String, dynamic>) {
          parsedItems.add(item);
        }
      }
    }

    return ResepModel(
      id: json['id'] as int?,
      rekamMedisId: json['rekam_medis_id'] as int? ?? 0,
      pasienId: json['pasien_id'] as int? ?? 0,
      catatanDokter: json['catatan_dokter']?.toString(),
      items: parsedItems.isEmpty ? null : parsedItems,
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rekam_medis_id': rekamMedisId,
      'pasien_id': pasienId,
      'catatan_dokter': catatanDokter,
      'items': items,
      'status': status,
    };
  }

  ResepModel copyWith({
    int? id,
    int? rekamMedisId,
    int? pasienId,
    String? catatanDokter,
    List<Map<String, dynamic>>? items,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return ResepModel(
      id: id ?? this.id,
      rekamMedisId: rekamMedisId ?? this.rekamMedisId,
      pasienId: pasienId ?? this.pasienId,
      catatanDokter: catatanDokter ?? this.catatanDokter,
      items: items ?? this.items,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
