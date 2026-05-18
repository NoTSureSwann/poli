import 'package:dio/dio.dart';
import '../models/dokter_model.dart';
import '../../core/constants/api_constants.dart';
import '../../helpers/api_client.dart';

class DokterRepository {
  final Dio _dio = ApiClient.instance.dio;

  // Get all doctors
  Future<List<DokterModel>> getDokterList({String? tipe}) async {
    try {
      final params = <String, dynamic>{};
      if (tipe != null && tipe != 'semua') {
        params['tipe'] = tipe;
      }

      final response = await _dio.get(
        ApiConstants.dokter,
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final list = (response.data['data'] as List)
            .map((item) => DokterModel.fromJson(item))
            .toList();
        return list;
      }
      throw Exception('Failed to load dokter');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get doctor by ID
  Future<DokterModel> getDokterById(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.dokter}/$id');

      if (response.statusCode == 200) {
        return DokterModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to load dokter');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Create doctor (admin)
  Future<DokterModel> createDokter(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiConstants.dokter, data: data);

      if (response.statusCode == 201) {
        return DokterModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to create dokter');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update doctor (admin)
  Future<void> updateDokter(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('${ApiConstants.dokter}/$id', data: data);

      if (response.statusCode != 200) {
        throw Exception('Failed to update dokter');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Delete doctor (admin)
  Future<void> deleteDokter(int id) async {
    try {
      final response = await _dio.delete('${ApiConstants.dokter}/$id');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete dokter');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get doctors by poli
  Future<List<DokterModel>> getDokterByPoli(int poliId) async {
    try {
      final response = await _dio.get('${ApiConstants.dokter}/poli/$poliId');

      if (response.statusCode == 200) {
        final list = (response.data['data'] as List)
            .map((item) => DokterModel.fromJson(item))
            .toList();
        return list;
      }
      throw Exception('Failed to load dokter');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
