# Quickstart: Tonic MVP

**Feature Branch**: `001-tonic-mvp`
**Date**: 2025-11-25

---

## Prerequisites

- Flutter SDK 3.x (stable channel)
- Dart 3.x
- Xcode 15+ (for iOS)
- Android Studio / Android SDK (for Android)
- Physical device recommended for audio testing

## Setup

### 1. Create Flutter Project

```bash
# Create new Flutter project
flutter create tonic_sound --org com.tonic --platforms=ios,android

# Navigate to project
cd tonic_sound
```

### 2. Install Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Audio
  flutter_pcm_sound: ^0.1.0
  audio_service: ^0.18.12
  audio_session: ^0.1.18

  # State Management
  provider: ^6.1.1

  # Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # UI
  google_fonts: ^6.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
```

Install packages:

```bash
flutter pub get
```

### 3. Configure iOS

Add to `ios/Runner/Info.plist`:

```xml
<!-- Background Audio -->
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
</array>

<!-- Audio Session Description -->
<key>NSMicrophoneUsageDescription</key>
<string>Not used - required for audio session</string>
```

### 4. Configure Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
    <!-- Foreground Service Permission -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>

    <application ...>
        <!-- Audio Service -->
        <service
            android:name="com.ryanheise.audioservice.AudioService"
            android:foregroundServiceType="mediaPlayback"
            android:exported="true">
            <intent-filter>
                <action android:name="android.media.browse.MediaBrowserService"/>
            </intent-filter>
        </service>

        <receiver
            android:name="com.ryanheise.audioservice.MediaButtonReceiver"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MEDIA_BUTTON"/>
            </intent-filter>
        </receiver>
    </application>
</manifest>
```

Update `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### 5. Create Project Structure

```bash
# Create directory structure per constitution
mkdir -p lib/core/audio/generators
mkdir -p lib/core/audio/services
mkdir -p lib/core/storage
mkdir -p lib/features/counter
mkdir -p lib/features/dispensary
mkdir -p lib/features/onboarding
mkdir -p lib/features/settings
mkdir -p lib/shared/theme
mkdir -p lib/shared/widgets
mkdir -p lib/shared/constants
mkdir -p test/unit
mkdir -p test/widget
mkdir -p test/integration
mkdir -p assets/audio/botanicals
mkdir -p assets/images/bottles
mkdir -p assets/images/botanicals
```

### 6. Initialize Main Entry Point

Create `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';

import 'core/storage/storage_service.dart';
import 'core/audio/services/audio_service_handler.dart';
import 'shared/theme/tonic_theme.dart';
import 'features/counter/counter_screen.dart';

late AudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await Hive.initFlutter();
  final storageService = StorageService();
  await storageService.initialize();

  // Initialize audio service
  audioHandler = await AudioService.init(
    builder: () => TonicAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.tonic.audio',
      androidNotificationChannelName: 'Tonic Playback',
      androidNotificationOngoing: true,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<AudioHandler>.value(value: audioHandler),
        // Add other providers here
      ],
      child: const TonicApp(),
    ),
  );
}

class TonicApp extends StatelessWidget {
  const TonicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tonic',
      theme: TonicTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const CounterScreen(),
    );
  }
}
```

### 7. Create Theme

Create `lib/shared/theme/tonic_theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TonicColors {
  // Dark mode palette per constitution
  static const base = Color(0xFF1A1614);
  static const surface = Color(0xFF2C2420);
  static const accent = Color(0xFFC9A227);
  static const textPrimary = Color(0xFFEDE6D9);
  static const textSecondary = Color(0xFFA69F92);

  // Safety indicator colors
  static const safe = Color(0xFF4A7C59);
  static const moderate = Color(0xFFD4A03C);
  static const warning = Color(0xFFC75D3A);

  // Tonic colors
  static const brightTonic = Color(0xFFF5F0E6);
  static const restTonic = Color(0xFFD4899A);
  static const focusTonic = Color(0xFF8B6914);
}

class TonicTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TonicColors.base,
      colorScheme: const ColorScheme.dark(
        primary: TonicColors.accent,
        secondary: TonicColors.accent,
        surface: TonicColors.surface,
        background: TonicColors.base,
        onPrimary: TonicColors.base,
        onSecondary: TonicColors.base,
        onSurface: TonicColors.textPrimary,
        onBackground: TonicColors.textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: TonicColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w500,
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
        labelSmall: GoogleFonts.inter(
          fontSize: 12,
          letterSpacing: 1.0,
          color: TonicColors.textSecondary,
        ),
      ),
      cardTheme: CardTheme(
        color: TonicColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: TonicColors.accent,
        inactiveTrackColor: TonicColors.surface,
        thumbColor: TonicColors.accent,
        overlayColor: TonicColors.accent.withOpacity(0.2),
      ),
    );
  }
}
```

### 8. Generate Hive Adapters

Create model files with annotations, then run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Run the App

### Development

```bash
# iOS Simulator
flutter run -d ios

# Android Emulator
flutter run -d android

# Physical device (recommended for audio testing)
flutter run
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/noise_generator_test.dart

# Run with coverage
flutter test --coverage
```

---

## Verification Checklist

After setup, verify:

- [ ] App launches on iOS and Android
- [ ] Dark theme displays correctly
- [ ] No console errors on startup
- [ ] Hive initializes without errors
- [ ] Audio service initializes without errors

### Audio Verification (Physical Device)

- [ ] Generate white noise for 10 seconds
- [ ] Lock device - audio continues
- [ ] Lock screen shows media controls
- [ ] Background app - audio continues for 5+ minutes
- [ ] Phone call interruption - audio pauses/resumes

---

## Common Issues

### iOS: No audio in background

Ensure `UIBackgroundModes` includes `audio` in Info.plist.

### Android: Service crashes on SDK 34

Ensure `FOREGROUND_SERVICE_MEDIA_PLAYBACK` permission is declared.

### Hive: TypeAdapter not found

Run `flutter pub run build_runner build` after adding `@HiveType` annotations.

### Audio: Choppy or silent

- Check buffer size (should be ~50ms / 2205 samples)
- Test on physical device (simulator audio is unreliable)
- Verify audio session category is set to playback

---

## Next Steps

1. Implement noise generators in `lib/core/audio/generators/`
2. Create storage service in `lib/core/storage/`
3. Build Counter screen UI in `lib/features/counter/`
4. Add onboarding flow in `lib/features/onboarding/`
5. Implement Dispensary browser in `lib/features/dispensary/`

See `tasks.md` for detailed implementation tasks.
