import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../models/rekam_medis.dart';

class RekamMedisService {
  final Dio _dio = DioClient.instance.dio;

  Future<List<RekamMedis>> getRekamMedisByPasien(String pasienId) async {
    try {
      final response = await _dio.get('/rekam-medis', queryParameters: {'pasien_id': pasienId});

      final data = response.data;
      if (data is List) {
        return data.map((json) => RekamMedis.fromJson(json)).toList();
      } else if (data['data'] is List) {
        return (data['data'] as List).map((json) => RekamMedis.fromJson(json)).toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal mendapatkan rekam medis');
    }
  }

  Future<RekamMedis> getRekamMedisById(String id) async {
    try {
      final response = await _dio.get('/rekam-medis/$id');
      return RekamMedis.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal mendapatkan rekam medis');
    }
  }

  Future<RekamMedis> createRekamMedis({
    required String pasienId,
    required String dokterId,
    required String keluhan,
    required String diagnosis,
    required String tindakan,
    String? resep,
    String? catatan,
    bool aiAssisted = false,
  }) async {
    try {
      final response = await _dio.post(
        '/rekam-medis',
        data: {
          'pasien_id': pasienId,
          'dokter_id': dokterId,
          'keluhan': keluhan,
          'diagnosis': diagnosis,
          'tindakan': tindakan,
          'resep': resep,
          'catatan': catatan,
          'ai_assisted': aiAssisted,
        },
      );

      return RekamMedis.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal membuat rekam medis');
    }
  }

  Future<RekamMedis> updateRekamMedis({
    required String id,
    required String keluhan,
    required String diagnosis,
    required String tindakan,
    String? resep,
    String? catatan,
  }) async {
    try {
      final response = await _dio.put(
        '/rekam-medis/$id',
        data: {
          'keluhan': keluhan,
          'diagnosis': diagnosis,
          'tindakan': tindakan,
          'resep': resep,
          'catatan': catatan,
        },
      );

      return RekamMedis.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal mengupdate rekam medis');
    }
  }

  Future<RekamMedis> aiAssistRekamMedis({
    required String id,
    required String keluhan,
  }) async {
    try {
      final response = await _dio.post(
        '/rekam-medis/$id/ai-assist',
        data: {'keluhan': keluhan},
      );

      return RekamMedis.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal mendapatkan bantuan AI');
    }
  }

  Future<RekamMedis> approveRekamMedis(String id) async {
    try {
      final response = await _dio.put('/rekam-medis/$id/approve');
      return RekamMedis.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal menyetujui rekam medis');
    }
  }

  Future<void> deleteRekamMedis(String id) async {
    try {
      await _dio.delete('/rekam-medis/$id');
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal menghapus rekam medis');
    }
  }
}