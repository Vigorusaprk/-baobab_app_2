import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_detail_views.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/offers_carousel_section.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Le squelette de la fiche d'une offre.
///
/// **Il prend la forme du mode attendu.** Les trois fiches ne se ressemblent
/// pas — une réservation met sa photo en tête, pleine largeur, sous une barre
/// épinglée ; une commande commence par son nom et son prix — et un squelette
/// d'une autre forme que son contenu fait sauter la page au moment où les
/// données arrivent.
///
/// Le mode vient de la carte qu'on vient de toucher, transmis par la route
/// ([OfferDetailScreen.expected]). Quand il est inconnu — lien direct,
/// reprise de session — la forme « commande » sert de défaut : c'est la plus
/// fréquente, et celle dont les deux autres sont le plus proches.
///
/// Les avis n'y sont pas : beaucoup d'offres n'en ont aucun, et annoncer une
/// section qui ne viendra pas fait sauter la page au remplacement.
class OfferDetailSkeleton extends StatelessWidget {
  const OfferDetailSkeleton({super.key, this.expected});

  final Fulfilment? expected;

  @override
  Widget build(BuildContext context) {
    if (expected == Fulfilment.booking) return const _BookingSkeleton();
    return _FlatSkeleton(inStore: expected == Fulfilment.inStore);
  }
}

/// La forme d'une commande — et, à un bandeau près, celle d'une offre en
/// boutique : une barre, le nom, le prix, la photo, la description.
class _FlatSkeleton extends StatelessWidget {
  const _FlatSkeleton({required this.inStore});

  /// Une offre en boutique porte un bandeau à la place du compteur.
  final bool inStore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + AppDimens.small,
      ),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const _BarSkeleton(),
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
              if (inStore) ...[
                const Bone(
                  width: double.infinity,
                  height: 72,
                  uniRadius: AppDimens.radius12,
                ),
                AppDimens.spacerMedium,
              ],
              Bone(
                width: double.infinity,
                height: inStore ? 150 : 172,
                uniRadius: AppDimens.radius12,
              ),
              AppDimens.spacerMedium,
              Bone.multiText(lines: 3, style: theme.textTheme.bodyMedium!),
              AppDimens.spacerMedium,
              const _FactLinesSkeleton(),
              if (!inStore) ...[
                AppDimens.spacerMedium,
                const _CounterSkeleton(),
              ],
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

/// La forme d'une réservation : la photo pleine largeur en tête, la feuille
/// qui la recouvre, l'étiquette, le nom, le prix, la date.
class _BookingSkeleton extends StatelessWidget {
  const _BookingSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final top = MediaQuery.paddingOf(context).top;

    return ListView(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Stack(
          children: [
            Bone(
              width: double.infinity,
              height: OfferBookingView.photoHeight + top,
              borderRadius: BorderRadius.zero,
            ),
            Padding(
              padding: EdgeInsets.only(
                top: top + AppDimens.small,
                left: AppDimens.appPaddingValue,
                right: AppDimens.appPaddingValue,
              ),
              child: const Row(
                children: [
                  Bone.circle(size: AppDimens.touchTarget),
                  Spacer(),
                  Bone.circle(size: AppDimens.touchTarget),
                ],
              ),
            ),
          ],
        ),
        Container(
          transform: Matrix4.translationValues(0, -14, 0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.radius16),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppDimens.appPaddingValue + 4,
            AppDimens.medium + 2,
            AppDimens.appPaddingValue + 4,
            AppDimens.large,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Bone(
                width: 130,
                height: 26,
                uniRadius: AppDimens.borderRadiusFull,
              ),
              AppDimens.spacerMedium,
              Bone.text(width: 230, style: theme.textTheme.headlineMedium!),
              AppDimens.spacerMedium,
              Bone.text(width: 120, style: theme.textTheme.headlineSmall!),
              AppDimens.spacerMedium,
              Bone.multiText(lines: 2, style: theme.textTheme.bodyMedium!),
              AppDimens.spacerLarge,
              Bone.text(width: 46, style: theme.textTheme.labelSmall!),
              AppDimens.spacerSmall,
              const Row(
                spacing: AppDimens.small,
                children: [
                  Expanded(
                    child: Bone(height: 68, uniRadius: AppDimens.radius12),
                  ),
                  Expanded(
                    child: Bone(height: 68, uniRadius: AppDimens.radius12),
                  ),
                  Expanded(
                    child: Bone(height: 68, uniRadius: AppDimens.radius12),
                  ),
                  Bone(
                    width: AppDimens.touchTarget,
                    height: 68,
                    uniRadius: AppDimens.radius12,
                  ),
                ],
              ),
              AppDimens.spacerLarge,
              const _CounterSkeleton(),
            ],
          ),
        ),
      ],
    );
  }
}

/// La barre du haut : le retour et le partage sont là, eux, dès le premier
/// pixel — un squelette qui les cache donnerait une page dont on ne peut pas
/// sortir.
class _BarSkeleton extends StatelessWidget {
  const _BarSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.small + 2),
      child: Row(
        children: [
          const Bone.circle(size: AppDimens.touchTarget),
          AppDimens.spacerSmallWidth,
          Bone.text(width: 140, style: Theme.of(context).textTheme.labelSmall!),
          const Spacer(),
          const Bone.circle(size: AppDimens.touchTarget),
        ],
      ),
    );
  }
}

/// Deux lignes de faits, entre leurs perforations.
class _FactLinesSkeleton extends StatelessWidget {
  const _FactLinesSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
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
      ],
    );
  }
}

/// « Quantité » et son compteur en pilule.
class _CounterSkeleton extends StatelessWidget {
  const _CounterSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Bone.text(width: 70, style: Theme.of(context).textTheme.bodyMedium!),
        const Spacer(),
        const Bone(
          width: 130,
          height: AppDimens.touchTarget,
          uniRadius: AppDimens.borderRadiusFull,
        ),
      ],
    );
  }
}
