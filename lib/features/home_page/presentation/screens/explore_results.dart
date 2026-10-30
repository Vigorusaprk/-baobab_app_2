import 'package:baobabe_0_2/features/home_page/presentation/bloc/explore_cubit.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_sections.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/search_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'business_search_grid.dart';

/// Rend les états de chargement, vide, erreur et les résultats d'Explorer.
class ExploreResults extends StatelessWidget {
  const ExploreResults({
    super.key,
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
    return BusinessSearchGrid(
      businesses: state.businesses,
      scroll: scroll,
      loadingMore: state.loadingMore,
      onRefresh: context.read<ExploreCubit>().retry,
    );
  }
}
