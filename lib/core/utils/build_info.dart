import 'package:package_info_plus/package_info_plus.dart';

/// Build information utility.
/// Mirrors the build number calculation from codemagic.yaml.
class BuildInfo {
  BuildInfo._();

  static PackageInfo? _packageInfo;

  /// Project start date from codemagic.yaml (first commit date)
  static final DateTime projectStartDate = DateTime.utc(2025, 11, 25, 15, 18, 55);

  /// Initialize package info. Call once at app startup.
  static Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  /// App version from pubspec.yaml (e.g., "1.0.3")
  static String get version => _packageInfo?.version ?? '–';

  /// Build number calculated as minutes since project start.
  /// This matches the codemagic.yaml calculation:
  /// BUILD_NUMBER=$(( (NOW_EPOCH - START_EPOCH) / 60 ))
  static String get buildNumber {
    final now = DateTime.now().toUtc();
    final minutesSinceStart = now.difference(projectStartDate).inMinutes;
    return minutesSinceStart.toString();
  }
}
