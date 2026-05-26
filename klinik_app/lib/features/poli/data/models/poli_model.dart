class PoliModel {
  final String id;
  final String namaPoli;
  final String deskripsi;
  final String jamBuka;
  final String jamTutup;
  final String icon;
  final String kategori; // Tambahan untuk pengelompokan

  PoliModel({
    required this.id,
    required this.namaPoli,
    required this.deskripsi,
    required this.jamBuka,
    required this.jamTutup,
    this.icon = 'local_hospital',
    this.kategori = 'Umum',
  });

  factory PoliModel.fromJson(Map<String, dynamic> json) {
    return PoliModel(
      id: json['id']?.toString() ?? '',
      namaPoli: json['nama_poli'] ?? json['name'] ?? '', 
      deskripsi: json['deskripsi'] ?? json['description'] ?? '',
      jamBuka: json['jam_buka'] ?? '08:00',
      jamTutup: json['jam_tutup'] ?? '16:00',
      icon: json['icon'] ?? 'local_hospital',
      kategori: json['kategori'] ?? 'Umum',
    );
  }
}
