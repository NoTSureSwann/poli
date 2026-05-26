import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/poli/data/models/poli_model.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

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
      final userId = supabase.auth.currentUser?.id;
      // Jika belum login, kita mock userId untuk sementara agar UI tidak error.
      final safeUserId = userId ?? '00000000-0000-0000-0000-000000000000';
      
      await supabase.from('antrian').insert({
        'pasien_id': safeUserId,
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
  
  Future<List<Map<String, dynamic>>> getRiwayatPasien() async {
     try {
      final userId = supabase.auth.currentUser?.id;
      final safeUserId = userId ?? '00000000-0000-0000-0000-000000000000';
      
      final response = await supabase
          .from('antrian')
          .select('*, poli:poli_id(nama_poli)')
          .eq('pasien_id', safeUserId);
          
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetch riwayat: $e');
      return [];
    }
  }
}
