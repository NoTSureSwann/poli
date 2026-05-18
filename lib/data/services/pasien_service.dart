import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/interceptors/error_interceptor.dart';
import '../models/pasien_model.dart';
import '../models/rekam_medis_model.dart';

class PasienService {
  PasienService({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient.instance;

  final DioClient _dioClient;

  Future<List<PasienModel>> fetchPasienList({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.pasien,
        queryParameters: {'page': page, 'limit': limit, 'search': search},
      );

      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;

      if (data is List) {
        return data
            .map((item) => PasienModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<PasienModel> createPasien(PasienModel pasien) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.pasien,
        data: pasien.toJson(),
      );
      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      return PasienModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<PasienModel> getPasienById(int id) async {
    try {
      final response = await _dioClient.dio.get('${ApiConstants.pasien}/$id');
      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      return PasienModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<PasienModel> updatePasien(int id, Map<String, dynamic> updates) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.pasien}/$id',
        data: updates,
      );
      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      return PasienModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<PasienModel?> getPasienByNik(String nik) async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.pasienNik}/$nik',
      );
      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      if (data is Map<String, dynamic>) {
        return PasienModel.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<List<RekamMedisModel>> getRekamMedis(int pasienId) async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.pasien}/$pasienId/rekam-medis',
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

  Future<void> deletePasien(int id) async {
    try {
      await _dioClient.dio.delete('${ApiConstants.pasien}/$id');
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
