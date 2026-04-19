import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/patient.dart';

/// Paginated result wrapper for list data
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

/// Service providing patient data using external Database API endpoints (Postman)
class PatientService {
  /// Base URL API dari environment file (.env)
  String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';

  /// Standard Headers untuk JSON requests
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // Jika endpoint Anda butuh otentikasi (Token JWT dsb), formatnya bisa di-uncomment:
        // 'Authorization': 'Bearer ${dotenv.env['JWT_SECRET'] ?? ''}',
      };

  /// Get paginated patients list (READ)
  Future<PaginatedResult<Patient>> getPatients({
    int page = 1,
    int limit = 20,
    String? searchQuery,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/patients').replace(queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery,
      });

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Peringatan: Akses data disesuaikan dengan asumsi stardard umum Postman yaitu => { "data": [...], "total": 100 }
        // Mohon edit block di bawah ini jika format response API Postman Anda tidak terbungkus key "data"
        List<dynamic> itemsJson = data['data'] ?? data; 
        int total = data['total'] ?? itemsJson.length;

        List<Patient> items = itemsJson.map((json) => Patient.fromJson(json)).toList();

        return PaginatedResult(
          items: items,
          totalCount: total,
          currentPage: page,
          pageSize: limit,
          hasMore: (page * limit) < total,
        );
      } else {
        throw Exception('Gagal memuat list pasien (Status: ${response.statusCode}). Detail: ${response.body}');
      }
    } catch (e) {
      throw Exception('Koneksi Error ($baseUrl/patients): $e');
    }
  }

  /// Get single patient by ID (READ SINGLE)
  Future<Patient?> getPatientById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/patients/$id'), headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final patientData = data['data'] ?? data;
        return Patient.fromJson(patientData);
      }
      return null;
    } catch (e) {
      throw Exception('Koneksi memuat profil error: $e');
    }
  }

  /// Create a new patient (CREATE)
  Future<Patient> createPatient(Patient patient) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/patients'),
        headers: _headers,
        body: jsonEncode(patient.toJson()),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final patientData = data['data'] ?? data;
        return Patient.fromJson(patientData);
      } else {
        throw Exception('Gagal menyimpan pasien baru. (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Koneksi jaringan error saat menambah pasien: $e');
    }
  }

  /// Update an existing patient (UPDATE)
  Future<Patient> updatePatient(String id, Patient patient) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/patients/$id'),
        headers: _headers,
        body: jsonEncode(patient.toJson()),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final patientData = data['data'] ?? data;
        return Patient.fromJson(patientData);
      } else {
        throw Exception('Gagal memperbarui data pasien. (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Koneksi server gagal saat update: $e');
    }
  }

  /// Delete a patient (DELETE)
  Future<bool> deletePatient(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/patients/$id'), headers: _headers);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Gagal terhubung saat menghapus: $e');
    }
  }

  /// Get total patient count
  Future<int> getTotalPatientCount() async {
     try {
       // Melakukan request 1 pasien saja demi mengambil angka "totalCount" dari API
       final result = await getPatients(limit: 1);
       return result.totalCount;
     } catch (_) {
       return 0;
     }
  }
}
