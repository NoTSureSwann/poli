import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../models/pembayaran.dart';

class PembayaranService {
  final Dio _dio = DioClient.instance.dio;

  Future<List<Pembayaran>> getAllPembayaran({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        '/pembayaran',
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is List) {
        return data.map((json) => Pembayaran.fromJson(json)).toList();
      } else if (data['data'] is List) {
        return (data['data'] as List)
            .map((json) => Pembayaran.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(
        e.error?.toString() ?? 'Gagal mendapatkan data pembayaran',
      );
    }
  }

  Future<Pembayaran> getPembayaranById(String id) async {
    try {
      final response = await _dio.get('/pembayaran/$id');
      return Pembayaran.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.error?.toString() ?? 'Gagal mendapatkan data pembayaran',
      );
    }
  }

  Future<List<Pembayaran>> getPembayaranByPasien(String pasienId) async {
    try {
      final response = await _dio.get(
        '/pembayaran',
        queryParameters: {'pasien_id': pasienId},
      );

      final data = response.data;
      if (data is List) {
        return data.map((json) => Pembayaran.fromJson(json)).toList();
      } else if (data['data'] is List) {
        return (data['data'] as List)
            .map((json) => Pembayaran.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(
        e.error?.toString() ?? 'Gagal mendapatkan pembayaran pasien',
      );
    }
  }

  Future<Pembayaran> createPembayaran({
    required String pasienId,
    required String namaPasien,
    String? rekamMedisId,
    String? resepId,
    required double totalBiaya,
    double? biayaKonsultasi,
    double? biayaObat,
    double? biayaLain,
    String? catatan,
  }) async {
    try {
      final response = await _dio.post(
        '/pembayaran',
        data: {
          'pasien_id': pasienId,
          'nama_pasien': namaPasien,
          'rekam_medis_id': rekamMedisId,
          'resep_id': resepId,
          'total_biaya': totalBiaya,
          'biaya_konsultasi': biayaKonsultasi,
          'biaya_obat': biayaObat,
          'biaya_lain': biayaLain,
          'catatan': catatan,
        },
      );

      return Pembayaran.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal membuat pembayaran');
    }
  }

  Future<Pembayaran> prosesPembayaran({
    required String id,
    required MetodePembayaran metodePembayaran,
  }) async {
    try {
      final response = await _dio.put(
        '/pembayaran/$id/proses',
        data: {'metode_pembayaran': metodePembayaran.name},
      );

      return Pembayaran.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal memproses pembayaran');
    }
  }

  Future<void> deletePembayaran(String id) async {
    try {
      await _dio.delete('/pembayaran/$id');
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal menghapus pembayaran');
    }
  }
}
