part of 'all_offers_screen.dart';

/// La grille des offres : deux colonnes, défilement infini.
class _OfferResults extends StatelessWidget {
  const _OfferResults({
    required this.state,
    required this.scroll,
    required this.ratio,
    required this.onRetry,
    required this.onClearFilters,
  });

  final OffersSearchState state;
  final ScrollController scroll;
  final double ratio;
  final VoidCallback onRetry;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    if (state.status == OffersSearchStatus.failure) {
      return SearchMessage(
        key: const ValueKey('echec'),
        title: 'La recherche a échoué',
        body: state.message ?? 'Réessayez dans un instant.',
        actionLabel: 'Réessayer',
        onAction: onRetry,
      );
    }

    final loading =
        state.status == OffersSearchStatus.loading ||
        state.status == OffersSearchStatus.initial;

    if (loading && state.offers.isEmpty) {
      return Skeletonizer(
        key: const ValueKey('squelette'),
        enabled: true,
        child: GridView.builder(
          padding: AppDimens.appPadding,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: _delegate,
          itemCount: 6,
          itemBuilder: (_, _) => const OfferCardSkeleton(),
        ),
      );
    }

    if (state.offers.isEmpty) {
      return SearchMessage(
        key: const ValueKey('vide'),
        title: 'Aucune offre ne correspond',
        body: state.filters.hasFacets
            ? 'Essayez d\'élargir vos filtres.'
            : 'Essayez un autre mot.',
        actionLabel: state.filters.hasFacets ? 'Effacer les filtres' : null,
        onAction: state.filters.hasFacets ? onClearFilters : null,
      );
    }

    return CustomRefresh(
      key: const ValueKey('resultats'),
      onRefresh: context.read<OffersSearchCubit>().retry,
      child: GridView.builder(
        controller: scroll,
        padding: AppDimens.appPadding.copyWith(
          top: AppDimens.small,
          bottom: AppDimens.large,
        ),
        gridDelegate: _delegate,
        itemCount: state.offers.length + (state.loadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= state.offers.length) {
            return const Skeletonizer(
              enabled: true,
              child: OfferCardSkeleton(),
            );
          }
          final offer = state.offers[index];
          // Voir le carrousel de l'accueil : la carte remplace un squelette de
          // même forme, elle n'a donc pas à entrer en scène.
          return OfferCard(
            offer: offer,
            onTap: () => context.pushNamed(
              'offerDetail',
              pathParameters: {'id': offer.id},
              // Le mode voyage avec l'identifiant : le squelette de la fiche
              // prend la forme de la fiche qui va s'afficher.
              extra: offer.fulfilment,
            ),
          );
        },
      ),
    );
  }

  SliverGridDelegate get _delegate => SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: ratio,
    mainAxisSpacing: AppDimens.allPadding12Number,
    crossAxisSpacing: AppDimens.allPadding12Number,
  );
}
