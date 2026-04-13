import 'package:flutter/material.dart';

/// ── Nexify CRM · Pure Light Palette ──────────────────────────────────────
/// White · Light Grey · Purple shades · Red only. Zero dark colours.
abstract class AppColors {
  // ── Page backgrounds
  static const Color background  = Color(0xFFF3F2FB);   // faint purple-white
  static const Color surface     = Colors.white;
  static const Color surfaceTint = Color(0xFFF0EFFF);   // barely-purple card

  // ── Purple family — ALL light shades
  static const Color primary     = Color(0xFF6C5CE7);   // main purple
  static const Color primaryGlow = Color(0xFF9B8FF5);   // lighter purple
  static const Color primaryMid  = Color(0xFFB3A9F8);   // mid-light purple
  static const Color primarySoft = Color(0xFFD4CFFB);   // soft lavender
  static const Color primaryLight= Color(0xFFEDE9FF);   // very light lavender
  static const Color primaryPale = Color(0xFFF5F3FF);   // almost-white purple

  // ── Danger (only non-purple allowed)
  static const Color danger      = Color(0xFFE53935);
  static const Color dangerLight = Color(0xFFFFEBEB);

  // ── Text
  static const Color textDark    = Color(0xFF1E1A3C);
  static const Color textMid     = Color(0xFF6B6890);
  static const Color textLight   = Color(0xFFB0ADCC);

  // ── Borders & Dividers
  static const Color border      = Color(0xFFE8E6F5);
  static const Color divider     = Color(0xFFF0EFF8);

  // ── Gradients (primary always used on light backgrounds for headers)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryGlow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleGradient = LinearGradient(
    colors: [primaryLight, primaryPale],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softGradient = LinearGradient(
    colors: [primarySoft, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
