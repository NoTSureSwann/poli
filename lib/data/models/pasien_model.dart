class PasienModel {
  final int? id;
  final String noRm;
  final String nama;
  final String nik;
  final String? bpjsId;
  final String tanggalLahir;
  final String jenisKelamin;
  final String? golonganDarah;
  final String? alamat;
  final String? noTelepon;
  final String? email;
  final List<String>? alergi;

  PasienModel({
    this.id,
    required this.noRm,
    required this.nama,
    required this.nik,
    this.bpjsId,
    required this.tanggalLahir,
    required this.jenisKelamin,
    this.golonganDarah,
    this.alamat,
    this.noTelepon,
    this.email,
    this.alergi,
  });

  factory PasienModel.fromJson(Map<String, dynamic> json) {
    final alergiData = json['alergi'];
    List<String>? alergiList;

    if (alergiData is List) {
      alergiList = alergiData.map((item) => item.toString()).toList();
    } else if (alergiData is String && alergiData.isNotEmpty) {
      alergiList = alergiData.split(',').map((item) => item.trim()).toList();
    }

    return PasienModel(
      id: json['id'] as int?,
      noRm: json['no_rm']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      nik: json['nik']?.toString() ?? '',
      bpjsId: json['bpjs_id']?.toString(),
      tanggalLahir: json['tanggal_lahir']?.toString() ?? '',
      jenisKelamin: json['jenis_kelamin']?.toString() ?? '',
      golonganDarah: json['golongan_darah']?.toString(),
      alamat: json['alamat']?.toString(),
      noTelepon: json['no_telepon']?.toString(),
      email: json['email']?.toString(),
      alergi: alergiList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'no_rm': noRm,
      'nama': nama,
      'nik': nik,
      'bpjs_id': bpjsId,
      'tanggal_lahir': tanggalLahir,
      'jenis_kelamin': jenisKelamin,
      'golongan_darah': golonganDarah,
      'alamat': alamat,
      'no_telepon': noTelepon,
      'email': email,
      'alergi': alergi,
    };
  }

  PasienModel copyWith({
    int? id,
    String? noRm,
    String? nama,
    String? nik,
    String? bpjsId,
    String? tanggalLahir,
    String? jenisKelamin,
    String? golonganDarah,
    String? alamat,
    String? noTelepon,
    String? email,
    List<String>? alergi,
  }) {
    return PasienModel(
      id: id ?? this.id,
      noRm: noRm ?? this.noRm,
      nama: nama ?? this.nama,
      nik: nik ?? this.nik,
      bpjsId: bpjsId ?? this.bpjsId,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      golonganDarah: golonganDarah ?? this.golonganDarah,
      alamat: alamat ?? this.alamat,
      noTelepon: noTelepon ?? this.noTelepon,
      email: email ?? this.email,
      alergi: alergi ?? this.alergi,
    );
  }
}
