import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../models/stok_obat.dart';

class StokObatService {
  final Dio _dio = DioClient.instance.dio;

  Future<List<StokObat>> getAllStokObat({bool? lowStockOnly}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (lowStockOnly == true) {
        queryParams['low_stock'] = 'true';
      }

      final response = await _dio.get(
        '/stok-obat',
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is List) {
        return data.map((json) => StokObat.fromJson(json)).toList();
      } else if (data['data'] is List) {
        return (data['data'] as List)
            .map((json) => StokObat.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(
        e.error?.toString() ?? 'Gagal mendapatkan data stok obat',
      );
    }
  }

  Future<StokObat> getStokObatById(String id) async {
    try {
      final response = await _dio.get('/stok-obat/$id');
      return StokObat.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.error?.toString() ?? 'Gagal mendapatkan data stok obat',
      );
    }
  }

  Future<StokObat> createStokObat({
    required String namaObat,
    required String deskripsi,
    required int stok,
    required int minimumStok,
    required String satuan,
    required DateTime tanggalKadaluarsa,
    String? lokasiPenyimpanan,
  }) async {
    try {
      final response = await _dio.post(
        '/stok-obat',
        data: {
          'nama_obat': namaObat,
          'deskripsi': deskripsi,
          'stok': stok,
          'minimum_stok': minimumStok,
          'satuan': satuan,
          'tanggal_kadaluarsa': tanggalKadaluarsa.toIso8601String(),
          'lokasi_penyimpanan': lokasiPenyimpanan,
        },
      );

      return StokObat.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal membuat data stok obat');
    }
  }

  Future<StokObat> updateStokObat({
    required String id,
    required String namaObat,
    required String deskripsi,
    required int stok,
    required int minimumStok,
    required String satuan,
    required DateTime tanggalKadaluarsa,
    String? lokasiPenyimpanan,
  }) async {
    try {
      final response = await _dio.put(
        '/stok-obat/$id',
        data: {
          'nama_obat': namaObat,
          'deskripsi': deskripsi,
          'stok': stok,
          'minimum_stok': minimumStok,
          'satuan': satuan,
          'tanggal_kadaluarsa': tanggalKadaluarsa.toIso8601String(),
          'lokasi_penyimpanan': lokasiPenyimpanan,
        },
      );

      return StokObat.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal mengupdate data stok obat');
    }
  }

  Future<StokObat> tambahStok({
    required String id,
    required int jumlahTambah,
  }) async {
    try {
      final response = await _dio.put(
        '/stok-obat/$id/tambah',
        data: {'jumlah': jumlahTambah},
      );

      return StokObat.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal menambah stok obat');
    }
  }

  Future<void> deleteStokObat(String id) async {
    try {
      await _dio.delete('/stok-obat/$id');
    } on DioException catch (e) {
      throw Exception(e.error?.toString() ?? 'Gagal menghapus data stok obat');
    }
  }
}
