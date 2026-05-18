enum StatusAntrian { menunggu, dipanggil, selesai, batal }

class Antrian {
  final String id;
  final String pasienId;
  final String namaPasien;
  final int nomorAntrian;
  final StatusAntrian status;
  final DateTime tanggal;
  final DateTime? waktuPanggilan;
  final DateTime createdAt;
  final DateTime updatedAt;

  Antrian({
    required this.id,
    required this.pasienId,
    required this.namaPasien,
    required this.nomorAntrian,
    required this.status,
    required this.tanggal,
    this.waktuPanggilan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Antrian.fromJson(Map<String, dynamic> json) {
    return Antrian(
      id: json['id'].toString(),
      pasienId: json['pasien_id'].toString(),
      namaPasien: json['nama_pasien'] ?? '',
      nomorAntrian: json['nomor_antrian'] ?? 0,
      status: _parseStatus(json['status']),
      tanggal: DateTime.parse(
        json['tanggal'] ?? DateTime.now().toIso8601String(),
      ),
      waktuPanggilan: json['waktu_panggilan'] != null
          ? DateTime.parse(json['waktu_panggilan'])
          : null,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  static StatusAntrian _parseStatus(String? status) {
    switch (status) {
      case 'dipanggil':
        return StatusAntrian.dipanggil;
      case 'selesai':
        return StatusAntrian.selesai;
      case 'batal':
        return StatusAntrian.batal;
      case 'menunggu':
      default:
        return StatusAntrian.menunggu;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pasien_id': pasienId,
      'nama_pasien': namaPasien,
      'nomor_antrian': nomorAntrian,
      'status': status.name,
      'tanggal': tanggal.toIso8601String(),
      'waktu_panggilan': waktuPanggilan?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Antrian copyWith({
    String? id,
    String? pasienId,
    String? namaPasien,
    int? nomorAntrian,
    StatusAntrian? status,
    DateTime? tanggal,
    DateTime? waktuPanggilan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Antrian(
      id: id ?? this.id,
      pasienId: pasienId ?? this.pasienId,
      namaPasien: namaPasien ?? this.namaPasien,
      nomorAntrian: nomorAntrian ?? this.nomorAntrian,
      status: status ?? this.status,
      tanggal: tanggal ?? this.tanggal,
      waktuPanggilan: waktuPanggilan ?? this.waktuPanggilan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
