import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';
import 'discover_ad_preview_hero.dart';

/// Carte fictive de développement pour vérifier le rendu d'une annonce.
class DiscoverAdPreviewCard extends StatelessWidget {
  const DiscoverAdPreviewCard({super.key, required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: AppDimens.cardBorderRadiusAll,
      elevation: AppDimens.elevationDefault,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Expanded(flex: 6, child: const DiscoverAdPreviewHero()),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.allPadding12Number),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'APERÇU FICTIF',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      AppDimens.spacerSmall,
                      Text(
                        'Commerce de démonstration',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      AppDimens.spacerSmall,
                      Text(
                        'Une annonce de commerce apparaîtra ici.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Text(
                        'Aperçu seulement',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: AppDimens.small,
            right: AppDimens.small,
            child: Semantics(
              button: true,
              label: 'Passer l’aperçu publicitaire',
              child: Material(
                color: colors.surface,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onSkip,
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.close_rounded),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
