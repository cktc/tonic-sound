import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';

import 'core/analytics/analytics_service.dart';
import 'core/storage/storage_service.dart';
import 'core/audio/services/audio_service_handler.dart';
import 'core/audio/services/tonic_audio_service.dart';
import 'features/counter/counter_provider.dart';
import 'features/onboarding/onboarding_flow.dart';
import 'shared/navigation/app_router.dart';
import 'features/onboarding/onboarding_provider.dart';
import 'shared/providers/preferences_provider.dart';
import 'shared/providers/prescription_provider.dart';
import 'shared/theme/tonic_theme.dart';

/// Global audio handler instance for background playback
late TonicAudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Hive for local storage
    await Hive.initFlutter();

    // Initialize storage service
    final storageService = StorageService();
    await storageService.initialize();

    // Initialize Mixpanel analytics
    await AnalyticsService.instance.initialize();

    // Initialize audio service for background playback and lock screen controls
    audioHandler = await AudioService.init(
      builder: () => TonicAudioHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.tonic.audio',
        androidNotificationChannelName: 'Tonic Playback',
        androidNotificationChannelDescription: 'Sound therapy playback controls',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );

    // Create the audio service
    final tonicAudioService = TonicAudioService(
      audioHandler: audioHandler,
      storageService: storageService,
    );

    runApp(
      MultiProvider(
        providers: [
          // Core services
          Provider<StorageService>.value(value: storageService),
          Provider<TonicAudioService>.value(value: tonicAudioService),

          // Preferences provider
          ChangeNotifierProvider<PreferencesProvider>(
            create: (context) => PreferencesProvider(
              storageService: storageService,
            ),
          ),

          // Onboarding provider
          ChangeNotifierProvider<OnboardingProvider>(
            create: (context) => OnboardingProvider(
              storageService: storageService,
            ),
          ),

          // Prescription provider
          ChangeNotifierProvider<PrescriptionProvider>(
            create: (context) => PrescriptionProvider(
              storageService: storageService,
            ),
          ),

          // Playback provider
          ChangeNotifierProvider<PlaybackProvider>(
            create: (context) => PlaybackProvider(
              audioService: tonicAudioService,
            ),
          ),
        ],
        child: const TonicApp(),
      ),
    );
  } catch (e, stack) {
    debugPrint('[main] Error during initialization: $e');
    debugPrint('[main] Stack trace: $stack');
    // Show error app
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
        ),
      ),
    ));
  }
}

class TonicApp extends StatefulWidget {
  const TonicApp({super.key});

  @override
  State<TonicApp> createState() => _TonicAppState();
}

class _TonicAppState extends State<TonicApp> {
  bool? _showOnboarding; // null = loading, true = show onboarding, false = show app
  bool _isFirstLaunch = false;

  @override
  void initState() {
    super.initState();
    // Check onboarding status after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboardingStatus();
    });
  }

  void _checkOnboardingStatus() {
    try {
      final preferencesProvider = context.read<PreferencesProvider>();
      final onboardingComplete = preferencesProvider.onboardingComplete;
      _isFirstLaunch = !onboardingComplete;

      // Track app opened
      AnalyticsService.instance.trackAppOpened(
        version: '1.0.1',
        isFirstLaunch: _isFirstLaunch,
        onboardingComplete: onboardingComplete,
      );

      // Register super properties
      AnalyticsService.instance.registerSuperProperties(
        onboardingComplete: onboardingComplete,
      );

      // Track onboarding started if showing onboarding
      if (!onboardingComplete) {
        AnalyticsService.instance.trackOnboardingStarted();
      }

      setState(() {
        _showOnboarding = !onboardingComplete;
      });
    } catch (e) {
      debugPrint('[TonicApp] Error checking onboarding: $e');
      setState(() {
        _showOnboarding = true; // Default to showing onboarding
      });
    }
  }

  void _onOnboardingComplete() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tonic',
      theme: TonicTheme.dark,
      debugShowCheckedModeBanner: false,
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    // Still loading
    if (_showOnboarding == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1614),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFC9A227),
          ),
        ),
      );
    }

    // Show onboarding or main app
    if (_showOnboarding!) {
      return OnboardingFlow(onComplete: _onOnboardingComplete);
    } else {
      return const AppShell();
    }
  }
}
