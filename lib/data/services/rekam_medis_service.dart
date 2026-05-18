import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/interceptors/error_interceptor.dart';
import '../models/rekam_medis_model.dart';

class RekamMedisService {
  RekamMedisService({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient.instance;

  final DioClient _dioClient;

  Future<List<RekamMedisModel>> fetchRekamMedis({
    int? pasienId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.rekamMedis,
        queryParameters: {'pasien_id': ?pasienId, 'page': page, 'limit': limit},
      );

      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      if (data is List) {
        return data
            .map(
              (item) => RekamMedisModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<RekamMedisModel> createRekamMedis({
    required RekamMedisModel rekamMedis,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.rekamMedis,
        data: rekamMedis.toJson(),
      );
      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      return RekamMedisModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<RekamMedisModel> getRekamMedisById(int id) async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.rekamMedis}/$id',
      );
      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      return RekamMedisModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<Map<String, dynamic>> aiAssist({
    required int id,
    required String context,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '${ApiConstants.rekamMedis}/$id${ApiConstants.rekamMedisAiAssist}',
        data: {'context': context},
      );
      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      return data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<RekamMedisModel> approveRekamMedis({
    required int id,
    required String diagnosis,
    required String tindakanRencana,
    required String icd10Code,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '${ApiConstants.rekamMedis}/$id${ApiConstants.rekamMedisApprove}',
        data: {
          'diagnosis': diagnosis,
          'tindakan_rencana': tindakanRencana,
          'icd10_code': icd10Code,
        },
      );
      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      return RekamMedisModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  AppException _parseDioException(DioException error) {
    if (error.error is AppException) {
      return error.error as AppException;
    }
    return AppException(
      error.message ?? 'Terjadi kesalahan saat menghubungi server.',
    );
  }
}
