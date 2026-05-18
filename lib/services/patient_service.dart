import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/patient.dart';
import 'api_config_service.dart';

class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool hasMore;

  PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.hasMore,
  });
}

class PatientService {
  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    String? token;

    if (userJson != null) {
      try {
        token = jsonDecode(userJson)['token']?.toString();
      } catch (_) {
        token = null;
      }
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<PaginatedResult<Patient>> getPatients({
    int page = 1,
    int limit = 20,
    String? searchQuery,
  }) async {
    try {
      final response = await http.get(
        ApiConfigService.apiUri(
          '/patients',
          queryParameters: {
            'page': page,
            'limit': limit,
            if (searchQuery != null && searchQuery.isNotEmpty)
              'search': searchQuery,
          },
        ),
        headers: await _headers(),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal memuat list pasien (Status: ${response.statusCode}). ${response.body}',
        );
      }

      final data = jsonDecode(response.body);
      final itemsJson = (data['data'] as List?) ?? <dynamic>[];
      final pagination = data['pagination'] as Map<String, dynamic>?;
      final total = (pagination?['total'] as num?)?.toInt() ?? itemsJson.length;
      final hasNext = pagination?['hasNext'] as bool? ?? (page * limit < total);

      final items = itemsJson
          .map((json) => Patient.fromJson(json as Map<String, dynamic>))
          .toList();

      return PaginatedResult(
        items: items,
        totalCount: total,
        currentPage: page,
        pageSize: limit,
        hasMore: hasNext,
      );
    } catch (e) {
      throw Exception(
        'Koneksi Error (${ApiConfigService.apiBaseUrl}/patients): $e',
      );
    }
  }

  Future<Patient?> getPatientById(String id) async {
    try {
      final response = await http.get(
        ApiConfigService.apiUri('/patients/$id'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final patientData = data['data'] ?? data;
        return Patient.fromJson(patientData as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Koneksi memuat profil error: $e');
    }
  }

  Future<Patient> createPatient(Patient patient) async {
    try {
      final response = await http.post(
        ApiConfigService.apiUri('/patients'),
        headers: await _headers(),
        body: jsonEncode(patient.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final patientData = data['data'] ?? data;
        return Patient.fromJson(patientData as Map<String, dynamic>);
      }
      throw Exception(
        'Gagal menyimpan pasien baru. (Status: ${response.statusCode})',
      );
    } catch (e) {
      throw Exception('Koneksi jaringan error saat menambah pasien: $e');
    }
  }

  Future<Patient> updatePatient(String id, Patient patient) async {
    try {
      final response = await http.put(
        ApiConfigService.apiUri('/patients/$id'),
        headers: await _headers(),
        body: jsonEncode(patient.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final patientData = data['data'] ?? data;
        return Patient.fromJson(patientData as Map<String, dynamic>);
      }
      throw Exception(
        'Gagal memperbarui data pasien. (Status: ${response.statusCode})',
      );
    } catch (e) {
      throw Exception('Koneksi server gagal saat update: $e');
    }
  }

  Future<bool> deletePatient(String id) async {
    try {
      final response = await http.delete(
        ApiConfigService.apiUri('/patients/$id'),
        headers: await _headers(),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Gagal terhubung saat menghapus: $e');
    }
  }

  Future<int> getTotalPatientCount() async {
    try {
      final result = await getPatients(limit: 1);
      return result.totalCount;
    } catch (_) {
      return 0;
    }
  }
}
