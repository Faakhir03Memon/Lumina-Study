import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Background
  static const Color bg = Color(0xFF0A0A0F);
  static const Color bgCard = Color(0xFF13131A);
  static const Color bgSurface = Color(0xFF1A1A26);
  static const Color bgBorder = Color(0xFF2A2A3A);

  // Primary (Electric Violet)
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFF9D5FF8);
  static const Color primaryDark = Color(0xFF5B21B6);
  static const Color primaryGlow = Color(0x337C3AED);

  // Secondary (Cyan)
  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondaryGlow = Color(0x3306B6D4);

  // Accent (Pink)
  static const Color accent = Color(0xFFEC4899);
  static const Color accentGlow = Color(0x33EC4899);

  // Success / Warning / Error
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C8);
  static const Color textMuted = Color(0xFF6B6B8A);
  static const Color textDisabled = Color(0xFF3A3A52);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0A0A0F), Color(0xFF0D0D1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16162A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Module colors
  static const Color chatColor = Color(0xFF7C3AED);
  static const Color pdfColor = Color(0xFFEC4899);
  static const Color quizColor = Color(0xFF10B981);
  static const Color imageColor = Color(0xFFF59E0B);
  static const Color codeColor = Color(0xFF06B6D4);
  static const Color dashColor = Color(0xFF6366F1);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.bgCard,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.bgBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.bgBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.bgBorder, width: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.bgBorder,
        thickness: 0.5,
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.bgSurface,
        contentTextStyle: GoogleFonts.inter(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      displayMedium: GoogleFonts.outfit(
        fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      displaySmall: GoogleFonts.outfit(
        fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleLarge: GoogleFonts.outfit(
        fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleMedium: GoogleFonts.outfit(
        fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      titleSmall: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
      bodySmall: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted),
      labelLarge: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      labelMedium: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
      labelSmall: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w400, color: AppColors.textMuted),
    );
  }
}
