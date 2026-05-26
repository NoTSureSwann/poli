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

    final Map<String, dynamic> payload = {
      'app_source': 'Klinik App E-Prescribing (Clean Arch)',
      'pasien': request.namaPasien,
      'prompt_text': promptText,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Simulasi respons sukses jika masih menggunakan URL dummy
    if (webhookUrl.contains('12345/abcde')) {
      await Future.delayed(const Duration(seconds: 2));
      return true;
    }

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
