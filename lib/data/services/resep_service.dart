import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/interceptors/error_interceptor.dart';
import '../models/resep_model.dart';

class ResepService {
  ResepService({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient.instance;

  final DioClient _dioClient;

  Future<List<ResepModel>> fetchResepList({
    int page = 1,
    int limit = 20,
    String status = '',
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.resep,
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
            .map((item) => ResepModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<ResepModel> createResep({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.resep,
        data: payload,
      );
      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      return ResepModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<ResepModel> prepareResep(int id) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.resep}/$id${ApiConstants.resepPrepare}',
      );
      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      return ResepModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<ResepModel> deliverResep(int id) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.resep}/$id${ApiConstants.resepDeliver}',
      );
      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      return ResepModel.fromJson(data as Map<String, dynamic>);
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
