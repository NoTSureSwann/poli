import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? 'gsk_placeholder_key_here';
  static String get groqBaseUrl => dotenv.env['GROQ_BASE_URL'] ?? 'https://api.groq.com/openai/v1';
  static String get groqModel => dotenv.env['GROQ_MODEL'] ?? 'llama-3.3-70b-versatile';
}
