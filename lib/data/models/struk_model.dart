class StrukModel {
  final String noStruk;
  final String barcodeValue;
  final String tanggal;
  final KlinikInfo klinik;
  final PasienInfo pasien;
  final DokterInfo dokter;
  final String? diagnosa;
  final List<ItemJasa> detailJasa;
  final List<ItemObat> detailObat;
  final int subtotalJasa;
  final int subtotalObat;
  final int diskon;
  final int total;
  final String metodeBayar;
  final String kasir;
  final String status;

  StrukModel({
    required this.noStruk,
    required this.barcodeValue,
    required this.tanggal,
    required this.klinik,
    required this.pasien,
    required this.dokter,
    this.diagnosa,
    required this.detailJasa,
    required this.detailObat,
    required this.subtotalJasa,
    required this.subtotalObat,
    required this.diskon,
    required this.total,
    required this.metodeBayar,
    required this.kasir,
    required this.status,
  });

  factory StrukModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return StrukModel(
      noStruk: data['no_struk'] ?? '',
      barcodeValue: data['barcode_value'] ?? '',
      tanggal: data['tanggal'] ?? '',
      klinik: KlinikInfo.fromJson(data['klinik']),
      pasien: PasienInfo.fromJson(data['pasien']),
      dokter: DokterInfo.fromJson(data['dokter']),
      diagnosa: data['diagnosa'],
      detailJasa:
          (data['detail_jasa'] as List?)
              ?.map((e) => ItemJasa.fromJson(e))
              .toList() ??
          [],
      detailObat:
          (data['detail_obat'] as List?)
              ?.map((e) => ItemObat.fromJson(e))
              .toList() ??
          [],
      subtotalJasa: data['subtotal_jasa'] ?? 0,
      subtotalObat: data['subtotal_obat'] ?? 0,
      diskon: data['diskon'] ?? 0,
      total: data['total'] ?? 0,
      metodeBayar: data['metode_bayar'] ?? 'tunai',
      kasir: data['kasir'] ?? 'Kasir Sistem',
      status: data['status'] ?? 'lunas',
    );
  }
}

class KlinikInfo {
  final String nama;
  final String alamat;
  final String telepon;
  final String email;

  KlinikInfo({
    required this.nama,
    required this.alamat,
    required this.telepon,
    required this.email,
  });

  factory KlinikInfo.fromJson(Map<String, dynamic> j) => KlinikInfo(
    nama: j['nama'] ?? 'Klinik Merah Putih',
    alamat: j['alamat'] ?? '',
    telepon: j['telepon'] ?? '',
    email: j['email'] ?? '',
  );
}

class PasienInfo {
  final String nama;
  final String noRm;
  final String nik;
  final String tanggalLahir;
  final String alamat;

  PasienInfo({
    required this.nama,
    required this.noRm,
    required this.nik,
    required this.tanggalLahir,
    required this.alamat,
  });

  factory PasienInfo.fromJson(Map<String, dynamic> j) => PasienInfo(
    nama: j['nama'] ?? '',
    noRm: j['no_rm'] ?? '-',
    nik: j['nik'] ?? '-',
    tanggalLahir: j['tanggal_lahir'] ?? '-',
    alamat: j['alamat'] ?? '-',
  );
}

class DokterInfo {
  final String nama;
  final String spesialisasi;
  final String poli;

  DokterInfo({
    required this.nama,
    required this.spesialisasi,
    required this.poli,
  });

  factory DokterInfo.fromJson(Map<String, dynamic> j) => DokterInfo(
    nama: j['nama'] ?? '-',
    spesialisasi: j['spesialisasi'] ?? 'Umum',
    poli: j['poli'] ?? '-',
  );
}

class ItemJasa {
  final String namaItem;
  final int qty;
  final int hargaSatuan;
  final int subtotal;

  ItemJasa({
    required this.namaItem,
    required this.qty,
    required this.hargaSatuan,
    required this.subtotal,
  });

  factory ItemJasa.fromJson(Map<String, dynamic> j) => ItemJasa(
    namaItem: j['nama_item'] ?? '',
    qty: j['qty'] ?? 1,
    hargaSatuan: j['harga_satuan'] ?? 0,
    subtotal: j['subtotal'] ?? 0,
  );
}

class ItemObat {
  final String namaObat;
  final int qty;
  final int hargaSatuan;
  final int subtotal;

  ItemObat({
    required this.namaObat,
    required this.qty,
    required this.hargaSatuan,
    required this.subtotal,
  });

  factory ItemObat.fromJson(Map<String, dynamic> j) => ItemObat(
    namaObat: j['nama_obat'] ?? '',
    qty: j['qty'] ?? 1,
    hargaSatuan: j['harga_satuan'] ?? 0,
    subtotal: j['subtotal'] ?? 0,
  );
}
