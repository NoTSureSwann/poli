import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:klinik_app/features/poli/data/models/poli_model.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  /// [SEC-05 FIX]: Helper yang memastikan user sudah login.
  /// Melempar exception jika belum terautentikasi.
  String _requireAuthUserId() {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Sesi login tidak ditemukan. Silakan login ulang.');
    }
    return userId;
  }

  Future<List<PoliModel>> getDaftarPoli() async {
    try {
      final response = await supabase.from('poli').select();
      return (response as List).map((e) => PoliModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetch poli Supabase: $e');
      return [];
    }
  }

  Future<bool> daftarAntrian(String poliId, String keluhan, String tanggal) async {
    try {
      // [SEC-05 FIX]: Wajib login, tidak ada lagi fallback ke UUID dummy.
      final userId = _requireAuthUserId();
      
      await supabase.from('antrian').insert({
        'pasien_id': userId,
        'poli_id': poliId,
        'keluhan': keluhan,
        'tanggal': tanggal,
        'status': 'menunggu'
      });
      return true;
    } catch (e) {
      debugPrint('Error daftar antrian: $e');
      return false;
    }
  }
  
  Future<List<Map<String, dynamic>>> getRiwayatPasien({int page = 0}) async {
     try {
      // [SEC-05 FIX]: Wajib login, tidak ada lagi fallback ke UUID dummy.
      final userId = _requireAuthUserId();
      final from = page * 10;
      final to = from + 9;
      
      final response = await supabase
          .from('antrian')
          .select('*, poli:poli_id(nama_poli)')
          .eq('pasien_id', userId)
          .order('tanggal', ascending: false)
          .range(from, to);
          
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetch riwayat: $e');
      return [];
    }
  }
}

