import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tonic_colors.dart';

/// Tonic app theme - dark mode with apothecary aesthetic.
/// Uses Playfair Display for headings (elegant, serif) and Inter for body (clean, readable).
class TonicTheme {
  TonicTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TonicColors.base,
      colorScheme: const ColorScheme.dark(
        primary: TonicColors.accent,
        secondary: TonicColors.accent,
        surface: TonicColors.surface,
        onPrimary: TonicColors.base,
        onSecondary: TonicColors.base,
        onSurface: TonicColors.textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: TonicColors.textPrimary,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: TonicColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: TonicColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: TonicColors.textPrimary,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: TonicColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: TonicColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: TonicColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: TonicColors.textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: TonicColors.textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: TonicColors.textPrimary,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: TonicColors.textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          letterSpacing: 1.0,
          color: TonicColors.textMuted,
        ),
      ),
      cardTheme: CardThemeData(
        color: TonicColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: TonicColors.accent,
        inactiveTrackColor: TonicColors.surfaceLight,
        thumbColor: TonicColors.accent,
        overlayColor: TonicColors.accent.withValues(alpha: 0.2),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TonicColors.accent,
          foregroundColor: TonicColors.base,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: TonicColors.accent,
        ),
      ),
      iconTheme: const IconThemeData(
        color: TonicColors.textSecondary,
        size: 24,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: TonicColors.base,
        foregroundColor: TonicColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: TonicColors.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: TonicColors.surface,
        selectedItemColor: TonicColors.accent,
        unselectedItemColor: TonicColors.textMuted,
      ),
    );
  }
}
