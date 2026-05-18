import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/interceptors/error_interceptor.dart';
import '../models/pembayaran_model.dart';

class PembayaranService {
  PembayaranService({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient.instance;

  final DioClient _dioClient;

  Future<PembayaranModel> createPembayaran({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.pembayaran,
        data: payload,
      );
      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      return PembayaranModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseDioException(e);
    }
  }

  Future<PembayaranModel> processPembayaran({
    required int id,
    required String paymentMethod,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.pembayaran}/$id${ApiConstants.pembayaranProcess}',
        data: {'payment_method': paymentMethod},
      );
      final data = response.data is Map<String, dynamic>
          ? response.data['data'] ?? response.data
          : response.data;
      return PembayaranModel.fromJson(data as Map<String, dynamic>);
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
