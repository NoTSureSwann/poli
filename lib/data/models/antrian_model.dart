class AntrianModel {
  final int? id;
  final int pasienId;
  final String poli;
  final String? catatan;
  final String? status;
  final String? tanggal;
  final int? estimasiTunggu;
  final String? createdAt;

  AntrianModel({
    this.id,
    required this.pasienId,
    required this.poli,
    this.catatan,
    this.status,
    this.tanggal,
    this.estimasiTunggu,
    this.createdAt,
  });

  factory AntrianModel.fromJson(Map<String, dynamic> json) {
    return AntrianModel(
      id: json['id'] as int?,
      pasienId: json['pasien_id'] as int? ?? 0,
      poli: json['poli']?.toString() ?? '',
      catatan: json['catatan']?.toString(),
      status: json['status']?.toString(),
      tanggal: json['tanggal']?.toString(),
      estimasiTunggu: json['estimasi_tunggu'] as int?,
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pasien_id': pasienId,
      'poli': poli,
      'catatan': catatan,
      'status': status,
      'tanggal': tanggal,
      'estimasi_tunggu': estimasiTunggu,
    };
  }

  AntrianModel copyWith({
    int? id,
    int? pasienId,
    String? poli,
    String? catatan,
    String? status,
    String? tanggal,
    int? estimasiTunggu,
    String? createdAt,
  }) {
    return AntrianModel(
      id: id ?? this.id,
      pasienId: pasienId ?? this.pasienId,
      poli: poli ?? this.poli,
      catatan: catatan ?? this.catatan,
      status: status ?? this.status,
      tanggal: tanggal ?? this.tanggal,
      estimasiTunggu: estimasiTunggu ?? this.estimasiTunggu,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
