class PoliModel {
  final String id;
  final String namaPoli;
  final String deskripsi;
  final String jamBuka;
  final String jamTutup;
  final String icon;

  PoliModel({
    required this.id,
    required this.namaPoli,
    required this.deskripsi,
    required this.jamBuka,
    required this.jamTutup,
    this.icon = 'local_hospital',
  });

  factory PoliModel.fromJson(Map<String, dynamic> json) {
    return PoliModel(
      id: json['id']?.toString() ?? '',
      namaPoli: json['nama_poli'] ?? json['name'] ?? '', // support mockapi
      deskripsi: json['deskripsi'] ?? json['description'] ?? '',
      jamBuka: json['jam_buka'] ?? '08:00',
      jamTutup: json['jam_tutup'] ?? '16:00',
      icon: json['icon'] ?? 'local_hospital',
    );
  }
}
