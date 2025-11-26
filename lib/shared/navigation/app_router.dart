import 'package:flutter/material.dart';
import '../../features/counter/counter_screen.dart';
import '../../features/dispensary/dispensary_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../constants/test_keys.dart';
import '../theme/tonic_colors.dart';

/// Main app shell with bottom navigation.
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

  final List<Widget> _screens = const [
    CounterScreen(),
    DispensaryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: TonicColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  key: TonicTestKeys.navCounter,
                  icon: Icons.science,
                  label: 'Counter',
                  isSelected: _currentIndex == 0,
                  onTap: () => _selectTab(0),
                ),
                _NavItem(
                  key: TonicTestKeys.navDispensary,
                  icon: Icons.store,
                  label: 'Dispensary',
                  isSelected: _currentIndex == 1,
                  onTap: () => _selectTab(1),
                ),
                _NavItem(
                  key: TonicTestKeys.navSettings,
                  icon: Icons.science_outlined,
                  label: 'Lab Notes',
                  isSelected: _currentIndex == 2,
                  onTap: () => _selectTab(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectTab(int index) {
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
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? TonicColors.accent.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? TonicColors.accent : TonicColors.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? TonicColors.accent
                        : TonicColors.textMuted,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
