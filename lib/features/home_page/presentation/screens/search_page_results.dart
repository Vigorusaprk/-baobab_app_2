part of 'search_page.dart';

/// Les commerces : deux tuiles par ligne, à la hauteur de leur texte — pas
/// une grille à ratio fixe, qui finirait par tronquer une pastille.
class _BusinessResults extends StatelessWidget {
  const _BusinessResults({
    required this.state,
    required this.scroll,
    required this.onRetry,
    required this.onClearFilters,
  });

  final ExploreState state;
  final ScrollController scroll;
  final VoidCallback onRetry;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    if (state.status == ExploreStatus.failure) {
      return SearchMessage(
        key: const ValueKey('echec'),
        title: 'La recherche a échoué',
        body: state.message ?? 'Réessayez dans un instant.',
        actionLabel: 'Réessayer',
        onAction: onRetry,
      );
    }

    final loading =
        state.status == ExploreStatus.loading ||
        state.status == ExploreStatus.initial;

    if (loading && state.businesses.isEmpty) {
      return const Skeletonizer(
        key: ValueKey('squelette'),
        enabled: true,
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: BusinessGridSkeleton(titleWidth: 0),
        ),
      );
    }

    if (state.businesses.isEmpty) {
      return SearchMessage(
        key: const ValueKey('vide'),
        title: 'Aucun commerce ne correspond',
        body: state.filters.hasFacets
            ? "Essayez d'élargir vos filtres."
            : 'Essayez un autre mot.',
        actionLabel: state.filters.hasFacets ? 'Effacer les filtres' : null,
        onAction: state.filters.hasFacets ? onClearFilters : null,
      );
    }

    final businesses = state.businesses;
    final rows = (businesses.length + 1) ~/ 2;

    return CustomRefresh(
      key: const ValueKey('resultats'),
      onRefresh: context.read<ExploreCubit>().retry,
      child: ListView.separated(
        controller: scroll,
        padding: AppDimens.appPadding.copyWith(
          top: AppDimens.small,
          bottom: AppDimens.large,
        ),
        itemCount: rows + (state.loadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, row) {
          if (row >= rows) {
            return const Skeletonizer(
              enabled: true,
              child: Row(
                children: [
                  Expanded(child: BusinessCardSkeleton.tile()),
                  SizedBox(width: 12),
                  Expanded(child: BusinessCardSkeleton.tile()),
                ],
              ),
            );
          }
          final left = businesses[row * 2];
          final right = row * 2 + 1 < businesses.length
              ? businesses[row * 2 + 1]
              : null;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: BusinessCard.tile(
                    business: left,
                    onTap: () => openBusiness(context, left),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: right == null
                      ? const SizedBox.shrink()
                      : BusinessCard.tile(
                          business: right,
                          onTap: () => openBusiness(context, right),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
