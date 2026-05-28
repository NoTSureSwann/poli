
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SecureGroqService {
  final Dio _dio;
  final List<DateTime> _requestTimestamps = [];

  SecureGroqService()
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://api.groq.com/openai/v1',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Authorization': 'Bearer ${dotenv.env['GROQ_API_KEY']}',
            'Content-Type': 'application/json',
          },
        ));

  /// 1. PROMPT INJECTION PREVENTION
  String sanitizePrompt(String input) {
    if (input.isEmpty) return '';

    String sanitized = input;

    // Hapus karakter berbahaya
    final blockList = [
      'ignore previous',
      'disregard',
      'forget',
      'system:',
      '[INST]'
    ];
    for (final word in blockList) {
      sanitized = sanitized.replaceAll(RegExp(word, caseSensitive: false), '');
    }

    // Strip HTML and script tags
    sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>'), '');

    // Batasi panjang maksimal 500 karakter
    if (sanitized.length > 500) {
      sanitized = sanitized.substring(0, 500);
    }

    return sanitized.trim();
  }

  /// 2. RATE LIMITER
  bool isRateLimited() {
    final now = DateTime.now();
    // Remove timestamps older than 1 minute
    _requestTimestamps.removeWhere((timestamp) => now.difference(timestamp).inMinutes >= 1);

    if (_requestTimestamps.length >= 5) {
      return true;
    }
    _requestTimestamps.add(now);
    return false;
  }

  /// 3. SECURE API CALL
  Future<String> sendMessage(String prompt) async {
    if (isRateLimited()) {
      return "Terlalu banyak pertanyaan, tunggu sebentar";
    }

    final sanitizedPrompt = sanitizePrompt(prompt);
    if (sanitizedPrompt.isEmpty) return "Pesan tidak boleh kosong.";

    try {
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': 'llama3-8b-8192',
          'messages': [
            {'role': 'user', 'content': sanitizedPrompt}
          ],
        },
      );

      final content = response.data['choices'][0]['message']['content']?.toString() ?? '';
      return _validateResponse(content);

    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('Groq API Error: ${e.message}');
      }
      
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        return "Maaf, AI sedang sibuk. Coba lagi.";
      }
      if (e.response?.statusCode == 429) {
        return "Batas request tercapai.";
      }
      return "Layanan AI tidak tersedia.";
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Unknown Error: $e');
      }
      return "Layanan AI tidak tersedia.";
    }
  }

  /// 4. RESPONSE VALIDATION
  String _validateResponse(String response) {
    if (response.isEmpty) return "Tidak ada balasan dari AI.";

    String validated = response;

    // Batasi response maksimal 500 karakter
    if (validated.length > 500) {
      validated = '${validated.substring(0, 500)}...';
    }

    // Filter kata-kata medis berbahaya
    final medicalBlockList = [
      'diagnosa pasti',
      'resep obat',
      'anda menderita',
      'saya meresepkan'
    ];
    
    for (final word in medicalBlockList) {
      if (validated.toLowerCase().contains(word)) {
        return "Maaf, AI tidak dapat memberikan diagnosa pasti atau resep obat. Silakan konsultasi dengan dokter.";
      }
    }

    return validated;
  }
}
