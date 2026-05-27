import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/automation_request.dart';

abstract class AutomationRemoteDataSource {
  Future<bool> sendPrompt(AutomationRequest request);
}

class AutomationRemoteDataSourceImpl implements AutomationRemoteDataSource {
  static const String webhookUrl = 'https://hooks.zapier.com/hooks/catch/12345/abcde/';

  @override
  Future<bool> sendPrompt(AutomationRequest request) async {
    final String promptText = '''
Buatkan ringkasan diagnosa awal dan rekomendasi pengobatan untuk pasien berikut:
Nama Pasien: ${request.namaPasien}
Keluhan: ${request.keluhan}
Catatan Tambahan Dokter: ${request.catatanDokter}
    ''';

    // [PENJELASAN]: Membuat struktur data JSON (Payload) yang akan dikirim ke Zapier/n8n.
    // Struktur ini disesuaikan dengan apa yang dibutuhkan oleh webhook penerima.
    final Map<String, dynamic> payload = {
      'app_source': 'Klinik App E-Prescribing (Clean Arch)',
      'pasien': request.namaPasien,
      'prompt_text': promptText,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // [PERUBAHAN/PENAMBAHAN]: Fitur Mock/Simulasi (Bypass)
    // Jika URL Webhook masih berupa URL Dummy (belum diatur URL Zapier/n8n aslinya),
    // aplikasi akan memalsukan (mock) proses pengiriman agar tidak terjadi Error 404/403.
    // Simulasi respons sukses diberikan setelah menunda (delay) selama 2 detik untuk efek loading di UI.
    if (webhookUrl.contains('12345/abcde')) {
      await Future.delayed(const Duration(seconds: 2));
      return true;
    }

    // [PENJELASAN]: Mengirimkan request HTTP POST yang sesungguhnya ke URL Webhook.
    // Menggunakan library 'http' dan mengkonversi Map payload ke format JSON.
    final response = await http.post(
      Uri.parse(webhookUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Gagal mengirim ke Webhook. Status: ${response.statusCode}');
    }
  }
}
