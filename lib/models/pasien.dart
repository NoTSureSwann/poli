class Pasien {
  final String id;
  final String nik;
  final String nama;
  final String alamat;
  final String noHp;
  final String tanggalLahir;
  final String jenisKelamin;
  final String? bpjs;
  final String? alergi;
  final String? riwayatPenyakit;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pasien({
    required this.id,
    required this.nik,
    required this.nama,
    required this.alamat,
    required this.noHp,
    required this.tanggalLahir,
    required this.jenisKelamin,
    this.bpjs,
    this.alergi,
    this.riwayatPenyakit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pasien.fromJson(Map<String, dynamic> json) {
    return Pasien(
      id: json['id'].toString(),
      nik: json['nik'] ?? '',
      nama: json['nama'] ?? '',
      alamat: json['alamat'] ?? '',
      noHp: json['no_hp'] ?? '',
      tanggalLahir: json['tanggal_lahir'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? '',
      bpjs: json['bpjs'],
      alergi: json['alergi'],
      riwayatPenyakit: json['riwayat_penyakit'],
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
      'nik': nik,
      'nama': nama,
      'alamat': alamat,
      'no_hp': noHp,
      'tanggal_lahir': tanggalLahir,
      'jenis_kelamin': jenisKelamin,
      'bpjs': bpjs,
      'alergi': alergi,
      'riwayat_penyakit': riwayatPenyakit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Pasien copyWith({
    String? id,
    String? nik,
    String? nama,
    String? alamat,
    String? noHp,
    String? tanggalLahir,
    String? jenisKelamin,
    String? bpjs,
    String? alergi,
    String? riwayatPenyakit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pasien(
      id: id ?? this.id,
      nik: nik ?? this.nik,
      nama: nama ?? this.nama,
      alamat: alamat ?? this.alamat,
      noHp: noHp ?? this.noHp,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      bpjs: bpjs ?? this.bpjs,
      alergi: alergi ?? this.alergi,
      riwayatPenyakit: riwayatPenyakit ?? this.riwayatPenyakit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
