class Patient {
  final String id;
  final String? noRM;
  final String nama;
  final String nik;
  final DateTime tanggalLahir;
  final String alamat;
  final String jenisKelamin; // Backend uses 'L' or 'P'
  final String? bpjsId;
  final String? noTelepon;
  final DateTime createdAt;

  Patient({
    required this.id,
    this.noRM,
    required this.nama,
    required this.nik,
    required this.tanggalLahir,
    required this.alamat,
    required this.jenisKelamin,
    String? bpjsId,
    String? noTelepon,
    String? noBPJS,
    String? phoneNumber,
    DateTime? createdAt,
  }) : bpjsId = bpjsId ?? noBPJS,
       noTelepon = noTelepon ?? phoneNumber,
       createdAt = createdAt ?? DateTime.now();

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: (json['id'] ?? '').toString(),
      noRM: (json['no_rm'] ?? '').toString().isEmpty
          ? null
          : json['no_rm'].toString(),
      nama: (json['nama'] ?? '').toString(),
      nik: (json['nik'] ?? '').toString(),
      tanggalLahir:
          DateTime.tryParse((json['tanggal_lahir'] ?? '').toString()) ??
          DateTime.now(),
      alamat: (json['alamat'] ?? '').toString(),
      jenisKelamin: (json['jenis_kelamin'] ?? 'L').toString(),
      bpjsId: json['bpjs_id']?.toString(),
      noTelepon: json['no_telepon']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      if (noRM != null && noRM!.isNotEmpty) 'no_rm': noRM,
      'nama': nama,
      'nik': nik,
      'tanggal_lahir':
          '${tanggalLahir.year.toString().padLeft(4, '0')}-${tanggalLahir.month.toString().padLeft(2, '0')}-${tanggalLahir.day.toString().padLeft(2, '0')}',
      'alamat': alamat,
      'jenis_kelamin': jenisKelamin,
      'bpjs_id': bpjsId,
      'no_telepon': noTelepon,
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

  String get genderLabel =>
      jenisKelamin.toUpperCase() == 'L' ? 'Laki-laki' : 'Perempuan';

  // Backward-compatible getters for existing UI code
  String? get noBPJS => bpjsId;
  String? get phoneNumber => noTelepon;

  bool get hasBPJS => bpjsId != null && bpjsId!.isNotEmpty;
}
