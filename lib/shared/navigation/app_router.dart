import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:provider/provider.dart';
import '../../core/analytics/analytics_service.dart';
import '../../features/counter/counter_provider.dart';
import '../../features/counter/counter_screen.dart';
import '../../features/dispensary/dispensary_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../constants/test_keys.dart';
import '../theme/tonic_colors.dart';

/// Main app shell with elegant bottom navigation.
/// Features Victorian apothecary-style design.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  /// Switch to a specific tab from anywhere in the widget tree
  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_AppShellState>();
    state?._selectTab(index);
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const CounterScreen();
      case 1:
        return const DispensaryScreen();
      case 2:
        return const SettingsScreen();
      default:
        return const CounterScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _getScreen(_currentIndex),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            TonicColors.surfaceLight,
            TonicColors.surface,
          ],
        ),
        border: Border(
          top: BorderSide(
            color: TonicColors.border,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                key: TonicTestKeys.navCounter,
                icon: Icons.water_drop_rounded,
                label: 'Counter',
                isSelected: _currentIndex == 0,
                onTap: () => _selectTab(0),
              ),
              _NavItem(
                key: TonicTestKeys.navDispensary,
                icon: Icons.local_pharmacy_rounded,
                label: 'Dispensary',
                isSelected: _currentIndex == 1,
                onTap: () => _selectTab(1),
              ),
              _NavItem(
                key: TonicTestKeys.navSettings,
                icon: Icons.menu_book_rounded,
                label: 'Lab Notes',
                isSelected: _currentIndex == 2,
                onTap: () => _selectTab(2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectTab(int index) {
    if (_currentIndex != index) {
      // Track bottom navigation tap
      final playback = context.read<PlaybackProvider>();
      AnalyticsService.instance.trackBottomNavTapped(
        fromTabIndex: _currentIndex,
        toTabIndex: index,
        wasPlaying: playback.isPlaying,
      );
    }

    setState(() {
      _currentIndex = index;
    });
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Haptics.vibrate(HapticsType.selection);
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    TonicColors.accent.withValues(alpha: 0.2),
                    TonicColors.accent.withValues(alpha: 0.08),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(
                  color: TonicColors.accent.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with glow effect when selected
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: isSelected
                  ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: TonicColors.accent.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    )
                  : null,
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? TonicColors.accent : TonicColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              label,
              style: GoogleFonts.sourceSans3(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.3,
                color: isSelected ? TonicColors.accent : TonicColors.textMuted,
              ),
            ),
            // Selection indicator dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(top: 4),
              width: isSelected ? 4 : 0,
              height: isSelected ? 4 : 0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: TonicColors.accent,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: TonicColors.accent.withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
