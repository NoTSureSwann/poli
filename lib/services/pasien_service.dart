import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../models/pasien.dart';

class PasienService {
  final Dio _dio = DioClient.instance.dio;

  Future<List<Pasien>> getAllPasien({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get('/pasien', queryParameters: queryParams);

      final data = response.data;
      if (data is List) {
        return data.map((json) => Pasien.fromJson(json)).toList();
      } else if (data['data'] is List) {
        return (data['data'] as List)
            .map((json) => Pasien.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal mendapatkan data pasien');
    }
  }

  Future<Pasien> getPasienById(String id) async {
    try {
      final response = await _dio.get('/pasien/$id');
      return Pasien.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal mendapatkan data pasien');
    }
  }

  Future<Pasien> getPasienByNik(String nik) async {
    try {
      final response = await _dio.get('/pasien/nik/$nik');
      return Pasien.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal mendapatkan data pasien');
    }
  }

  Future<Pasien> createPasien({
    required String nik,
    required String nama,
    required String alamat,
    required String noHp,
    required String tanggalLahir,
    required String jenisKelamin,
    String? bpjs,
    String? alergi,
    String? riwayatPenyakit,
  }) async {
    try {
      final response = await _dio.post(
        '/pasien',
        data: {
          'nik': nik,
          'nama': nama,
          'alamat': alamat,
          'no_hp': noHp,
          'tanggal_lahir': tanggalLahir,
          'jenis_kelamin': jenisKelamin,
          'bpjs': bpjs,
          'alergi': alergi,
          'riwayat_penyakit': riwayatPenyakit,
        },
      );

      return Pasien.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal membuat data pasien');
    }
  }

  Future<Pasien> updatePasien({
    required String id,
    required String nik,
    required String nama,
    required String alamat,
    required String noHp,
    required String tanggalLahir,
    required String jenisKelamin,
    String? bpjs,
    String? alergi,
    String? riwayatPenyakit,
  }) async {
    try {
      final response = await _dio.put(
        '/pasien/$id',
        data: {
          'nik': nik,
          'nama': nama,
          'alamat': alamat,
          'no_hp': noHp,
          'tanggal_lahir': tanggalLahir,
          'jenis_kelamin': jenisKelamin,
          'bpjs': bpjs,
          'alergi': alergi,
          'riwayat_penyakit': riwayatPenyakit,
        },
      );

      return Pasien.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal mengupdate data pasien');
    }
  }

  Future<void> deletePasien(String id) async {
    try {
      await _dio.delete('/pasien/$id');
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal menghapus data pasien');
    }
  }
}
