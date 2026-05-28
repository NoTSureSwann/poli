import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static String get groqBaseUrl => dotenv.env['GROQ_BASE_URL'] ?? '';
  static String get groqModel => dotenv.env['GROQ_MODEL'] ?? '';
}
