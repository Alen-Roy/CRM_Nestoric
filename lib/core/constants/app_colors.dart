import 'package:flutter/material.dart';

/// ── Nexify CRM · Light Theme Palette ──────────────────────────────────────
abstract class AppColors {
  // ── Background layers
  static const Color background   = Color(0xFFEEEFF8);
  static const Color surface      = Colors.white;
  static const Color surfaceTint  = Color(0xFFF5F4FF);

  // ── Brand / Primary
  static const Color primary      = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFFEDE9FF);
  static const Color primaryGlow  = Color(0xFF9B8FF5);
  static const Color primaryDark  = Color(0xFF4A3CB5);  // deep purple for dark cards

  // ── Secondary / Accent
  static const Color secondary    = Color(0xFF54C5EB);
  static const Color accent2      = Color(0xFF67D39F);
  static const Color accent3      = Color(0xFFFFB86C);

  // ── Card accent blocks (for task/stat colored blocks)
  static const Color cardDark     = Color(0xFF1A1F36);   // dark card bg
  static const Color cardPurple   = Color(0xFF6C5CE7);   // primary card bg
  static const Color cardMint     = Color(0xFFDDF6EC);   // soft mint
  static const Color cardLavender = Color(0xFFEDE9FF);   // soft lavender

  // ── Text
  static const Color textDark     = Color(0xFF1A1F36);
  static const Color textMid      = Color(0xFF6B7194);
  static const Color textLight    = Color(0xFFB0B5CC);

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

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1F36), Color(0xFF2D3358)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
