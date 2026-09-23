import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5A52D5);
  static const Color primaryLight = Color(0xFF8B83FF);

  static const Color secondary = Color(0xFFFF6B6B);
  static const Color secondaryDark = Color(0xFFE55555);

  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F5);

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);

  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocus = Color(0xFF6C63FF);

  static const Color like = Color(0xFF22C55E);
  static const Color superLike = Color(0xFF3B82F6);
  static const Color pass = Color(0xFFEF4444);

  static const Color google = Color(0xFFDB4437);
  static const Color apple = Color(0xFF000000);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF8B83FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFF6C63FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
