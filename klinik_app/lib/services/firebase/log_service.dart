import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class LogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Cache user data to minimize db reads
  String? _currentUserRole;
  
  /// Dipanggil ketika aplikasi di-resume atau user baru login
  Future<String> startSession() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return '';

    // Ambil role dari profile Supabase
    if (_currentUserRole == null) {
      try {
        final profile = await _supabase.from('profiles').select('role').eq('id', user.id).single();
        _currentUserRole = profile['role'];
      } catch (e) {
        _currentUserRole = 'unknown';
      }
    }

    // Buat dokumen log sesi baru di Firestore
    try {
      final docRef = await _firestore.collection('app_logs').add({
        'user_id': user.id,
        'role': _currentUserRole,
        'session_start': FieldValue.serverTimestamp(),
        'session_end': null,
        'duration_seconds': 0,
        'actions': ['Session started'],
      });
      return docRef.id;
    } catch (e) {
      debugPrint('Error starting log session: $e');
      return '';
    }
  }

  /// Dipanggil ketika aplikasi di-pause, ditutup, atau logout
  Future<void> endSession(String sessionId) async {
    if (sessionId.isEmpty) return;
    try {
      final docSnapshot = await _firestore.collection('app_logs').doc(sessionId).get();
      if (!docSnapshot.exists) return;

      final data = docSnapshot.data();
      if (data == null || data['session_start'] == null) return;

      final sessionStart = (data['session_start'] as Timestamp).toDate();
      final sessionEnd = DateTime.now();
      final duration = sessionEnd.difference(sessionStart).inSeconds;

      await _firestore.collection('app_logs').doc(sessionId).update({
        'session_end': FieldValue.serverTimestamp(),
        'duration_seconds': duration,
        'actions': FieldValue.arrayUnion(['Session ended']),
      });
    } catch (e) {
      debugPrint('Error ending log session: $e');
    }
  }

  /// Menambahkan spesifik action (traffic) ke dalam log sesi berjalan
  Future<void> logAction(String sessionId, String action) async {
    if (sessionId.isEmpty) return;
    try {
      final timestamp = DateTime.now().toIso8601String().substring(11, 19); // HH:mm:ss
      await _firestore.collection('app_logs').doc(sessionId).update({
        'actions': FieldValue.arrayUnion(['[$timestamp] $action']),
      });
    } catch (e) {
      debugPrint('Error logging action: $e');
    }
  }

  /// Mengambil logs untuk analisa AI (terbatas 50 logs terakhir)
  Future<List<Map<String, dynamic>>> getRecentLogsForAnalytics() async {
    try {
      final query = await _firestore
          .collection('app_logs')
          .orderBy('session_start', descending: true)
          .limit(50)
          .get();
          
      return query.docs.map((e) {
        final data = e.data();
        // Convert timestamp to readable string for AI
        if (data['session_start'] != null && data['session_start'] is Timestamp) {
          data['session_start'] = (data['session_start'] as Timestamp).toDate().toString();
        }
        if (data['session_end'] != null && data['session_end'] is Timestamp) {
          data['session_end'] = (data['session_end'] as Timestamp).toDate().toString();
        }
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error fetch logs for analytics: $e');
      return [];
    }
  }
}
