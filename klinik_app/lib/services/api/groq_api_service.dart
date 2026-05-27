import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:klinik_app/core/config/app_config.dart';

class GroqApiService {
  final Dio _dio;

  GroqApiService() : _dio = Dio(BaseOptions(
    baseUrl: AppConfig.groqBaseUrl,
    headers: {
      'Authorization': 'Bearer ${AppConfig.groqApiKey}',
      'Content-Type': 'application/json',
    },
  ));

  /// Send message and get full response
  Future<String> sendMessage(List<Map<String, String>> messages) async {
    try {
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': AppConfig.groqModel,
          'messages': messages,
          'temperature': 0.7,
          'max_completion_tokens': 1024,
          'top_p': 1,
          'stream': false,
        },
      );

      if (response.statusCode == 200) {
        return response.data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to get AI response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Groq API Error: $e');
    }
  }

  /// Send message and get streaming response using stream
  Stream<String> streamMessage(List<Map<String, String>> messages) async* {
    try {
      final response = await _dio.post(
        '/chat/completions',
        data: jsonEncode({
          'model': AppConfig.groqModel,
          'messages': messages,
          'temperature': 0.7,
          'max_completion_tokens': 1024,
          'top_p': 1,
          'stream': true,
        }),
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data.stream as Stream<List<int>>;
      
      await for (final chunk in stream) {
        final chunkString = utf8.decode(chunk);
        final lines = chunkString.split('\n');
        
        for (final line in lines) {
          if (line.startsWith('data: ') && line != 'data: [DONE]') {
            final dataStr = line.substring(6);
            try {
              final data = jsonDecode(dataStr);
              if (data['choices'] != null && data['choices'].isNotEmpty) {
                final delta = data['choices'][0]['delta'];
                if (delta['content'] != null) {
                  yield delta['content'];
                }
              }
            } catch (_) {
              // Ignore partial JSON parse errors in chunks
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Groq Stream API Error: $e');
    }
  }
}
