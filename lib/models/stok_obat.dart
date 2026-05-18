class StokObat {
  final String id;
  final String namaObat;
  final String deskripsi;
  final int stok;
  final int minimumStok;
  final String satuan;
  final DateTime tanggalKadaluarsa;
  final String? lokasiPenyimpanan;
  final DateTime createdAt;
  final DateTime updatedAt;

  StokObat({
    required this.id,
    required this.namaObat,
    required this.deskripsi,
    required this.stok,
    required this.minimumStok,
    required this.satuan,
    required this.tanggalKadaluarsa,
    this.lokasiPenyimpanan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StokObat.fromJson(Map<String, dynamic> json) {
    return StokObat(
      id: json['id'].toString(),
      namaObat: json['nama_obat'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      stok: json['stok'] ?? 0,
      minimumStok: json['minimum_stok'] ?? 0,
      satuan: json['satuan'] ?? '',
      tanggalKadaluarsa: DateTime.parse(
        json['tanggal_kadaluarsa'] ?? DateTime.now().toIso8601String(),
      ),
      lokasiPenyimpanan: json['lokasi_penyimpanan'],
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
      'nama_obat': namaObat,
      'deskripsi': deskripsi,
      'stok': stok,
      'minimum_stok': minimumStok,
      'satuan': satuan,
      'tanggal_kadaluarsa': tanggalKadaluarsa.toIso8601String(),
      'lokasi_penyimpanan': lokasiPenyimpanan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  StokObat copyWith({
    String? id,
    String? namaObat,
    String? deskripsi,
    int? stok,
    int? minimumStok,
    String? satuan,
    DateTime? tanggalKadaluarsa,
    String? lokasiPenyimpanan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StokObat(
      id: id ?? this.id,
      namaObat: namaObat ?? this.namaObat,
      deskripsi: deskripsi ?? this.deskripsi,
      stok: stok ?? this.stok,
      minimumStok: minimumStok ?? this.minimumStok,
      satuan: satuan ?? this.satuan,
      tanggalKadaluarsa: tanggalKadaluarsa ?? this.tanggalKadaluarsa,
      lokasiPenyimpanan: lokasiPenyimpanan ?? this.lokasiPenyimpanan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isLowStock => stok <= minimumStok;
  bool get isExpired => tanggalKadaluarsa.isBefore(DateTime.now());
}
