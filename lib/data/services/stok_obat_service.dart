import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/interceptors/error_interceptor.dart';
import '../models/stok_obat_model.dart';

class StokObatService {
  StokObatService({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient.instance;

  final DioClient _dioClient;

  Future<List<StokObatModel>> fetchStokObat({
    int page = 1,
    int limit = 20,
    bool lowStockOnly = false,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.stokObat,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (lowStockOnly) 'low_stock': true,
        },
      );

      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      if (data is List) {
        return data
            .map((item) => StokObatModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<StokObatModel> createStokObat({
    required StokObatModel stokObat,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.stokObat,
        data: stokObat.toJson(),
      );
      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      return StokObatModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<StokObatModel> addStock({
    required int id,
    required int quantity,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '${ApiConstants.stokObat}/$id/tambah',
        data: {'quantity': quantity},
      );
      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      return StokObatModel.fromJson(data as Map<String, dynamic>);
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
