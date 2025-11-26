// Basic Flutter widget test for Tonic app.
// Full integration tests require device-specific audio setup.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tonic_sound/shared/theme/tonic_theme.dart';

void main() {
  testWidgets('TonicApp theme smoke test', (WidgetTester tester) async {
    // Build a minimal widget with Tonic theme to verify theme loads correctly
    await tester.pumpWidget(
      MaterialApp(
        theme: TonicTheme.dark,
        home: const Scaffold(
          body: Center(
            child: Text('Tonic'),
          ),
        ),
      ),
    );

    // Verify the app renders
    expect(find.text('Tonic'), findsOneWidget);
  });
}
