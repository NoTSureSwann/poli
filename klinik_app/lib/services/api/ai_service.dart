import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// ─── Model: satu sesi percakapan + skor reward ───────────────────────────────

class RlhfSession {
  double rewardScore; // 0–100, mulai dari 50 (netral)
  int totalLikes;
  int totalDislikes;
  final List<Map<String, String>> conversationHistory;
  final String sessionId;

  RlhfSession({required this.sessionId})
    : rewardScore = 50.0,
      totalLikes = 0,
      totalDislikes = 0,
      conversationHistory = [];

  // Rekam feedback → update skor secara realtime
  void applyLike() {
    rewardScore = (rewardScore + 0.857).clamp(0, 100);
    totalLikes++;
  }

  void applyDislike() {
    rewardScore = (rewardScore - 0.341).clamp(0, 100);
    totalDislikes++;
  }

  // Tier perilaku berdasarkan skor
  String get behaviorTier {
    if (rewardScore >= 70) return 'confident';
    if (rewardScore >= 40) return 'balanced';
    return 'cautious';
  }

  // Suhu model menyesuaikan tier
  double get modelTemperature {
    switch (behaviorTier) {
      case 'confident':
        return 0.6; // lebih ringkas & tegas
      case 'cautious':
        return 0.4; // lebih konservatif
      default:
        return 0.7; // normal
    }
  }
}

// ─── AI Service dengan RLHF ──────────────────────────────────────────────────

class AiService {
  static const _apiKey =
      'gsk_placeholder_key_here';
  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── System Prompt Dasar ───────────────────────────────────────────────────

  static const _baseSystemPrompt = '''
## IDENTITAS
Kamu adalah "Sena", asisten virtual kesehatan Klinik Sehat yang ramah, empatik, dan profesional.
Kamu berbicara seperti seorang perawat yang hangat — tidak kaku, tidak terlalu formal, tapi tetap terpercaya.

## KEPRIBADIAN & GAYA BICARA
- Selalu sapa pasien dengan hangat dan gunakan "Anda".
- Gunakan bahasa yang mudah dipahami, hindari istilah medis tanpa penjelasan.
- Tunjukkan empati saat pasien menyampaikan keluhan.
- Gunakan emoji secukupnya (✅ ❤️ 🏥 💊).

## KEMAMPUAN UTAMA
1. Triage Awal: tanyakan keluhan (lokasi, durasi, skala 1–10).
2. Rekomendasi Poli: Umum, Gigi, Anak, Kandungan, Mata, IGD.
3. Panduan Pendaftaran: cara daftar, jam operasional, dokumen.
4. Saran Kesehatan Umum: tips pencegahan, pertolongan pertama ringan.
5. Tindak Lanjut: SELALU tanya apakah pasien ingin informasi lebih lanjut.

## ALUR TRIAGE INTERAKTIF
Jika pasien menyebut keluhan fisik:
1. Tanya durasi keluhan.
2. Tanya skala 1–10.
3. Tanya gejala penyerta.
4. Baru berikan rekomendasi.

## BATASAN PENTING
- ❌ Jangan berikan diagnosis medis spesifik.
- ❌ Jangan resepkan obat dengan dosis tertentu.
- ✅ Selalu sarankan konsultasi dokter untuk keluhan serius.
- ⚠️ Darurat (nyeri dada, sesak, pingsan, perdarahan): langsung arahkan ke IGD.

## FORMAT DARURAT
"⚠️ Kondisi ini DARURAT. Segera ke IGD Klinik Sehat atau hubungi 119!"
''';

  // ── Instruksi Adaptif berdasarkan Tier RLHF ───────────────────────────────

  static String _adaptiveInstruction(RlhfSession session) {
    switch (session.behaviorTier) {
      case 'confident':
        // Pasien puas → lebih ringkas & proaktif
        return '''
## INSTRUKSI ADAPTIF [Tier: Percaya Diri — Skor ${session.rewardScore.toStringAsFixed(1)}]
Pasien tampak puas dengan respons sebelumnya. Terapkan gaya ini:
- Jawab lebih langsung dan ringkas (maks 100 kata).
- Gunakan poin-poin jika ada lebih dari 2 saran.
- Tawarkan informasi lanjutan secara proaktif.
- Nada: hangat tapi efisien.
''';

      case 'cautious':
        // Pasien tidak puas → lebih hati-hati & menggali
        return '''
## INSTRUKSI ADAPTIF [Tier: Hati-hati — Skor ${session.rewardScore.toStringAsFixed(1)}]
Beberapa respons sebelumnya kurang memuaskan pasien. Terapkan gaya ini:
- Ajukan lebih banyak pertanyaan klarifikasi sebelum memberi saran.
- Gunakan bahasa yang lebih sederhana dan analogis.
- Tunjukkan lebih banyak empati di awal respons.
- Konfirmasi pemahaman: "Apakah maksud Anda...?"
- Nada: sangat sabar, tidak terburu-buru.
''';

      default: // balanced
        return '''
## INSTRUKSI ADAPTIF [Tier: Seimbang — Skor ${session.rewardScore.toStringAsFixed(1)}]
Pertahankan pendekatan standar:
- Gali keluhan sebelum memberi saran (1–2 pertanyaan).
- Jawaban sedang: 80–130 kata.
- Tanya tindak lanjut di akhir setiap respons.
''';
    }
  }

