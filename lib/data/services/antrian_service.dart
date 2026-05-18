import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/interceptors/error_interceptor.dart';
import '../models/antrian_model.dart';

class AntrianService {
  AntrianService({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient.instance;

  final DioClient _dioClient;

  Future<List<AntrianModel>> fetchAntrianList({
    int page = 1,
    int limit = 20,
    String status = '',
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.antrian,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status.isNotEmpty) 'status': status,
        },
      );

      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      if (data is List) {
        return data
            .map((item) => AntrianModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<AntrianModel> createAntrian({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.antrian,
        data: payload,
      );
      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      return AntrianModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<AntrianModel?> getNextAntrian(String poli) async {
    try {
      final response = await _dioClient.dio.get(
        '${ApiConstants.antrian}${ApiConstants.antrianNext}/$poli',
      );
      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      if (data is Map<String, dynamic>) {
        return AntrianModel.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<AntrianModel> callAntrian(int id) async {
    try {
      final response = await _dioClient.dio.post(
        '${ApiConstants.antrian}/$id${ApiConstants.antrianCall}',
      );
      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      return AntrianModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<AntrianModel> updateStatus(int id, String status) async {
    try {
      final response = await _dioClient.dio.patch(
        '${ApiConstants.antrian}/$id',
        data: {'status': status},
      );
      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      return AntrianModel.fromJson(data as Map<String, dynamic>);
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
