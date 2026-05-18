class RekamMedisModel {
  final int? id;
  final int pasienId;
  final String? keluhanUtama;
  final String? pemeriksaanFisik;
  final String? tekananDarah;
  final String? nadi;
  final String? suhu;
  final String? beratBadan;
  final String? tinggiBadan;
  final String? saturasiOksigen;
  final String? diagnosis;
  final String? tindakanRencana;
  final String? icd10Code;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  RekamMedisModel({
    this.id,
    required this.pasienId,
    this.keluhanUtama,
    this.pemeriksaanFisik,
    this.tekananDarah,
    this.nadi,
    this.suhu,
    this.beratBadan,
    this.tinggiBadan,
    this.saturasiOksigen,
    this.diagnosis,
    this.tindakanRencana,
    this.icd10Code,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory RekamMedisModel.fromJson(Map<String, dynamic> json) {
    return RekamMedisModel(
      id: json['id'] as int?,
      pasienId: json['pasien_id'] as int? ?? 0,
      keluhanUtama: json['keluhan_utama']?.toString(),
      pemeriksaanFisik: json['pemeriksaan_fisik']?.toString(),
      tekananDarah: json['tekanan_darah']?.toString(),
      nadi: json['nadi']?.toString(),
      suhu: json['suhu']?.toString(),
      beratBadan: json['berat_badan']?.toString(),
      tinggiBadan: json['tinggi_badan']?.toString(),
      saturasiOksigen: json['saturasi_oksigen']?.toString(),
      diagnosis: json['diagnosis']?.toString(),
      tindakanRencana: json['tindakan_rencana']?.toString(),
      icd10Code: json['icd10_code']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pasien_id': pasienId,
      'keluhan_utama': keluhanUtama,
      'pemeriksaan_fisik': pemeriksaanFisik,
      'tekanan_darah': tekananDarah,
      'nadi': nadi,
      'suhu': suhu,
      'berat_badan': beratBadan,
      'tinggi_badan': tinggiBadan,
      'saturasi_oksigen': saturasiOksigen,
      'diagnosis': diagnosis,
      'tindakan_rencana': tindakanRencana,
      'icd10_code': icd10Code,
      'status': status,
    };
  }

  RekamMedisModel copyWith({
    int? id,
    int? pasienId,
    String? keluhanUtama,
    String? pemeriksaanFisik,
    String? tekananDarah,
    String? nadi,
    String? suhu,
    String? beratBadan,
    String? tinggiBadan,
    String? saturasiOksigen,
    String? diagnosis,
    String? tindakanRencana,
    String? icd10Code,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return RekamMedisModel(
      id: id ?? this.id,
      pasienId: pasienId ?? this.pasienId,
      keluhanUtama: keluhanUtama ?? this.keluhanUtama,
      pemeriksaanFisik: pemeriksaanFisik ?? this.pemeriksaanFisik,
      tekananDarah: tekananDarah ?? this.tekananDarah,
      nadi: nadi ?? this.nadi,
      suhu: suhu ?? this.suhu,
      beratBadan: beratBadan ?? this.beratBadan,
      tinggiBadan: tinggiBadan ?? this.tinggiBadan,
      saturasiOksigen: saturasiOksigen ?? this.saturasiOksigen,
      diagnosis: diagnosis ?? this.diagnosis,
      tindakanRencana: tindakanRencana ?? this.tindakanRencana,
      icd10Code: icd10Code ?? this.icd10Code,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
