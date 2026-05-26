import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  // SILAKAN GANTI DENGAN API KEY ASLI ANDA
  static const _apiKey = 'API_KEY_GEMINI_ANDA';
  
  static const _systemPrompt = '''
Kamu adalah asisten virtual Klinik Sehat.
Bantu pasien dengan informasi poli, cara daftar, dan saran umum kesehatan.
Jangan berikan diagnosa medis. Jawab dalam Bahasa Indonesia yang ramah.
Batasi jawaban maksimal 150 kata untuk hemat token.
''';

  Future<String> chatKlinik(String pesanPasien) async {
    if (_apiKey == 'API_KEY_GEMINI_ANDA') {
      // Mengembalikan response dummy jika key belum diganti untuk mencegah crash
      await Future.delayed(const Duration(seconds: 1));
      return "Halo! Saat ini AI sedang dalam mode demonstrasi karena API Key belum diatur. Untuk keluhan Anda, disarankan mengunjungi Poli Umum.";
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(_systemPrompt),
    );

    try {
      final response = await model.generateContent([Content.text(pesanPasien)]);
      return response.text ?? "Maaf, saya tidak mengerti.";
    } catch (e) {
      return "Error: Layanan AI sementara tidak tersedia. (${e.toString()})";
    }
  }
}
