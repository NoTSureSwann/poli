import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../models/antrian.dart';

class AntrianService {
  final Dio _dio = DioClient.instance.dio;

  Future<List<Antrian>> getAllAntrian({DateTime? tanggal}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (tanggal != null) {
        queryParams['tanggal'] = tanggal.toIso8601String().split('T')[0];
      }

      final response = await _dio.get('/antrian', queryParameters: queryParams);

      final data = response.data;
      if (data is List) {
        return data.map((json) => Antrian.fromJson(json)).toList();
      } else if (data['data'] is List) {
        return (data['data'] as List)
            .map((json) => Antrian.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal mendapatkan data antrian');
    }
  }

  Future<Antrian> getAntrianById(String id) async {
    try {
      final response = await _dio.get('/antrian/$id');
      return Antrian.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal mendapatkan data antrian');
    }
  }

  Future<Antrian> createAntrian({
    required String pasienId,
    required String namaPasien,
  }) async {
    try {
      final response = await _dio.post(
        '/antrian',
        data: {'pasien_id': pasienId, 'nama_pasien': namaPasien},
      );

      return Antrian.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal membuat antrian');
    }
  }

  Future<Antrian> panggilAntrian(String id) async {
    try {
      final response = await _dio.put('/antrian/$id/panggil');
      return Antrian.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal memanggil antrian');
    }
  }

  Future<Antrian> nextAntrian() async {
    try {
      final response = await _dio.put('/antrian/next');
      return Antrian.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.error?.toString() ?? 'Gagal mendapatkan antrian berikutnya',
      );
    }
  }

  Future<void> deleteAntrian(String id) async {
    try {
      await _dio.delete('/antrian/$id');
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal menghapus antrian');
    }
  }
}
