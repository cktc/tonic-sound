import 'package:flutter/foundation.dart';

/// Simple debug logger that only logs in debug mode.
/// Prevents log spam in release builds.
class TonicLogger {
  TonicLogger._();

  /// Whether logging is enabled (only in debug mode by default)
  static bool enabled = kDebugMode;

  /// Log a debug message
  static void d(String tag, String message) {
    if (enabled) {
      debugPrint('[$tag] $message');
    }
  }

  /// Log an error message (always logs, even in release)
  static void e(String tag, String message, [Object? error, StackTrace? stack]) {
    debugPrint('[$tag] ERROR: $message');
    if (error != null) {
      debugPrint('[$tag] Error: $error');
    }
    if (stack != null) {
      debugPrint('[$tag] Stack: $stack');
    }
  }
}
