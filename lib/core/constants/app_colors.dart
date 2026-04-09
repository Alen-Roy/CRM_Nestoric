import 'package:flutter/material.dart';

/// ── Nexify CRM · Light Theme Palette ──────────────────────────────────────
/// Matches the soft-lavender / clean-white design from the UI reference.
abstract class AppColors {
  // ── Background layers
  static const Color background   = Color(0xFFEEEFF8);   // page bg
  static const Color surface      = Colors.white;         // card / sheet bg
  static const Color surfaceTint  = Color(0xFFF5F4FF);   // slightly purple white

  // ── Brand / Primary
  static const Color primary      = Color(0xFF6C5CE7);   // main purple
  static const Color primaryLight = Color(0xFFEDE9FF);   // tint
  static const Color primaryGlow  = Color(0xFF9B8FF5);   // lighter purple

  // ── Secondary / Accent
  static const Color secondary    = Color(0xFF54C5EB);   // sky blue accent
  static const Color accent2      = Color(0xFF67D39F);   // mint green
  static const Color accent3      = Color(0xFFFFB86C);   // warm amber

  // ── Text
  static const Color textDark     = Color(0xFF1A1F36);   // headlines
  static const Color textMid      = Color(0xFF6B7194);   // body copy
  static const Color textLight    = Color(0xFFB0B5CC);   // placeholders

  // ── Status
  static const Color success      = Color(0xFF4CAF7D);
  static const Color warning      = Color(0xFFFFC048);
  static const Color danger       = Color(0xFFFF6B6B);
  static const Color info         = Color(0xFF54C5EB);

  // ── Borders & Dividers
  static const Color border       = Color(0xFFE4E6F0);
  static const Color divider      = Color(0xFFEEEFF5);

  // ── Gradient shortcuts
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryGlow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleGradient = LinearGradient(
    colors: [Color(0xFFEDE9FF), Color(0xFFE0F5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
