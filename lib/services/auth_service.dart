import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      try {
        _currentUser = User.fromJson(jsonDecode(userJson));
      } catch (e) {
        debugPrint('Error parsing user data: $e');
      }
    }
  }

  Future<bool> login(String email, String password, UserRole role) async {
    // Simulasi HTTP Login Request
    await Future.delayed(const Duration(seconds: 1));
    
    // Hardcoded logic untuk saat ini, sesuai kebutuhan mockup
    if (password == '123456') { // Mock authentication
      _currentUser = User(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: role == UserRole.admin ? 'Administrator' : 'Pasien',
        email: email,
        role: role,
      );
      await _saveUserSession();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password, UserRole role) async {
    // Simulasi pendaftaran HTTP request 
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUser = User(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: role,
    );
    await _saveUserSession();
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    notifyListeners();
  }

  Future<void> _saveUserSession() async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));
  }
}
