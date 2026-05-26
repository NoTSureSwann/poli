import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../features/poli/data/models/poli_model.dart';

class MockApiService {
  // Anda dapat mengganti ini dengan URL MockAPI sungguhan Anda.
  // URL dummy publik untuk referensi poli:
  final String _baseUrl = 'https://65c363dc39055e7482c0c793.mockapi.io/api/v1';

  Future<List<PoliModel>> getDaftarPoli() async {
    try {
      final url = Uri.parse('$_baseUrl/poli');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => PoliModel.fromJson(e)).toList();
      } else {
        // Fallback dummy data jika endpoint API bermasalah/dihapus
        return _getDummyData();
      }
    } catch (e) {
      debugPrint('Error fetch mock poli: $e');
      return _getDummyData();
    }
  }
  
  Future<List<Map<String, dynamic>>> getRiwayatPasien() async {
    // Dummy riwayat pasien
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        'tanggal': '2026-05-20',
        'poli': {'nama_poli': 'Poli Gigi'},
        'status': 'selesai',
        'keluhan': 'Sakit gigi geraham'
      },
      {
        'tanggal': '2026-05-30',
        'poli': {'nama_poli': 'Poli Umum'},
        'status': 'menunggu',
        'keluhan': 'Demam dan flu'
      }
    ];
  }

  List<PoliModel> _getDummyData() {
    return [
      PoliModel(id: '1', namaPoli: 'Poli Umum', deskripsi: 'Pemeriksaan kesehatan umum.', jamBuka: '08:00', jamTutup: '16:00'),
      PoliModel(id: '2', namaPoli: 'Poli Gigi', deskripsi: 'Perawatan gigi dan mulut.', jamBuka: '08:00', jamTutup: '14:00'),
      PoliModel(id: '3', namaPoli: 'Poli Anak', deskripsi: 'Kesehatan ibu dan anak.', jamBuka: '09:00', jamTutup: '15:00'),
    ];
  }
}
