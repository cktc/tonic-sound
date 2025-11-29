import 'package:flutter/material.dart';
import '../theme/tonic_colors.dart';
import 'enums.dart';

/// Static catalog of available Tonics.
/// Tonics are generated sounds using noise algorithms.
/// Each Tonic has a unique character suited for different purposes.
class Tonic {
  const Tonic({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.noiseType,
    required this.color,
    required this.imagePath,
  });

  final String id;
  final String name;
  final String tagline;
  final String description;
  final NoiseType noiseType;
  final Color color;
  final String imagePath;

  /// The default Tonic shown on first launch
  static Tonic get defaultTonic => catalog.first;

  /// All available Tonics
  static const List<Tonic> catalog = [
    Tonic(
      id: 'bright',
      name: 'Bright',
      tagline: 'Clarity & Focus',
      description:
          'A crisp, even-energy formula that masks distractions and sharpens concentration. Ideal for deep work and study sessions.',
      noiseType: NoiseType.white,
      color: TonicColors.brightTonic,
      imagePath: 'assets/images/bottles/bright.png',
    ),
    Tonic(
      id: 'rest',
      name: 'Rest',
      tagline: 'Deep Sleep',
      description:
          'A warm, balanced blend that soothes the mind and promotes restful sleep. The go-to prescription for a peaceful night.',
      noiseType: NoiseType.pink,
      color: TonicColors.restTonic,
      imagePath: 'assets/images/bottles/rest.png',
    ),
    Tonic(
      id: 'focus',
      name: 'Focus',
      tagline: 'Calm Concentration',
      description:
          'A deep, rumbling foundation that blocks outside noise while keeping you grounded. Perfect for meditation and relaxation.',
      noiseType: NoiseType.brown,
      color: TonicColors.focusTonic,
      imagePath: 'assets/images/bottles/focus.png',
    ),
  ];

  /// Find a Tonic by its ID
  static Tonic? byId(String id) {
    try {
      return catalog.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Static catalog of available Botanicals.
/// Botanicals are algorithmically generated ambient sounds.
/// Each Botanical provides natural soundscapes for relaxation.
class Botanical {
  const Botanical({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.botanicalType,
    required this.color,
    required this.imagePath,
  });

  final String id;
  final String name;
  final String tagline;
  final String description;
  final BotanicalType botanicalType;
  final Color color;
  final String imagePath;

  /// The default Botanical shown on first launch
  static Botanical get defaultBotanical => catalog.first;

  /// All available Botanicals
  static const List<Botanical> catalog = [
    Botanical(
      id: 'rain',
      name: 'Rain',
      tagline: 'Gentle Rainfall',
      description:
          'The soothing sound of steady rain against a windowpane. A timeless remedy for restless minds.',
      botanicalType: BotanicalType.rain,
      color: TonicColors.rainBotanical,
      imagePath: 'assets/images/botanicals/rain.png',
    ),
    Botanical(
      id: 'ocean',
      name: 'Ocean',
      tagline: 'Coastal Waves',
      description:
          'Rhythmic ocean waves rolling onto a quiet shore. Let the tide wash away your worries.',
      botanicalType: BotanicalType.ocean,
      color: TonicColors.oceanBotanical,
      imagePath: 'assets/images/botanicals/ocean.png',
    ),
    Botanical(
      id: 'wind',
      name: 'Wind',
      tagline: 'Gentle Breeze',
      description:
          'The soft whisper of wind through open spaces. A calming presence that carries your thoughts away.',
      botanicalType: BotanicalType.wind,
      color: TonicColors.windBotanical,
      imagePath: 'assets/images/botanicals/wind.png',
    ),
  ];

  /// Find a Botanical by its ID
  static Botanical? byId(String id) {
    try {
      return catalog.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
