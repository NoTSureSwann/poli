import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat_message_model.dart';
import 'api_config_service.dart';

class ChatbotService {
  Future<Map<String, dynamic>> sendMessage({
    required int userId,
    required String message,
    String? sessionId,
    String? model,
  }) async {
    try {
      final response = await http
          .post(
            ApiConfigService.apiUri('/chatbot/send'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': userId,
              'message': message,
              'sessionId': sessionId,
              if (model != null && model.isNotEmpty) 'model': model,
            }),
          )
          .timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to send message: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  Future<List<ChatMessage>> getChatHistory(
    int userId, {
    String? sessionId,
  }) async {
    try {
      final response = await http
          .get(
            ApiConfigService.apiUri(
              '/chatbot/history/$userId',
              queryParameters: sessionId != null
                  ? {'sessionId': sessionId}
                  : null,
            ),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data =
            jsonDecode(response.body)['data'] as List<dynamic>;
        return data
            .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch chat history: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching chat history: $e');
    }
  }

  Future<void> clearChatHistory(int userId, {String? sessionId}) async {
    try {
      final response = await http
          .delete(
            ApiConfigService.apiUri(
              '/chatbot/clear/$userId',
              queryParameters: sessionId != null
                  ? {'sessionId': sessionId}
                  : null,
            ),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to clear chat history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error clearing chat history: $e');
    }
  }

  Future<List<LLMModel>> getAvailableModels() async {
    try {
      final response = await http
          .get(ApiConfigService.apiUri('/chatbot/models'))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        if (data is Map && data['models'] is List) {
          return List<LLMModel>.from(
            (data['models'] as List).map(
              (m) => LLMModel.fromJson(m as Map<String, dynamic>),
            ),
          );
        }
        return [];
      }
      throw Exception('Failed to fetch models: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching models: $e');
    }
  }

  Future<Map<String, dynamic>> getServiceStatus() async {
    try {
      final response = await http
          .get(ApiConfigService.apiUri('/chatbot/status'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'] as Map<String, dynamic>;
      }
      return {'available': false, 'provider': 'Unknown', 'defaultModel': ''};
    } catch (_) {
      return {'available': false, 'provider': 'Unknown', 'defaultModel': ''};
    }
  }
}
