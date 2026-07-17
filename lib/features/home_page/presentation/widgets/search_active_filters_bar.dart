import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart' show BusinessType;
import 'package:baobabe_0_2/features/home_page/domain/entities/search_filter_entity.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_event.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/filter_chip.dart';
import 'package:flutter/material.dart';

/// Affiche la ligne de puces des filtres actifs sur la page de recherche.
/// Extrait de search_page.dart pour garder ce fichier concis ; comportement
/// identique.
class SearchActiveFiltersBar extends StatelessWidget {
  final SearchFilterEntity filters;
  final SearchBloc searchBloc;

  const SearchActiveFiltersBar({
    super.key,
    required this.filters,
    required this.searchBloc,
  });

  static String categoryDisplayName(BusinessType type) {
    switch (type) {
      case BusinessType.restaurant:
        return 'Restaurants';
      case BusinessType.fastFood:
        return 'Fast Food';
      case BusinessType.shopping:
        return 'Shopping';
      case BusinessType.mall:
        return 'Centres Commerciaux';
      case BusinessType.hotel:
        return 'Hôtels';
      case BusinessType.carRental:
        return 'Location Voiture';
      case BusinessType.travelAgency:
        return 'Agences de voyages';
      case BusinessType.spa:
        return 'Sap';
      case BusinessType.cinema:
        return 'Cinema';
      default:
        return 'Autre';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (filters.category != null)
              FilterChipWidget(
                label: categoryDisplayName(filters.category!),
                onRemoved: () {
                  searchBloc.add(SearchFiltersChanged(filters.copyWith(category: null)));
                },
              ),
            if (filters.minRating != null)
              FilterChipWidget(
                label: 'Note ≥ ${filters.minRating}',
                onRemoved: () {
                  searchBloc.add(SearchFiltersChanged(filters.copyWith(minRating: null)));
                },
              ),
            if (filters.location != null && filters.location!.isNotEmpty)
              FilterChipWidget(
                label: filters.location!,
                onRemoved: () {
                  searchBloc.add(SearchFiltersChanged(filters.copyWith(location: null)));
                },
              ),
            if (filters.sortBy != SortBy.relevance)
              FilterChipWidget(
                label: 'Tri: ${filters.sortBy.displayName}',
                onRemoved: () {
                  searchBloc.add(SearchFiltersChanged(filters.copyWith(sortBy: SortBy.relevance)));
                },
              ),
            TextButton(
              onPressed: () {
                searchBloc.add(SearchClearFilters());
              },
              child: Text('Tout effacer', style: TextStyle(color: AppColors.secondary),),
            ),
          ],
        ),
      ),
    );
  }
}
