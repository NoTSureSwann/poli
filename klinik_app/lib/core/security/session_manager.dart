import 'dart:async';
import 'package:flutter/material.dart';
import '../storage/token_storage_service.dart';
import '../../core/providers/auth_provider.dart';

class SessionManager {
  final TokenStorageService _storage = TokenStorageService();
  final AuthNotifier _authNotifier;
  
  static const int sessionTimeoutMinutes = 15;
  Timer? _sessionTimer;

  SessionManager(this._authNotifier);

  void startSession() {
    _resetTimer();
  }

  void userInteracted() {
    _resetTimer();
  }

  void _resetTimer() {
    _sessionTimer?.cancel();
    _storage.saveLastActive(DateTime.now());

    _sessionTimer = Timer(const Duration(minutes: sessionTimeoutMinutes), () {
      _handleTimeout();
    });
  }

  Future<void> _handleTimeout() async {
    final lastActive = await _storage.getLastActive();
    if (lastActive != null) {
      final difference = DateTime.now().difference(lastActive).inMinutes;
      if (difference >= sessionTimeoutMinutes) {
        debugPrint('🔒 [Session Timeout] User has been inactive for $sessionTimeoutMinutes minutes. Logging out.');
        await _authNotifier.signOut();
        _sessionTimer?.cancel();
      }
    }
  }

  void stopSession() {
    _sessionTimer?.cancel();
  }
}
