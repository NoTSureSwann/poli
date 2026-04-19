class Patient {
  final String id;
  final String nama;
  final String nik;
  final DateTime tanggalLahir;
  final String alamat;
  final String jenisKelamin;
  final String? noBPJS;
  final String? phoneNumber;
  final DateTime createdAt;

  Patient({
    required this.id,
    required this.nama,
    required this.nik,
    required this.tanggalLahir,
    required this.alamat,
    required this.jenisKelamin,
    this.noBPJS,
    this.phoneNumber,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      nama: json['nama'] as String,
      nik: json['nik'] as String,
      tanggalLahir: DateTime.parse(json['tanggal_lahir'] as String),
      alamat: json['alamat'] as String,
      jenisKelamin: json['jenis_kelamin'] as String,
      noBPJS: json['no_bpjs'] as String?,
      phoneNumber: json['phone_number'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'nik': nik,
      'tanggal_lahir': tanggalLahir.toIso8601String(),
      'alamat': alamat,
      'jenis_kelamin': jenisKelamin,
      'no_bpjs': noBPJS,
      'phone_number': phoneNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get age {
    final now = DateTime.now();
    int years = now.year - tanggalLahir.year;
    if (now.month < tanggalLahir.month ||
        (now.month == tanggalLahir.month && now.day < tanggalLahir.day)) {
      years--;
    }
    return '$years tahun';
  }

  bool get hasBPJS => noBPJS != null && noBPJS!.isNotEmpty;
}