  // ── Build System Prompt Dinamis ───────────────────────────────────────────

  String _buildSystemPrompt(RlhfSession session) =>
      _baseSystemPrompt + _adaptiveInstruction(session);

  // ── Chat Utama dengan RLHF ────────────────────────────────────────────────

  Future<String> chatKlinik(String pesanPasien, RlhfSession session) async {
    // Simpan pesan pasien ke history
    session.conversationHistory.add({'role': 'user', 'content': pesanPasien});

    // Batasi history 12 pesan terakhir (hemat token)
    final recentHistory = session.conversationHistory.length > 12
        ? session.conversationHistory.sublist(
            session.conversationHistory.length - 12,
          )
        : session.conversationHistory;

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 350,
          'temperature': session.modelTemperature, // ← Suhu adaptif
          'messages': [
            {'role': 'system', 'content': _buildSystemPrompt(session)},
            ...recentHistory,
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply =
            data['choices'][0]['message']['content'] as String? ??
            "Maaf, saya tidak mengerti. Bisa diulangi? 😊";
        final tokens = data['usage']?['total_tokens'] as int? ?? 0;

        // Simpan respons AI ke history
        session.conversationHistory.add({
          'role': 'assistant',
          'content': reply,
        });

        // Log ke Firebase (non-blocking)
        _logInteraction(
          sessionId: session.sessionId,
          userMessage: pesanPasien,
          aiResponse: reply,
          rewardScore: session.rewardScore,
          behaviorTier: session.behaviorTier,
          tokensUsed: tokens,
        );

        return reply;
      }

      return "Maaf, layanan sedang gangguan (${response.statusCode}). Silakan coba lagi. 🏥";
    } catch (e) {
      return "Koneksi bermasalah. Pastikan internet Anda aktif. 🙏";
    }
  }

  // ── Proses Feedback Like / Unlike ─────────────────────────────────────────

  Future<void> submitFeedback({
    required RlhfSession session,
    required bool isLike,
    required String messageId,
  }) async {
    final delta = isLike ? 0.857 : -0.341;

    // Update skor lokal secara instan (realtime feel)
    isLike ? session.applyLike() : session.applyDislike();

    // Persist ke Firebase
    try {
      final batch = _db.batch();

      // 1) Dokumen feedback individual
      final feedbackRef = _db
          .collection('rlhf_feedback')
          .doc(session.sessionId)
          .collection('events')
          .doc(messageId);

      batch.set(feedbackRef, {
        'sessionId': session.sessionId,
        'messageId': messageId,
        'type': isLike ? 'like' : 'dislike',
        'delta': delta,
        'rewardAfter': session.rewardScore,
        'behaviorTier': session.behaviorTier,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2) Snapshot sesi (untuk ML aggregation)
      final sessionRef = _db.collection('rlhf_sessions').doc(session.sessionId);
      batch.set(sessionRef, {
        'rewardScore': session.rewardScore,
        'behaviorTier': session.behaviorTier,
        'totalLikes': session.totalLikes,
        'totalDislikes': session.totalDislikes,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      // Gagal log tidak mengganggu UX
      debugPrint('Firebase RLHF log error: $e');
    }
  }

  // ── Log Interaksi untuk ML Training Data ──────────────────────────────────

  Future<void> _logInteraction({
    required String sessionId,
    required String userMessage,
    required String aiResponse,
    required double rewardScore,
    required String behaviorTier,
    required int tokensUsed,
  }) async {
    try {
      await _db.collection('rlhf_interactions').add({
        'sessionId': sessionId,
        'userMessage': userMessage,
        'aiResponse': aiResponse,
        'rewardScore': rewardScore,
        'behaviorTier': behaviorTier,
        'tokensUsed': tokensUsed,
        'timestamp': FieldValue.serverTimestamp(),
        // Field ini yang dipakai Firebase ML untuk supervised fine-tuning
        'trainingLabel': null, // diisi manual reviewer di Firebase Console
      });
    } catch (e) {
      debugPrint('Firebase interaction log error: $e');
    }
  }

  // ── Analytics Traffic ──────────────────────────────────────────────────────

  Future<String> analyzeTraffic(List<Map<String, dynamic>> logs) async {
    const systemPromptAnalytics = '''
Kamu adalah Data Scientist di Klinik Sehat.
Analisis log trafik dan data RLHF berikut. Berikan insight dalam Bahasa Indonesia:
- Pola penggunaan (jam puncak, keluhan terbanyak, behavior tier dominan)
- Tren reward score (apakah AI makin disukai pasien?)
- Saran operasional klinik (penjadwalan staf, topik training AI)
Format: markdown rapi dengan bullet points dan bold text. Maks 300 kata.
''';

    try {
      final logString = logs.map((l) => l.toString()).join('\n');
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 500,
          'messages': [
            {'role': 'system', 'content': systemPromptAnalytics},
            {
              'role': 'user',
              'content': 'Data log:\n$logString\n\nBerikan analisis.',
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ??
            "Gagal menganalisa data.";
      }
      return "Error analisa: kode ${response.statusCode}.";
    } catch (e) {
      return "Error: Analisa AI gagal. ($e)";
    }
  }
}
