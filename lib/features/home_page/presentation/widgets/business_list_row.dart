import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Ligne compacte représentant un établissement dans une liste verticale :
/// pastille avec l'initiale, nom, note et badge de catégorie.
///
/// Extraite de [PopularBusinessListView] pour être partagée avec l'écran
/// "Voir tout" ([AllBusinessesScreen]) — les deux doivent présenter un
/// établissement exactement de la même façon.
///
/// ⚠️ Pas de distance affichée : la table `business` n'a pas encore de
/// colonnes `latitude`/`longitude` côté Supabase.
class BusinessListRow extends StatelessWidget {
  final UIBusiness uiBusiness;
  final VoidCallback onTap;

  const BusinessListRow({
    super.key,
    required this.uiBusiness,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final business = uiBusiness.business;
    final initial = business.name.isNotEmpty
        ? business.name[0].toUpperCase()
        : '?';
    final double interiorPadding =
        AppDimens.cardBorderRadius - AppDimens.allPadding12Number;

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      borderRadius: AppDimens.cardBorderRadiusAll,
      child: InkWell(
        borderRadius: AppDimens.cardBorderRadiusAll,
        onTap: onTap,
        child: Container(
          padding: AppDimens.allPadding12,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: AppDimens.cardBorderRadiusAll,
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar rond avec l'initiale du nom
              Container(
                width: 45,
                height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: uiBusiness.categoryColor(context),
                  borderRadius: BorderRadius.circular(interiorPadding),
                ),
                child: Text(
                  initial,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      business.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium!,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: OtherTheme.of(context).rating,
                        ),
                        Text(
                          business.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        AppDimens.spacerSmallWidth,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              interiorPadding,
                            ),
                            color: uiBusiness
                                .categoryColor(context)
                                .withValues(alpha: 0.3),
                          ),
                          child: Text(
                            business.type.name,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: uiBusiness.categoryColor(context),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Squelette d'une [BusinessListRow], à envelopper dans un `Skeletonizer`.
///
/// Reprend exactement la structure de la vraie ligne (pastille carrée
/// arrondie, nom, ligne note + badge) avec des [Bone] explicites, comme
/// l'exige la convention de chargement du projet.
class BusinessListRowSkeleton extends StatelessWidget {
  const BusinessListRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final double interiorPadding =
        AppDimens.cardBorderRadius - AppDimens.allPadding12Number;

    return Container(
      padding: AppDimens.allPadding12,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: AppDimens.cardBorderRadiusAll,
      ),
      child: Row(
        children: [
          Bone(width: 45, height: 45, uniRadius: interiorPadding),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Bone.text(
                  width: 140,
                  style: Theme.of(context).textTheme.titleMedium!,
                ),
                const SizedBox(height: 6),
                Bone.text(
                  width: 90,
                  style: Theme.of(context).textTheme.bodySmall!,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
