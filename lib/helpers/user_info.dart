import 'package:shared_preferences/shared_preferences.dart';

class UserInfo {
  static String? token;
  static bool isAdmin = false;

  static Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    isAdmin = prefs.getBool('is_admin') ?? false;
  }
}
