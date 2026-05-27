import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:klinik_app/features/poli/data/models/poli_model.dart';

/// Service layer untuk interaksi real-time dengan Cloud Firestore.
/// Menyediakan Stream-based API untuk data poli, antrian, dan riwayat kunjungan.
class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── POLI ────────────────────────────────────────────────

  /// Stream daftar poli secara real-time.
  Stream<List<PoliModel>> getPoliStream() {
    return _db.collection('poli').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PoliModel.fromJson(data);
      }).toList();
    });
  }

  /// Validasi apakah poli dengan [poliId] ada dan aktif di database.
  Future<bool> validatePoli(String poliId) async {
    try {
      final doc = await _db.collection('poli').doc(poliId).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error validasi poli: $e');
      return false;
    }
  }

  /// Tambah poli baru ke Firestore (admin).
  Future<void> tambahPoli(PoliModel poli) async {
    await _db.collection('poli').add({
      'nama_poli': poli.namaPoli,
      'deskripsi': poli.deskripsi,
      'jam_buka': poli.jamBuka,
      'jam_tutup': poli.jamTutup,
      'icon': poli.icon,
    });
  }

  // ─── ANTRIAN ─────────────────────────────────────────────

  /// Validasi ketersediaan slot antrian pada [poliId] dan [tanggal].
  /// Mengembalikan `true` jika slot masih tersedia (< 50 antrian per poli per hari).
  Future<bool> validateAntrianSlot(String poliId, String tanggal) async {
    try {
      final query = await _db
          .collection('antrian')
          .where('poli_id', isEqualTo: poliId)
          .where('tanggal', isEqualTo: tanggal)
          .where('status', isNotEqualTo: 'batal')
          .get();
      return query.docs.length < 50; // Maks 50 antrian per poli per hari
    } catch (e) {
      debugPrint('Error validasi slot: $e');
      return false; // [SEC-18 FIX]: Fail-closed — tolak jika tidak bisa verifikasi
    }
  }

  /// Daftarkan antrian baru ke Firestore setelah validasi.
  /// Mengembalikan nomor antrian yang diberikan atau -1 jika gagal.
  Future<int> daftarAntrian({
    required String pasienId,
    required String poliId,
    required String keluhan,
    required String tanggal,
  }) async {
    try {
      // 1. Validasi poli
      final poliValid = await validatePoli(poliId);
      if (!poliValid) {
        debugPrint('Poli tidak valid: $poliId');
        return -1;
      }

      // 2. Validasi slot
      final slotAvailable = await validateAntrianSlot(poliId, tanggal);
      if (!slotAvailable) {
        debugPrint('Slot antrian penuh untuk tanggal: $tanggal');
        return -1;
      }

      // 3. Hitung nomor antrian berikutnya
      final existing = await _db
          .collection('antrian')
          .where('poli_id', isEqualTo: poliId)
          .where('tanggal', isEqualTo: tanggal)
          .get();
      final nomorAntrian = existing.docs.length + 1;

      // 4. Insert antrian
      await _db.collection('antrian').add({
        'pasien_id': pasienId,
        'poli_id': poliId,
        'keluhan': keluhan,
        'tanggal': tanggal,
        'nomor_antrian': nomorAntrian,
        'status': 'menunggu',
        'created_at': FieldValue.serverTimestamp(),
      });

      return nomorAntrian;
    } catch (e) {
      debugPrint('Error daftar antrian Firebase: $e');
      return -1;
    }
  }

  /// Stream antrian aktif (hari ini) untuk sebuah poli, diurutkan nomor antrian.
  Stream<List<Map<String, dynamic>>> getAntrianStream(String poliId, String tanggal) {
    return _db
        .collection('antrian')
        .where('poli_id', isEqualTo: poliId)
        .where('tanggal', isEqualTo: tanggal)
        .orderBy('nomor_antrian')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Stream antrian milik satu pasien.
  Stream<List<Map<String, dynamic>>> getAntrianPasienStream(String pasienId) {
    return _db
        .collection('antrian')
        .where('pasien_id', isEqualTo: pasienId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // ─── RIWAYAT ─────────────────────────────────────────────

  /// Stream riwayat kunjungan pasien (semua antrian selesai/batal).
  Stream<List<Map<String, dynamic>>> getRiwayatStream(String pasienId) {
    return _db
        .collection('antrian')
        .where('pasien_id', isEqualTo: pasienId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Update status antrian (untuk admin: menunggu → dilayani → selesai).
  Future<void> updateStatusAntrian(String antrianId, String statusBaru) async {
    await _db.collection('antrian').doc(antrianId).update({
      'status': statusBaru,
    });
  }

  // ─── SEED DATA (untuk demo) ──────────────────────────────

  /// Seed data poli awal ke Firestore jika collection kosong.
  Future<void> seedPoliData() async {
    final existing = await _db.collection('poli').get();
    if (existing.docs.isNotEmpty) return; // Sudah ada data

    final seedPoli = [
      {'nama_poli': 'Poli Umum', 'kategori': 'Umum', 'deskripsi': 'Pemeriksaan kesehatan umum.', 'jam_buka': '08:00', 'jam_tutup': '16:00', 'icon': 'local_hospital'},
      {'nama_poli': 'Poli Gigi & Mulut', 'kategori': 'Gigi', 'deskripsi': 'Perawatan gigi dan mulut.', 'jam_buka': '08:00', 'jam_tutup': '14:00', 'icon': 'mood'},
      {'nama_poli': 'Poli Bedah Mulut', 'kategori': 'Gigi', 'deskripsi': 'Operasi dan bedah rahang mulut.', 'jam_buka': '10:00', 'jam_tutup': '15:00', 'icon': 'healing'},
      {'nama_poli': 'Poli Tumbuh Kembang', 'kategori': 'Anak', 'deskripsi': 'Pemantauan tumbuh kembang anak.', 'jam_buka': '09:00', 'jam_tutup': '15:00', 'icon': 'child_care'},
      {'nama_poli': 'Poli Pediatri', 'kategori': 'Anak', 'deskripsi': 'Pemeriksaan penyakit pada anak.', 'jam_buka': '08:00', 'jam_tutup': '16:00', 'icon': 'face'},
      {'nama_poli': 'Poli Kandungan (Obgyn)', 'kategori': 'Kandungan', 'deskripsi': 'Kesehatan ibu hamil dan kandungan.', 'jam_buka': '08:00', 'jam_tutup': '14:00', 'icon': 'pregnant_woman'},
      {'nama_poli': 'Poli Mata', 'kategori': 'Spesialis', 'deskripsi': 'Gangguan penglihatan dan mata.', 'jam_buka': '09:00', 'jam_tutup': '15:00', 'icon': 'visibility'},
      {'nama_poli': 'Poli THT', 'kategori': 'Spesialis', 'deskripsi': 'Telinga, hidung, dan tenggorokan.', 'jam_buka': '08:00', 'jam_tutup': '14:00', 'icon': 'hearing'},
      {'nama_poli': 'Poli Penyakit Dalam', 'kategori': 'Spesialis', 'deskripsi': 'Pemeriksaan organ dalam.', 'jam_buka': '08:00', 'jam_tutup': '16:00', 'icon': 'favorite'},
    ];

    for (final poli in seedPoli) {
      await _db.collection('poli').add(poli);
    }
    debugPrint('Seed data poli berhasil ditambahkan.');
  }
}
