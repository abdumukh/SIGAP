import 'package:flutter/material.dart';

/// Design tokens & color palette for SIGAP.
/// Optimized for emergency response, high contrast, and clean professional mobile layout.
class AppColors {
  AppColors._();

  // Primary & Emergency Colors
  static const Color primary = Color(0xFF1E3A8A); // Deep Navy Blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF172554);

  static const Color emergencyRed = Color(0xFFDC2626); // Bright Alert Red
  static const Color emergencyRedLight = Color(0xFFFEE2E2);

  // Role Badge Colors
  static const Color roleAdmin = Color(0xFF7C3AED); // Purple
  static const Color roleMasyarakat = Color(0xFF0284C7); // Sky Blue
  static const Color roleKetuaTim = Color(0xFFD97706); // Amber
  static const Color rolePetugas = Color(0xFF059669); // Emerald Green

  // Neutral Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textWhite = Color(0xFFFFFFFF);

  // State Colors
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoLight = Color(0xFFE0F2FE);
}
