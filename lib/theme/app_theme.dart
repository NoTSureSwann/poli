import 'package:flutter/material.dart';

class AppTheme {
  // Standar Warna Kesehatan Digital Internasional
  static const Color primary = Color(0xFF2563EB); // Blue Medical
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1E40AF);

  static const Color success = Color(0xFF10B981); // Green Health
  static const Color warning = Color(0xFFF59E0B); // Amber Warning
  static const Color error = Color(0xFFEF4444); // Red Danger
  static const Color info = Color(0xFF3B82F6); // Blue Info

  static const Color accent = Color(0xFF0EA5A4); // Teal AI
  static const Color neutral = Color(0xFF64748B);

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    cardColor: Colors.white,
    dividerColor: const Color(0xFFE2E8F0),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      headlineMedium: TextStyle(
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      titleLarge: TextStyle(
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      bodyLarge: TextStyle(color: Color(0xFF334155), fontSize: 16),
      bodyMedium: TextStyle(color: Color(0xFF475569), fontSize: 14),
      labelMedium: TextStyle(color: Color(0xFF64748B), fontSize: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: primary, width: 1.7),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary.withAlpha(30)
              : Colors.transparent,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primaryDark
              : const Color(0xFF334155),
        ),
        side: WidgetStateProperty.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.selected)
                ? primary
                : const Color(0xFFCBD5E1),
          ),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: accent,
      error: error,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSurface: Color(0xFF0F172A),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryLight,
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    cardColor: const Color(0xFF1E293B),
    dividerColor: const Color(0xFF334155),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E293B),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      titleLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      bodyLarge: TextStyle(color: Color(0xFFF1F5F9), fontSize: 16),
      bodyMedium: TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
      labelMedium: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: primaryLight, width: 1.7),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primaryLight.withAlpha(38)
              : Colors.transparent,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : const Color(0xFFCBD5E1),
        ),
        side: WidgetStateProperty.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.selected)
                ? primaryLight
                : const Color(0xFF334155),
          ),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryLight,
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.dark(
      primary: primaryLight,
      secondary: accent,
      error: error,
      surface: const Color(0xFF1E293B),
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
  );
}
