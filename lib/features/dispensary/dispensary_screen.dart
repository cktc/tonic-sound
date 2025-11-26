import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/constants/test_keys.dart';
import '../../shared/constants/tonic_catalog.dart';
import '../../shared/navigation/app_router.dart';
import '../../shared/theme/tonic_colors.dart';
import '../counter/counter_provider.dart';
import 'dispensary_provider.dart';
import 'widgets/botanical_card.dart';
import 'widgets/tonic_card.dart';

/// Dispensary screen - browse and select tonics and botanicals.
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
      appBar: AppBar(
        backgroundColor: TonicColors.base,
        elevation: 0,
        title: Text(
          'Dispensary',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Consumer2<DispensaryProvider, PlaybackProvider>(
        builder: (context, dispensary, playback, child) {
          return Column(
            children: [
              // Tab selector
              _buildTabSelector(context, dispensary),
              const SizedBox(height: 16),
              // Content
              Expanded(
                child: dispensary.selectedTabIndex == 0
                    ? _buildTonicGrid(context, playback)
                    : _buildBotanicalGrid(context, playback),
              ),
              // Selection info
              if (dispensary.highlightedTonic != null ||
                  dispensary.highlightedBotanical != null)
                _buildSelectionInfo(context, dispensary, playback),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabSelector(BuildContext context, DispensaryProvider dispensary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Tonics',
              isSelected: dispensary.selectedTabIndex == 0,
              onTap: () => dispensary.selectTab(0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TabButton(
              label: 'Botanicals',
              isSelected: dispensary.selectedTabIndex == 1,
              onTap: () => dispensary.selectTab(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTonicGrid(BuildContext context, PlaybackProvider playback) {
    final tonics = Tonic.catalog;
    final dispensary = context.watch<DispensaryProvider>();

    return GridView.builder(
      key: TonicTestKeys.dispensaryTonicGrid,
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
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
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
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

  Widget _buildSelectionInfo(
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TonicColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and type
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  tonic != null ? Icons.water_drop : Icons.eco,
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      tonic != null ? 'Generated Noise' : 'Nature Sound',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: TonicColors.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TonicColors.textSecondary,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          // Select button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (tonic != null) {
                  playback.selectTonic(tonic);
                } else if (botanical != null) {
                  playback.selectBotanical(botanical);
                }
                dispensary.clearHighlight();
                // Switch to Counter tab (index 0) to show the selected item
                AppShell.switchTab(context, 0);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('Use This'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? TonicColors.accent : TonicColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isSelected ? TonicColors.base : TonicColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
