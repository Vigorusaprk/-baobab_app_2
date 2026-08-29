import 'package:baobabe_0_2/core/widgets/remote_image.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart'
    show Business;
import 'package:baobabe_0_2/features/home_page/domain/entities/search_filter_entity.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_state.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_event.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/list_skeletons.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/search_active_filters_bar.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:flutter/material.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/screens/business_detail_screen.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';

/// Rendu de l'état "résultats chargés" (en-tête + liste scrollable) de la
/// page de recherche. Extrait de search_page.dart pour garder ce fichier
/// concis ; comportement identique.
class SearchResultsList extends StatelessWidget {
  final SearchResultsLoaded state;
  final bool isLoadingMore;
  final ScrollController scrollController;
  final SearchBloc searchBloc;

  const SearchResultsList({
    super.key,
    required this.state,
    required this.scrollController,
    required this.searchBloc,
    this.isLoadingMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // En-tête avec nombre de résultats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '${state.results.length} résultat(s)',
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(AppDimens.radius10),
                ),
                child: _buildSortDropdown(context),
              ),
            ],
          ),
        ),

        // Liste des résultats
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: isLoadingMore || !state.hasReachedMax
                ? state.results.length + 1
                : state.results.length,
            itemBuilder: (context, index) {
              if (index >= state.results.length) {
                return _buildLoadingMore();
              }
              final business = state.results[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildBusinessCard(context, business),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Tuile de fin de liste pendant le chargement de la page suivante :
  /// exactement la forme de ce qui va s'y afficher, plutôt qu'un spinner
  /// qui ne dit rien de ce qui arrive.
  Widget _buildLoadingMore() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: SearchResultSkeleton(),
    );
  }

  Widget _buildSortDropdown(BuildContext context) {
    return DropdownButton<SortBy>(
      borderRadius: BorderRadius.circular(AppDimens.radius20),
      dropdownColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      value: state.activeFilters.sortBy,
      underline: const SizedBox(),
      items: SortBy.values.map((sortBy) {
        return DropdownMenuItem(value: sortBy, child: Text(sortBy.displayName));
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          searchBloc.add(
            SearchFiltersChanged(
              state.activeFilters.copyWith(sortBy: newValue),
            ),
          );
        }
      },
    );
  }

  Widget _buildBusinessCard(BuildContext context, Business business) {
    final uiBusiness = UIBusiness(business);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusinessDetailScreen(businessId: business.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 80,
                height: 80,
                child: RemoteImage(
                  url: business.bgImg,
                  fallback: ColoredBox(
                    color: uiBusiness
                        .categoryColor(context)
                        .withValues(alpha: 0.2),
                    child: Icon(
                      uiBusiness.categoryIcon,
                      color: uiBusiness.categoryColor(context),
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    style: Theme.of(context).textTheme.titleMedium!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: OtherTheme.of(context).rating,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        business.rating.toString(),
                        style: Theme.of(context).textTheme.bodySmall!,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: uiBusiness
                              .categoryColor(context)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          SearchActiveFiltersBar.categoryDisplayName(
                            business.type,
                          ),
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
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
    );
  }
}
