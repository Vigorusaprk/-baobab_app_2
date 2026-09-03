import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/core/widgets/offer_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Carrousel horizontal d'offres, avec son titre.
///
/// Sert les sections « Nouveautés » et « Découvrir » : même présentation,
/// contenus différents. Quand [hasMore] est vrai, une dernière tuile « Voir
/// plus » clôt la liste plutôt que de la laisser se terminer sans indice
/// qu'il en existe d'autres.
class OffersCarouselSection extends StatelessWidget {
  final String title;
  final List<Offer> offers;

  /// Reste-t-il des offres au-delà de celles affichées ?
  final bool hasMore;

  /// Déclenché par la tuile de fin. Sans lui, elle n'est pas affichée.
  final VoidCallback? onSeeMore;

  /// Tuile supplémentaire pendant le chargement d'une page suivante.
  final bool isLoadingMore;

  /// Signalé quand l'utilisateur approche de la fin : la vue ne connaît
  /// rien de la pagination, elle se contente de prévenir.
  final VoidCallback? onReachedEnd;

  const OffersCarouselSection({
    super.key,
    required this.title,
    required this.offers,
    this.hasMore = false,
    this.onSeeMore,
    this.isLoadingMore = false,
    this.onReachedEnd,
  });

  static const double cardWidth = 190;

  /// Hauteur du rail, partagée avec [OffersCarouselSkeleton] : un squelette
  /// plus haut ou plus court que le contenu réel fait sauter la page au
  /// moment où les données arrivent.
  static double railHeight(BuildContext context) =>
      AppDimens.horizontalScrollHeight(context, 0.36, min: 265, max: 310);

  @override
  Widget build(BuildContext context) {
    // Une section sans contenu disparaît entièrement : mieux vaut aucune
    // section qu'un titre suivi du vide.
    if (offers.isEmpty) return const SizedBox.shrink();

    final showSeeMore = hasMore && onSeeMore != null;
    final itemCount = offers.length + (showSeeMore ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppDimens.appPadding,
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: railHeight(context),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: AppDimens.appPadding,
            itemCount: itemCount,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index >= offers.length) {
                return _SeeMoreTile(
                  width: cardWidth,
                  onTap: onSeeMore!,
                  isLoading: isLoadingMore,
                );
              }

              if (onReachedEnd != null && index == offers.length - 2) {
                onReachedEnd!();
              }

              final offer = offers[index];
              // Pas d'entrée en scène ici. Un squelette de même forme
              // occupait déjà la place : la carte n'arrive pas, elle se
              // précise. Le seul mouvement est le croisement du squelette
              // vers le contenu, qui appartient à l'écran.
              return SizedBox(
                width: cardWidth,
                child: OfferCard(
                  offer: offer,
                  // On ouvre l'offre, pas la boutique : l'utilisateur a
                  // cliqué sur une chose précise, l'envoyer sur le catalogue
                  // entier du commerçant lui ferait la chercher.
                  onTap: () => context.pushNamed(
                    'offerDetail',
                    pathParameters: {'id': offer.id},
                    // Le mode voyage avec l'identifiant : le squelette prend
                    // la forme de la fiche qui va s'afficher.
                    extra: offer.fulfilment,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Tuile de fin de liste : indique qu'il reste des offres et permet de les
/// charger sans quitter la page.
class _SeeMoreTile extends StatelessWidget {
  final double width;
  final VoidCallback onTap;
  final bool isLoading;

  const _SeeMoreTile({
    required this.width,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: AppDimens.cardBorderRadiusAll,
        child: InkWell(
          borderRadius: AppDimens.cardBorderRadiusAll,
          onTap: isLoading ? null : onTap,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLoading ? Icons.more_horiz_rounded : Icons.arrow_forward,
                  color: Theme.of(context).colorScheme.primary,
                ),
                AppDimens.spacerSmall,
                Text(
                  isLoading ? 'Chargement…' : 'Voir plus',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Squelette d'un [OffersCarouselSection] : le titre puis le rail de
/// cartes, aux mêmes dimensions que le contenu réel.
///
/// Partagé par l'accueil, la fiche d'un commerçant et la fiche d'une offre —
/// les trois montrent le même rail, ils doivent donc charger pareil.
class OffersCarouselSkeleton extends StatelessWidget {
  /// Largeur du faux titre. Varie d'une section à l'autre ; approcher la
  /// vraie longueur évite un saut au moment où le texte s'affiche.
  final double titleWidth;
  final int cardCount;

  const OffersCarouselSkeleton({
    super.key,
    this.titleWidth = 120,
    this.cardCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppDimens.appPadding,
          child: Bone.text(
            width: titleWidth,
            style: Theme.of(context).textTheme.titleMedium!,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: OffersCarouselSection.railHeight(context),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: AppDimens.appPadding,
            itemCount: cardCount,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, _) => const SizedBox(
              width: OffersCarouselSection.cardWidth,
              child: OfferCardSkeleton(),
            ),
          ),
        ),
      ],
    );
  }
}
