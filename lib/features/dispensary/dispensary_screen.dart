import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
class DispensaryScreen extends StatelessWidget {
  const DispensaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DispensaryProvider(),
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
                // Selection panel
                if (dispensary.highlightedTonic != null ||
                    dispensary.highlightedBotanical != null)
                  _buildSelectionPanel(context, dispensary, playback),
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
                onTap: () => dispensary.selectTab(0),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _TabButton(
                label: 'Botanicals',
                subtitle: 'Nature',
                isSelected: dispensary.selectedTabIndex == 1,
                onTap: () => dispensary.selectTab(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTonicGrid(BuildContext context, PlaybackProvider playback) {
    final tonics = Tonic.catalog;
    final dispensary = context.watch<DispensaryProvider>();

    return GridView.builder(
      key: TonicTestKeys.dispensaryTonicGrid,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: tonics.length,
      itemBuilder: (context, index) {
        final tonic = tonics[index];
        final isHighlighted = dispensary.highlightedTonic?.id == tonic.id;

        return TonicCard(
          tonic: tonic,
          isSelected: isHighlighted,
          onTap: () {
            dispensary.highlightTonic(tonic);
          },
        );
      },
    );
  }

  Widget _buildBotanicalGrid(BuildContext context, PlaybackProvider playback) {
    final botanicals = Botanical.catalog;
    final dispensary = context.watch<DispensaryProvider>();

    return GridView.builder(
      key: TonicTestKeys.dispensaryBotanicalGrid,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: botanicals.length,
      itemBuilder: (context, index) {
        final botanical = botanicals[index];
        final isHighlighted = dispensary.highlightedBotanical?.id == botanical.id;

        return BotanicalCard(
          botanical: botanical,
          isSelected: isHighlighted,
          onTap: () {
            dispensary.highlightBotanical(botanical);
          },
        );
      },
    );
  }

  Widget _buildSelectionPanel(
    BuildContext context,
    DispensaryProvider dispensary,
    PlaybackProvider playback,
  ) {
    final tonic = dispensary.highlightedTonic;
    final botanical = dispensary.highlightedBotanical;

    final name = tonic?.name ?? botanical?.name ?? '';
    final description = tonic?.description ?? botanical?.description ?? '';
    final color = tonic?.color ?? botanical?.color ?? TonicColors.accent;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            TonicColors.surfaceLight,
            TonicColors.surface,
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        border: Border(
          top: BorderSide(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag indicator
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: TonicColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Info row
            Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        color.withValues(alpha: 0.3),
                        color.withValues(alpha: 0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    tonic != null ? Icons.water_drop_rounded : Icons.eco_rounded,
                    size: 22,
                    color: color,
                  ),
                ),
                const SizedBox(width: 14),
                // Name and type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: TonicColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tonic != null ? 'Generated Sound' : 'Nature Essence',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: color,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              description,
              style: GoogleFonts.sourceSans3(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: TonicColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 18),
            // Action button
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  if (tonic != null) {
                    playback.selectTonic(tonic);
                  } else if (botanical != null) {
                    playback.selectBotanical(botanical);
                  }
                  dispensary.clearHighlight();
                  AppShell.switchTab(context, 0);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TonicColors.accent,
                        TonicColors.accentDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: TonicColors.accentLight.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: TonicColors.accent.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Use This Remedy',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: TonicColors.base,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
      onTap: onTap,
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
