import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Squelettes des listes verticales de l'application.
///
/// Chacun reprend la forme du composant qu'il remplace, avec des [Bone]
/// explicites : un spinner centré ne dit rien de ce qui arrive, alors qu'une
/// forme reconnaissable prépare l'œil et évite le saut de mise en page au
/// moment du remplacement.

/// Mirrors [SearchResultsList]'s result card : vignette carrée, nom, note.
///
/// Sert aussi de tuile de fin de liste pendant le chargement de la page
/// suivante — c'est exactement ce qui va s'y afficher.
class SearchResultSkeleton extends StatelessWidget {
  const SearchResultSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppDimens.radius20),
        ),
        child: Row(
          children: [
            const Bone(width: 80, height: 80, uniRadius: AppDimens.radius16),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Bone.text(
                    width: 150,
                    style: Theme.of(context).textTheme.titleMedium!,
                  ),
                  const SizedBox(height: 8),
                  Bone.text(
                    width: 100,
                    style: Theme.of(context).textTheme.bodySmall!,
                  ),
                  const SizedBox(height: 6),
                  Bone.text(
                    width: 70,
                    style: Theme.of(context).textTheme.bodySmall!,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mirrors [FeedItemCard] : icône, titre, corps, horodatage.
class FeedListSkeleton extends StatelessWidget {
  final int itemCount;

  const FeedListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 12, bottom: 16),
        itemCount: itemCount,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppDimens.radius16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Bone.circle(size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Bone.text(
                      width: 160,
                      style: Theme.of(context).textTheme.bodyLarge!,
                    ),
                    const SizedBox(height: 6),
                    Bone.multiText(
                      lines: 2,
                      style: Theme.of(context).textTheme.bodySmall!,
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

/// Cartes de commerces en liste verticale.
class BudgetResultsSkeleton extends StatelessWidget {
  final int itemCount;

  const BudgetResultsSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: itemCount,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Bone(
            width: double.infinity,
            height: 140,
            uniRadius: AppDimens.radius16,
          ),
        ),
      ),
    );
  }
}
