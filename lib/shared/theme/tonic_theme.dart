import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tonic_colors.dart';

/// Tonic app theme - Victorian Apothecary aesthetic.
/// Uses Cormorant Garamond for elegant serif headings
/// and Source Sans 3 for refined body text.
class TonicTheme {
  TonicTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TonicColors.base,
      colorScheme: const ColorScheme.dark(
        primary: TonicColors.accent,
        secondary: TonicColors.accentLight,
        surface: TonicColors.surface,
        onPrimary: TonicColors.base,
        onSecondary: TonicColors.base,
        onSurface: TonicColors.textPrimary,
      ),
      textTheme: TextTheme(
        // Display - large decorative text
        displayLarge: GoogleFonts.cormorantGaramond(
          fontSize: 40,
          fontWeight: FontWeight.w500,
          color: TonicColors.textPrimary,
          letterSpacing: 1.5,
        ),
        displayMedium: GoogleFonts.cormorantGaramond(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          color: TonicColors.textPrimary,
          letterSpacing: 1.0,
        ),
        displaySmall: GoogleFonts.cormorantGaramond(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: TonicColors.textPrimary,
        ),
        // Headlines - section headers
        headlineLarge: GoogleFonts.cormorantGaramond(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: TonicColors.textPrimary,
          letterSpacing: 0.5,
        ),
        headlineMedium: GoogleFonts.cormorantGaramond(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: TonicColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.cormorantGaramond(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: TonicColors.textPrimary,
        ),
        // Titles - card headers, nav
        titleLarge: GoogleFonts.cormorantGaramond(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: TonicColors.textPrimary,
          letterSpacing: 0.5,
        ),
        titleMedium: GoogleFonts.sourceSans3(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: TonicColors.textPrimary,
          letterSpacing: 0.3,
        ),
        titleSmall: GoogleFonts.sourceSans3(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: TonicColors.textSecondary,
          letterSpacing: 0.3,
        ),
        // Body text
        bodyLarge: GoogleFonts.sourceSans3(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: TonicColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.sourceSans3(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: TonicColors.textSecondary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.sourceSans3(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: TonicColors.textSecondary,
          height: 1.4,
        ),
        // Labels - buttons, tags, small text
        labelLarge: GoogleFonts.sourceSans3(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: TonicColors.textPrimary,
        ),
        labelMedium: GoogleFonts.sourceSans3(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
          color: TonicColors.textSecondary,
        ),
        labelSmall: GoogleFonts.sourceSans3(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
          color: TonicColors.textMuted,
        ),
      ),
      cardTheme: CardThemeData(
        color: TonicColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: TonicColors.border,
            width: 1,
          ),
        ),
        elevation: 0,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: TonicColors.accent,
        inactiveTrackColor: TonicColors.surfaceLight,
        thumbColor: TonicColors.accentLight,
        overlayColor: TonicColors.accent.withValues(alpha: 0.15),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 8,
          elevation: 2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TonicColors.accent,
          foregroundColor: TonicColors.base,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TonicColors.accent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: TonicColors.accent, width: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: TonicColors.accent,
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: TonicColors.textSecondary,
        size: 24,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: TonicColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: TonicColors.textPrimary,
          letterSpacing: 1.0,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: TonicColors.accent,
        unselectedItemColor: TonicColors.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: TonicColors.divider,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: TonicColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: TonicColors.border),
        ),
        elevation: 0,
      ),
    );
  }
}
