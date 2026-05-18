class ApiConstants {
  ApiConstants._();

  static const String _defaultHost = 'localhost:3001';
  static const String _androidEmulatorHost = '10.0.2.2:3001';
  static const String _apiPath = '/api';

  /// Default host for physical device or web.
  static String baseHost = _defaultHost;

  static String get baseUrl => 'http://$baseHost$_apiPath';

  /// Panggil ini saat menjalankan di emulator Android.
  static void useAndroidEmulator() {
    baseHost = _androidEmulatorHost;
  }

  /// Panggil ini saat menjalankan di perangkat fisik atau web.
  static void setHost(String host) {
    baseHost = host;
  }

  static const Duration timeout = Duration(seconds: 10);

  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authMe = '/auth/me';

  static const String pasien = '/pasien';
  static const String pasienNik = '/pasien/nik';
  static const String pasienRekamMedis = '/pasien';

  static const String rekamMedis = '/rekam-medis';
  static const String rekamMedisAiAssist = '/ai-assist';
  static const String rekamMedisApprove = '/approve';

  static const String antrian = '/antrian';
  static const String antrianPanggil = '/panggil';
  static const String antrianCall = '/panggil'; // alias for data services
  static const String antrianNext = '/next';

  static const String resep = '/resep';
  static const String resepSiapkan = '/siapkan';
  static const String resepPrepare = '/siapkan'; // alias for data services
  static const String resepSerahkan = '/serahkan';
  static const String resepDeliver = '/serahkan'; // alias for data services

  static const String stokObat = '/stok-obat';
  static const String stokObatTambah = '/tambah';

  static const String pembayaran = '/pembayaran';
  static const String pembayaranProses = '/proses';
  static const String pembayaranProcess = '/proses'; // alias for data services

  // Endpoints referenced by repositories
  static const String dokter = '/dokter';
  static const String adminPembayaran = '/admin/pembayaran';
  static const String layanan = '/layanan';
}
