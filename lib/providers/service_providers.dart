import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/antrian_service.dart';
import '../data/services/auth_service.dart';
import '../data/services/pasien_service.dart';
import '../data/services/pembayaran_service.dart';
import '../data/services/rekam_medis_service.dart';
import '../data/services/resep_service.dart';
import '../data/services/stok_obat_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final pasienServiceProvider = Provider<PasienService>((ref) {
  return PasienService();
});

final rekamMedisServiceProvider = Provider<RekamMedisService>((ref) {
  return RekamMedisService();
});

final antrianServiceProvider = Provider<AntrianService>((ref) {
  return AntrianService();
});

final resepServiceProvider = Provider<ResepService>((ref) {
  return ResepService();
});

final stokObatServiceProvider = Provider<StokObatService>((ref) {
  return StokObatService();
});

final pembayaranServiceProvider = Provider<PembayaranService>((ref) {
  return PembayaranService();
});
