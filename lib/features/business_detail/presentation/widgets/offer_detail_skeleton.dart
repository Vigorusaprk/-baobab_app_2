import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/offers_carousel_section.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Le squelette de la fiche d'une offre.
///
/// Il suit l'ordre réel de la page depuis la refonte : la barre du haut, le
/// nom en grand, le prix, la photo, la description, le bloc de faits, le
/// compteur, puis le rail des autres offres.
///
/// **Il ne peut pas connaître le mode de l'offre** : c'est la réponse du
/// serveur qui le dit, et elle n'est pas encore arrivée. Il prend donc la
/// forme de la fiche « à commander », la plus fréquente, et celle dont les
/// deux autres sont le plus proches — un titre, un prix, une photo. Les avis
/// n'y sont pas : beaucoup d'offres n'en ont aucun, et annoncer une section
/// qui ne viendra pas fait sauter la page au moment du remplacement.
class OfferDetailSkeleton extends StatelessWidget {
  const OfferDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + AppDimens.small,
      ),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // La barre du haut : le retour et le partage sont déjà là, eux, dès
        // le premier pixel — un squelette qui les cache donnerait une page
        // dont on ne peut pas sortir.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.small + 2),
          child: Row(
            children: [
              const Bone.circle(size: AppDimens.touchTarget),
              AppDimens.spacerSmallWidth,
              Bone.text(width: 140, style: theme.textTheme.labelSmall!),
              const Spacer(),
              const Bone.circle(size: AppDimens.touchTarget),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.appPaddingValue + 4,
            AppDimens.medium,
            AppDimens.appPaddingValue + 4,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone.text(width: 250, style: theme.textTheme.headlineMedium!),
              AppDimens.spacerMedium,
              Bone.text(width: 120, style: theme.textTheme.headlineSmall!),
              AppDimens.spacerMedium,
              const Bone(
                width: double.infinity,
                height: 172,
                uniRadius: AppDimens.radius12,
              ),
              AppDimens.spacerMedium,
              Bone.multiText(lines: 3, style: theme.textTheme.bodyMedium!),
              AppDimens.spacerMedium,
              for (var i = 0; i < 2; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.small + 1),
                  child: Row(
                    children: [
                      const Bone.circle(size: AppDimens.medium),
                      AppDimens.spacerSmallWidth,
                      Bone.text(width: 220, style: theme.textTheme.bodySmall!),
                    ],
                  ),
                ),
              AppDimens.spacerMedium,
              Row(
                children: [
                  Bone.text(width: 70, style: theme.textTheme.bodyMedium!),
                  const Spacer(),
                  const Bone(
                    width: 130,
                    height: AppDimens.touchTarget,
                    uniRadius: AppDimens.borderRadiusFull,
                  ),
                ],
              ),
            ],
          ),
        ),
        AppDimens.spacerLarge,
        const OffersCarouselSkeleton(titleWidth: 170, cardCount: 2),
        const SizedBox(height: AppDimens.large),
      ],
    );
  }
}
