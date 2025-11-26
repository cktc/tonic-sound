import 'package:flutter/material.dart';

/// Tonic app color palette - dark mode optimized for sleep/focus context.
/// Colors are designed for low eye strain and apothecary aesthetic.
class TonicColors {
  TonicColors._();

  // Base palette - warm dark tones
  static const base = Color(0xFF1A1614);
  static const surface = Color(0xFF2C2420);
  static const surfaceLight = Color(0xFF3D342E);
  static const accent = Color(0xFFC9A227);
  static const accentLight = Color(0xFFE0BC4A);

  // Text colors
  static const textPrimary = Color(0xFFEDE6D9);
  static const textSecondary = Color(0xFFA69F92);
  static const textMuted = Color(0xFF6B665C);

  // Safety indicator colors (volume levels)
  static const safe = Color(0xFF4A7C59);
  static const moderate = Color(0xFFD4A03C);
  static const warning = Color(0xFFC75D3A);

  // Tonic colors - each tonic has a signature color
  static const brightTonic = Color(0xFFF5F0E6);
  static const restTonic = Color(0xFFD4899A);
  static const focusTonic = Color(0xFF8B6914);

  // Botanical colors
  static const rainBotanical = Color(0xFF6B8E9F);
  static const oceanBotanical = Color(0xFF2E5A6B);
  static const forestBotanical = Color(0xFF4A6B4A);
}
