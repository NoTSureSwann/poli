import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../helpers/api_client.dart';

class LayananRepository {
  final Dio _dio = ApiClient.instance.dio;

  /// GET /api/layanan (public)
  /// Backend response includes:
  /// {
  ///   success: true,
  ///   data: [...],
  ///   grouped: {...}
  /// }
  Future<List<Map<String, dynamic>>> getAllLayanan() async {
    final response = await _dio.get(ApiConstants.layanan);

    if (response.statusCode == 200) {
      final list = (response.data['data'] as List?) ?? [];
      return list.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to load layanan');
  }

  /// GET /api/layanan grouped by kategori (if backend supports grouped)
  Future<Map<String, List<Map<String, dynamic>>>> getGroupedLayanan() async {
    final response = await _dio.get(ApiConstants.layanan);

    if (response.statusCode == 200) {
      final groupedRaw = response.data['grouped'] as Map<String, dynamic>?;

      if (groupedRaw == null) {
        final all = await getAllLayanan();
        final grouped = <String, List<Map<String, dynamic>>>{};
        for (final item in all) {
          final kategori = (item['kategori'] ?? 'lainnya').toString();
          grouped
              .putIfAbsent(kategori, () => <Map<String, dynamic>>[])
              .add(item);
        }
        return grouped;
      }

      final grouped = <String, List<Map<String, dynamic>>>{};
      for (final entry in groupedRaw.entries) {
        final items = (entry.value as List?) ?? [];
        grouped[entry.key] = items.cast<Map<String, dynamic>>();
      }
      return grouped;
    }

    throw Exception('Failed to load grouped layanan');
  }
}
