import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../models/resep.dart';

class ResepService {
  final Dio _dio = DioClient.instance.dio;

  Future<List<Resep>> getAllResep({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _dio.get('/resep', queryParameters: queryParams);

      final data = response.data;
      if (data is List) {
        return data.map((json) => Resep.fromJson(json)).toList();
      } else if (data['data'] is List) {
        return (data['data'] as List)
            .map((json) => Resep.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal mendapatkan data resep');
    }
  }

  Future<Resep> getResepById(String id) async {
    try {
      final response = await _dio.get('/resep/$id');
      return Resep.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal mendapatkan data resep');
    }
  }

  Future<List<Resep>> getResepByPasien(String pasienId) async {
    try {
      final response = await _dio.get(
        '/resep',
        queryParameters: {'pasien_id': pasienId},
      );

      final data = response.data;
      if (data is List) {
        return data.map((json) => Resep.fromJson(json)).toList();
      } else if (data['data'] is List) {
        return (data['data'] as List)
            .map((json) => Resep.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal mendapatkan resep pasien');
    }
  }

  Future<Resep> createResep({
    required String rekamMedisId,
    required String obat,
    required String dosis,
    required String instruksi,
    required int jumlah,
  }) async {
    try {
      final response = await _dio.post(
        '/resep',
        data: {
          'rekam_medis_id': rekamMedisId,
          'obat': obat,
          'dosis': dosis,
          'instruksi': instruksi,
          'jumlah': jumlah,
        },
      );

      return Resep.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal membuat resep');
    }
  }

  Future<Resep> siapkanResep(String id) async {
    try {
      final response = await _dio.put('/resep/$id/siapkan');
      return Resep.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal menyiapkan resep');
    }
  }

  Future<Resep> serahkanResep(String id) async {
    try {
      final response = await _dio.put('/resep/$id/serahkan');
      return Resep.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal menyerahkan resep');
    }
  }

  Future<void> deleteResep(String id) async {
    try {
      await _dio.delete('/resep/$id');
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal menghapus resep');
    }
  }
}
