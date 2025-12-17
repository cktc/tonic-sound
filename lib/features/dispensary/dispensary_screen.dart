import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:provider/provider.dart';
import '../../core/analytics/analytics_service.dart';
import '../../shared/constants/enums.dart';
import '../../shared/constants/test_keys.dart';
import '../../shared/constants/tonic_catalog.dart';
import '../../shared/navigation/app_router.dart';
import '../../shared/theme/tonic_colors.dart';
import '../counter/counter_provider.dart';
import 'dispensary_provider.dart';
import 'widgets/botanical_card.dart';
import 'widgets/tonic_card.dart';

/// Dispensary screen - elegant apothecary-style sound library.
/// Browse and select tonics and botanicals with Victorian aesthetics.
/// Single tap selects a sound and navigates to Counter.
class DispensaryScreen extends StatelessWidget {
  const DispensaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current sound type to set initial tab
    final playback = context.read<PlaybackProvider>();
    final initialTab = playback.soundType == SoundType.botanical ? 1 : 0;

    return ChangeNotifierProvider(
      create: (_) => DispensaryProvider(initialTabIndex: initialTab),
      child: const _DispensaryScreenContent(),
    );
  }
}

class _DispensaryScreenContent extends StatelessWidget {
  const _DispensaryScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: TonicTestKeys.dispensaryScreen,
      backgroundColor: TonicColors.base,
      body: Consumer2<DispensaryProvider, PlaybackProvider>(
        builder: (context, dispensary, playback, child) {
          return SafeArea(
            child: Column(
              children: [
                // Elegant header
                _buildHeader(context),
                const SizedBox(height: 20),
                // Tab selector
                _buildTabSelector(context, dispensary),
                const SizedBox(height: 16),
                // Content grid
                Expanded(
                  child: dispensary.selectedTabIndex == 0
                      ? _buildTonicGrid(context, playback)
                      : _buildBotanicalGrid(context, playback),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        children: [
          // Decorative element
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 1,
                color: TonicColors.accent.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 12),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: TonicColors.accent.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 1,
                color: TonicColors.accent.withValues(alpha: 0.4),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            'Dispensary',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: TonicColors.textPrimary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          // Subtitle
          Text(
            'Sound Remedies & Nature Essences',
            style: GoogleFonts.sourceSans3(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: TonicColors.textMuted,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector(BuildContext context, DispensaryProvider dispensary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: TonicColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: TonicColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _TabButton(
                label: 'Tonics',
                subtitle: 'Generated',
                isSelected: dispensary.selectedTabIndex == 0,
                onTap: () {
                  if (dispensary.selectedTabIndex != 0) {
                    AnalyticsService.instance.trackDispensaryTabSwitched(
                      fromTabIndex: dispensary.selectedTabIndex,
                      toTabIndex: 0,
                    );
                  }
                  dispensary.selectTab(0);
                },
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _TabButton(
                label: 'Botanicals',
                subtitle: 'Nature',
                isSelected: dispensary.selectedTabIndex == 1,
                onTap: () {
                  if (dispensary.selectedTabIndex != 1) {
                    AnalyticsService.instance.trackDispensaryTabSwitched(
                      fromTabIndex: dispensary.selectedTabIndex,
                      toTabIndex: 1,
                    );
                  }
                  dispensary.selectTab(1);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTonicGrid(BuildContext context, PlaybackProvider playback) {
    final tonics = Tonic.catalog;

    return GridView.builder(
      key: TonicTestKeys.dispensaryTonicGrid,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: tonics.length,
      itemBuilder: (context, index) {
        final tonic = tonics[index];
        final isSelected = playback.soundType == SoundType.tonic &&
            playback.selectedTonic.id == tonic.id;

        return TonicCard(
          tonic: tonic,
          isSelected: isSelected,
          onTap: () => _selectTonic(context, playback, tonic),
        );
      },
    );
  }

  Widget _buildBotanicalGrid(BuildContext context, PlaybackProvider playback) {
    final botanicals = Botanical.catalog;

    return GridView.builder(
      key: TonicTestKeys.dispensaryBotanicalGrid,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: botanicals.length,
      itemBuilder: (context, index) {
        final botanical = botanicals[index];
        final isSelected = playback.soundType == SoundType.botanical &&
            playback.selectedBotanical?.id == botanical.id;

        return BotanicalCard(
          botanical: botanical,
          isSelected: isSelected,
          onTap: () => _selectBotanical(context, playback, botanical),
        );
      },
    );
  }

  void _selectTonic(
    BuildContext context,
    PlaybackProvider playback,
    Tonic tonic,
  ) {
    // Get previous sound ID for tracking
    final previousSoundId = playback.soundType == SoundType.tonic
        ? playback.selectedTonic.id
        : playback.selectedBotanical?.id;

    // Track sound selected
    AnalyticsService.instance.trackSoundSelected(
      soundId: tonic.id,
      soundType: SoundType.tonic,
      soundName: tonic.name,
      previousSoundId: previousSoundId,
    );

    playback.selectTonic(tonic);
    AppShell.switchTab(context, 0);
  }

  void _selectBotanical(
    BuildContext context,
    PlaybackProvider playback,
    Botanical botanical,
  ) {
    // Get previous sound ID for tracking
    final previousSoundId = playback.soundType == SoundType.tonic
        ? playback.selectedTonic.id
        : playback.selectedBotanical?.id;

    // Track sound selected
    AnalyticsService.instance.trackSoundSelected(
      soundId: botanical.id,
      soundType: SoundType.botanical,
      soundName: botanical.name,
      previousSoundId: previousSoundId,
    );

    playback.selectBotanical(botanical);
    AppShell.switchTab(context, 0);
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Haptics.vibrate(HapticsType.selection);
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    TonicColors.accent,
                    TonicColors.accentDark,
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: TonicColors.accent.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? TonicColors.base : TonicColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.sourceSans3(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: isSelected
                    ? TonicColors.base.withValues(alpha: 0.7)
                    : TonicColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
