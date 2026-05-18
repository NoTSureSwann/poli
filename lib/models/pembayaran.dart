enum StatusPembayaran { pending, lunas, dibatalkan }

enum MetodePembayaran { tunai, transfer, bpjs }

class Pembayaran {
  final String id;
  final String pasienId;
  final String namaPasien;
  final String? rekamMedisId;
  final String? resepId;
  final double totalBiaya;
  final double? biayaKonsultasi;
  final double? biayaObat;
  final double? biayaLain;
  final StatusPembayaran status;
  final MetodePembayaran? metodePembayaran;
  final DateTime tanggalPembayaran;
  final DateTime? waktuLunas;
  final String? catatan;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pembayaran({
    required this.id,
    required this.pasienId,
    required this.namaPasien,
    this.rekamMedisId,
    this.resepId,
    required this.totalBiaya,
    this.biayaKonsultasi,
    this.biayaObat,
    this.biayaLain,
    required this.status,
    this.metodePembayaran,
    required this.tanggalPembayaran,
    this.waktuLunas,
    this.catatan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pembayaran.fromJson(Map<String, dynamic> json) {
    return Pembayaran(
      id: json['id'].toString(),
      pasienId: json['pasien_id'].toString(),
      namaPasien: json['nama_pasien'] ?? '',
      rekamMedisId: json['rekam_medis_id']?.toString(),
      resepId: json['resep_id']?.toString(),
      totalBiaya: (json['total_biaya'] ?? 0).toDouble(),
      biayaKonsultasi: json['biaya_konsultasi']?.toDouble(),
      biayaObat: json['biaya_obat']?.toDouble(),
      biayaLain: json['biaya_lain']?.toDouble(),
      status: _parseStatus(json['status']),
      metodePembayaran: _parseMetode(json['metode_pembayaran']),
      tanggalPembayaran: DateTime.parse(
        json['tanggal_pembayaran'] ?? DateTime.now().toIso8601String(),
      ),
      waktuLunas: json['waktu_lunas'] != null
          ? DateTime.parse(json['waktu_lunas'])
          : null,
      catatan: json['catatan'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  static StatusPembayaran _parseStatus(String? status) {
    switch (status) {
      case 'lunas':
        return StatusPembayaran.lunas;
      case 'dibatalkan':
        return StatusPembayaran.dibatalkan;
      case 'pending':
      default:
        return StatusPembayaran.pending;
    }
  }

  static MetodePembayaran? _parseMetode(String? metode) {
    switch (metode) {
      case 'transfer':
        return MetodePembayaran.transfer;
      case 'bpjs':
        return MetodePembayaran.bpjs;
      case 'tunai':
      default:
        return MetodePembayaran.tunai;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pasien_id': pasienId,
      'nama_pasien': namaPasien,
      'rekam_medis_id': rekamMedisId,
      'resep_id': resepId,
      'total_biaya': totalBiaya,
      'biaya_konsultasi': biayaKonsultasi,
      'biaya_obat': biayaObat,
      'biaya_lain': biayaLain,
      'status': status.name,
      'metode_pembayaran': metodePembayaran?.name,
      'tanggal_pembayaran': tanggalPembayaran.toIso8601String(),
      'waktu_lunas': waktuLunas?.toIso8601String(),
      'catatan': catatan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Pembayaran copyWith({
    String? id,
    String? pasienId,
    String? namaPasien,
    String? rekamMedisId,
    String? resepId,
    double? totalBiaya,
    double? biayaKonsultasi,
    double? biayaObat,
    double? biayaLain,
    StatusPembayaran? status,
    MetodePembayaran? metodePembayaran,
    DateTime? tanggalPembayaran,
    DateTime? waktuLunas,
    String? catatan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pembayaran(
      id: id ?? this.id,
      pasienId: pasienId ?? this.pasienId,
      namaPasien: namaPasien ?? this.namaPasien,
      rekamMedisId: rekamMedisId ?? this.rekamMedisId,
      resepId: resepId ?? this.resepId,
      totalBiaya: totalBiaya ?? this.totalBiaya,
      biayaKonsultasi: biayaKonsultasi ?? this.biayaKonsultasi,
      biayaObat: biayaObat ?? this.biayaObat,
      biayaLain: biayaLain ?? this.biayaLain,
      status: status ?? this.status,
      metodePembayaran: metodePembayaran ?? this.metodePembayaran,
      tanggalPembayaran: tanggalPembayaran ?? this.tanggalPembayaran,
      waktuLunas: waktuLunas ?? this.waktuLunas,
      catatan: catatan ?? this.catatan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
