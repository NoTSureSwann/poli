class PembayaranModel {
  final int? id;
  final int pasienId;
  final int? rekamMedisId;
  final int? resepId;
  final String jenisPembayaran;
  final double totalBiaya;
  final double? totalDibayar;
  final String? bpjsClaimId;
  final String? status;
  final String? keterangan;
  final String? createdAt;
  final String? updatedAt;

  PembayaranModel({
    this.id,
    required this.pasienId,
    this.rekamMedisId,
    this.resepId,
    required this.jenisPembayaran,
    required this.totalBiaya,
    this.totalDibayar,
    this.bpjsClaimId,
    this.status,
    this.keterangan,
    this.createdAt,
    this.updatedAt,
  });

  factory PembayaranModel.fromJson(Map<String, dynamic> json) {
    return PembayaranModel(
      id: json['id'] as int?,
      pasienId: json['pasien_id'] as int? ?? 0,
      rekamMedisId: json['rekam_medis_id'] as int?,
      resepId: json['resep_id'] as int?,
      jenisPembayaran: json['jenis_pembayaran']?.toString() ?? '',
      totalBiaya: (json['total_biaya'] as num?)?.toDouble() ?? 0.0,
      totalDibayar: (json['total_dibayar'] as num?)?.toDouble(),
      bpjsClaimId: json['bpjs_claim_id']?.toString(),
      status: json['status']?.toString(),
      keterangan: json['keterangan']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pasien_id': pasienId,
      'rekam_medis_id': rekamMedisId,
      'resep_id': resepId,
      'jenis_pembayaran': jenisPembayaran,
      'total_biaya': totalBiaya,
      'total_dibayar': totalDibayar,
      'bpjs_claim_id': bpjsClaimId,
      'status': status,
      'keterangan': keterangan,
    };
  }

  PembayaranModel copyWith({
    int? id,
    int? pasienId,
    int? rekamMedisId,
    int? resepId,
    String? jenisPembayaran,
    double? totalBiaya,
    double? totalDibayar,
    String? bpjsClaimId,
    String? status,
    String? keterangan,
    String? createdAt,
    String? updatedAt,
  }) {
    return PembayaranModel(
      id: id ?? this.id,
      pasienId: pasienId ?? this.pasienId,
      rekamMedisId: rekamMedisId ?? this.rekamMedisId,
      resepId: resepId ?? this.resepId,
      jenisPembayaran: jenisPembayaran ?? this.jenisPembayaran,
      totalBiaya: totalBiaya ?? this.totalBiaya,
      totalDibayar: totalDibayar ?? this.totalDibayar,
      bpjsClaimId: bpjsClaimId ?? this.bpjsClaimId,
      status: status ?? this.status,
      keterangan: keterangan ?? this.keterangan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
