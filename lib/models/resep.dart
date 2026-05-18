enum StatusResep { menunggu, disiapkan, diserahkan, selesai }

class Resep {
  final String id;
  final String rekamMedisId;
  final String pasienId;
  final String namaPasien;
  final String obat;
  final String dosis;
  final String instruksi;
  final int jumlah;
  final StatusResep status;
  final DateTime tanggalResep;
  final DateTime? waktuSiap;
  final DateTime? waktuSerah;
  final DateTime createdAt;
  final DateTime updatedAt;

  Resep({
    required this.id,
    required this.rekamMedisId,
    required this.pasienId,
    required this.namaPasien,
    required this.obat,
    required this.dosis,
    required this.instruksi,
    required this.jumlah,
    required this.status,
    required this.tanggalResep,
    this.waktuSiap,
    this.waktuSerah,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Resep.fromJson(Map<String, dynamic> json) {
    return Resep(
      id: json['id'].toString(),
      rekamMedisId: json['rekam_medis_id'].toString(),
      pasienId: json['pasien_id'].toString(),
      namaPasien: json['nama_pasien'] ?? '',
      obat: json['obat'] ?? '',
      dosis: json['dosis'] ?? '',
      instruksi: json['instruksi'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      status: _parseStatus(json['status']),
      tanggalResep: DateTime.parse(
        json['tanggal_resep'] ?? DateTime.now().toIso8601String(),
      ),
      waktuSiap: json['waktu_siap'] != null
          ? DateTime.parse(json['waktu_siap'])
          : null,
      waktuSerah: json['waktu_serah'] != null
          ? DateTime.parse(json['waktu_serah'])
          : null,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  static StatusResep _parseStatus(String? status) {
    switch (status) {
      case 'disiapkan':
        return StatusResep.disiapkan;
      case 'diserahkan':
        return StatusResep.diserahkan;
      case 'selesai':
        return StatusResep.selesai;
      case 'menunggu':
      default:
        return StatusResep.menunggu;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rekam_medis_id': rekamMedisId,
      'pasien_id': pasienId,
      'nama_pasien': namaPasien,
      'obat': obat,
      'dosis': dosis,
      'instruksi': instruksi,
      'jumlah': jumlah,
      'status': status.name,
      'tanggal_resep': tanggalResep.toIso8601String(),
      'waktu_siap': waktuSiap?.toIso8601String(),
      'waktu_serah': waktuSerah?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Resep copyWith({
    String? id,
    String? rekamMedisId,
    String? pasienId,
    String? namaPasien,
    String? obat,
    String? dosis,
    String? instruksi,
    int? jumlah,
    StatusResep? status,
    DateTime? tanggalResep,
    DateTime? waktuSiap,
    DateTime? waktuSerah,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Resep(
      id: id ?? this.id,
      rekamMedisId: rekamMedisId ?? this.rekamMedisId,
      pasienId: pasienId ?? this.pasienId,
      namaPasien: namaPasien ?? this.namaPasien,
      obat: obat ?? this.obat,
      dosis: dosis ?? this.dosis,
      instruksi: instruksi ?? this.instruksi,
      jumlah: jumlah ?? this.jumlah,
      status: status ?? this.status,
      tanggalResep: tanggalResep ?? this.tanggalResep,
      waktuSiap: waktuSiap ?? this.waktuSiap,
      waktuSerah: waktuSerah ?? this.waktuSerah,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
