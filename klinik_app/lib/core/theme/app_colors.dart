import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors (Premium Healthcare)
  static const Color primary = Color(0xFF2563EB); // Modern Blue
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFFDBEAFE);
  
  static const Color secondary = Color(0xFF10B981); // Emerald Green
  static const Color secondaryDark = Color(0xFF047857);
  static const Color secondaryLight = Color(0xFFD1FAE5);

  static const Color accent = Color(0xFF8B5CF6); // Purple for AI
  static const Color accentLight = Color(0xFFEDE9FE);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Status Colors
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient aiGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
