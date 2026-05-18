class StokObatModel {
  final int? id;
  final String kodeObat;
  final String namaGenerik;
  final String? namaDagang;
  final String? kategori;
  final String satuan;
  final int stokTersedia;
  final int stokMinimum;
  final double? hargaBeli;
  final double? hargaJual;
  final String? createdAt;
  final String? updatedAt;

  StokObatModel({
    this.id,
    required this.kodeObat,
    required this.namaGenerik,
    this.namaDagang,
    this.kategori,
    required this.satuan,
    required this.stokTersedia,
    required this.stokMinimum,
    this.hargaBeli,
    this.hargaJual,
    this.createdAt,
    this.updatedAt,
  });

  factory StokObatModel.fromJson(Map<String, dynamic> json) {
    return StokObatModel(
      id: json['id'] as int?,
      kodeObat: json['kode_obat']?.toString() ?? '',
      namaGenerik: json['nama_generik']?.toString() ?? '',
      namaDagang: json['nama_dagang']?.toString(),
      kategori: json['kategori']?.toString(),
      satuan: json['satuan']?.toString() ?? '',
      stokTersedia: json['stok_tersedia'] as int? ?? 0,
      stokMinimum: json['stok_minimum'] as int? ?? 0,
      hargaBeli: (json['harga_beli'] as num?)?.toDouble(),
      hargaJual: (json['harga_jual'] as num?)?.toDouble(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kode_obat': kodeObat,
      'nama_generik': namaGenerik,
      'nama_dagang': namaDagang,
      'kategori': kategori,
      'satuan': satuan,
      'stok_tersedia': stokTersedia,
      'stok_minimum': stokMinimum,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
    };
  }

  StokObatModel copyWith({
    int? id,
    String? kodeObat,
    String? namaGenerik,
    String? namaDagang,
    String? kategori,
    String? satuan,
    int? stokTersedia,
    int? stokMinimum,
    double? hargaBeli,
    double? hargaJual,
    String? createdAt,
    String? updatedAt,
  }) {
    return StokObatModel(
      id: id ?? this.id,
      kodeObat: kodeObat ?? this.kodeObat,
      namaGenerik: namaGenerik ?? this.namaGenerik,
      namaDagang: namaDagang ?? this.namaDagang,
      kategori: kategori ?? this.kategori,
      satuan: satuan ?? this.satuan,
      stokTersedia: stokTersedia ?? this.stokTersedia,
      stokMinimum: stokMinimum ?? this.stokMinimum,
      hargaBeli: hargaBeli ?? this.hargaBeli,
      hargaJual: hargaJual ?? this.hargaJual,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
