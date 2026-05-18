class DokterModel {
  final int id;
  final String nama;
  final String tipe; // 'umum' | 'poli' | 'spesialis'
  final String? spesialisasi;
  final int? poliId;
  final String? namaPoli;
  final int hargaKonsultasi;
  final String? fotoUrl;
  final String? jadwal;
  final bool statusAktif;

  DokterModel({
    required this.id,
    required this.nama,
    required this.tipe,
    this.spesialisasi,
    this.poliId,
    this.namaPoli,
    required this.hargaKonsultasi,
    this.fotoUrl,
    this.jadwal,
    this.statusAktif = true,
  });

  factory DokterModel.fromJson(Map<String, dynamic> json) => DokterModel(
    id: json['id'],
    nama: json['nama'] ?? '',
    tipe: json['tipe'] ?? 'umum',
    spesialisasi: json['spesialisasi'],
    poliId: json['poli_id'],
    namaPoli: json['nama_poli'],
    hargaKonsultasi: json['harga_konsultasi'] ?? 0,
    fotoUrl: json['foto_url'],
    jadwal: json['jadwal'],
    statusAktif: json['status_aktif'] == 1 || json['status_aktif'] == true,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'nama': nama,
    'tipe': tipe,
    'spesialisasi': spesialisasi,
    'poli_id': poliId,
    'harga_konsultasi': hargaKonsultasi,
    'foto_url': fotoUrl,
    'jadwal': jadwal,
    'status_aktif': statusAktif ? 1 : 0,
  };

  // Label tipe untuk display
  String get labelTipe {
    switch (tipe) {
      case 'umum':
        return 'Dokter Umum';
      case 'poli':
        return 'Dokter Poli';
      case 'spesialis':
        return 'Dokter Spesialis';
      default:
        return tipe;
    }
  }

  // Color badge berdasarkan tipe (hex string)
  String get badgeColor {
    switch (tipe) {
      case 'umum':
        return '#4CAF50';
      case 'poli':
        return '#2196F3';
      case 'spesialis':
        return '#9C27B0';
      default:
        return '#757575';
    }
  }

  // Copy with method
  DokterModel copyWith({
    int? id,
    String? nama,
    String? tipe,
    String? spesialisasi,
    int? poliId,
    String? namaPoli,
    int? hargaKonsultasi,
    String? fotoUrl,
    String? jadwal,
    bool? statusAktif,
  }) {
    return DokterModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      tipe: tipe ?? this.tipe,
      spesialisasi: spesialisasi ?? this.spesialisasi,
      poliId: poliId ?? this.poliId,
      namaPoli: namaPoli ?? this.namaPoli,
      hargaKonsultasi: hargaKonsultasi ?? this.hargaKonsultasi,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      jadwal: jadwal ?? this.jadwal,
      statusAktif: statusAktif ?? this.statusAktif,
    );
  }
}
