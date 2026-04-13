import 'package:crm/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: false);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor:            AppColors.primary,

      colorScheme: const ColorScheme.light(
        primary:      AppColors.primary,
        secondary:    AppColors.primaryGlow,
        surface:      AppColors.surface,
        background:   AppColors.background,
        error:        AppColors.danger,
        onPrimary:    Colors.white,
        onSecondary:  Colors.white,
        onSurface:    AppColors.textDark,
        onBackground: AppColors.textDark,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation:       0,
        scrolledUnderElevation: 0,
        iconTheme:       IconThemeData(color: AppColors.textDark),
        titleTextStyle:  TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.w700),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:           Colors.transparent,
          statusBarIconBrightness:  Brightness.dark,
          systemNavigationBarColor: AppColors.primary,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),

      // DM Sans for everything
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        displayLarge:  GoogleFonts.dmSans(color: AppColors.textDark, fontWeight: FontWeight.w800),
        headlineMedium: GoogleFonts.dmSans(color: AppColors.textDark, fontWeight: FontWeight.w700),
        bodyLarge:     GoogleFonts.dmSans(color: AppColors.textDark),
        bodyMedium:    GoogleFonts.dmSans(color: AppColors.textDark),
        bodySmall:     GoogleFonts.dmSans(color: AppColors.textMid),
        titleLarge:    GoogleFonts.dmSans(color: AppColors.textDark, fontWeight: FontWeight.w700),
        labelMedium:   GoogleFonts.dmSans(color: AppColors.textMid),
      ),

      cardTheme: CardThemeData(
        color:     AppColors.surface,
        elevation: 0,
        shape:     RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin:    EdgeInsets.zero,
      ),

      // Global input fields — rounded 16px
      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),

      // Floating snackbar — dark navy pill style
      snackBarTheme: SnackBarThemeData(
        backgroundColor:  AppColors.primary,
        contentTextStyle: const TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w500),
        shape:            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior:         SnackBarBehavior.floating,
        elevation:        8,
        insetPadding:     const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Text selection
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor:           AppColors.primary,
        selectionColor:        AppColors.primaryLight,
        selectionHandleColor:  AppColors.primary,
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation:       8,
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      // Dialogs — rounder
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation:       12,
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),

      // Bottom sheets
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor:       AppColors.surface,
        modalBackgroundColor:  AppColors.surface,
        elevation:             0,
        shape:                 RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor:   AppColors.primaryLight,
        selectedColor:     AppColors.primary,
        labelStyle:        const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
        shape:             RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        side:              BorderSide.none,
        padding:           const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      dividerColor:    AppColors.divider,
      dividerTheme:    const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1),
      splashColor:     AppColors.primary.withOpacity(0.08),
      highlightColor:  AppColors.primary.withOpacity(0.05),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color:            AppColors.primary,
        linearMinHeight:  6,
      ),
    );
  }
}
