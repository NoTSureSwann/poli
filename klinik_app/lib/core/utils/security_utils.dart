import 'dart:math';

/// Utility class untuk keamanan data dan sanitasi input.
/// [SEC-13, SEC-14 FIX]
class SecurityUtils {
  /// Memask NIK agar hanya menampilkan 4 digit pertama dan 4 digit terakhir.
  /// Contoh: '3201123456780001' → '3201********0001'
  /// [SEC-13 FIX]: NIK adalah data sensitif yang tidak boleh ditampilkan utuh.
  static String maskNik(String nik) {
    if (nik.length <= 8) return nik; // Terlalu pendek untuk di-mask
    final first = nik.substring(0, 4);
    final last = nik.substring(nik.length - 4);
    final masked = '*' * (nik.length - 8);
    return '$first$masked$last';
  }

  /// Sanitasi input teks dari karakter berbahaya (XSS, injection).
  /// [SEC-14 FIX]: Membersihkan input sebelum disimpan ke database.
  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'[<>"\x27\\]'), '') // Hapus karakter XSS
        .replaceAll(RegExp(r'\$\{.*?\}'), '')   // Hapus template injection
        .trim()
        .substring(0, min(input.trim().length, 500)); // Batasi panjang maks
  }

  /// Validasi format NIK Indonesia (16 digit angka).
  static bool isValidNik(String nik) {
    return RegExp(r'^\d{16}$').hasMatch(nik);
  }

  /// Validasi format email.
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(email);
  }
}
