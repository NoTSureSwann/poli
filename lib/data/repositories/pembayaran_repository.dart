import 'package:dio/dio.dart';
import '../models/struk_model.dart';
import '../../core/constants/api_constants.dart';
import '../../helpers/api_client.dart';

class PembayaranRepository {
  final Dio _dio = ApiClient.instance.dio;

  // Get all payments
  Future<List<dynamic>> getPaymentList() async {
    try {
      final response = await _dio.get(ApiConstants.adminPembayaran);

      if (response.statusCode == 200) {
        return response.data['data'] as List;
      }
      throw Exception('Failed to load pembayaran');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get payment by ID
  Future<dynamic> getPaymentById(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.adminPembayaran}/$id');

      if (response.statusCode == 200) {
        return response.data['data'];
      }
      throw Exception('Failed to load pembayaran');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Create payment
  Future<dynamic> createPayment(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiConstants.adminPembayaran,
        data: data,
      );

      if (response.statusCode == 201) {
        return response.data['data'];
      }
      throw Exception('Failed to create pembayaran');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get struk data for payment (PDF)
  Future<StrukModel> getStruk(int pembayaranId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.adminPembayaran}/$pembayaranId/struk',
      );

      if (response.statusCode == 200) {
        return StrukModel.fromJson(response.data);
      }
      throw Exception('Failed to load struk');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get struk obat (resep/medicine struk)
  Future<StrukModel> getStrukObat(int pembayaranId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.adminPembayaran}/$pembayaranId/struk-obat',
      );

      if (response.statusCode == 200) {
        return StrukModel.fromJson(response.data);
      }
      throw Exception('Failed to load struk obat');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update payment status
  Future<void> updatePaymentStatus(int id, String status) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.adminPembayaran}/$id',
        data: {'status': status},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update pembayaran');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Delete payment
  Future<void> deletePayment(int id) async {
    try {
      final response = await _dio.delete('${ApiConstants.adminPembayaran}/$id');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete pembayaran');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
