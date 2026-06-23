import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/search_filter_entity.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_event.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_state.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/filter_chip.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/search_bar.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/search_filter_sheet.dart';
import 'package:baobabe_0_2/features/main/presentation/widgets/main_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/screens/business_detail_screen.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late SearchBloc _searchBloc;

  @override
  void initState() {
    super.initState();
    _searchBloc = context.read<SearchBloc>()..add(SearchInitialized());
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchBloc.add(SearchQueryChanged(_searchController.text));
  }

  void _onScroll() {
    if (_isBottom) {
      _searchBloc.add(LoadMoreResults());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return MainBackground(
      child: Scaffold(
        backgroundColor: AppColors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Barre de recherche fixe
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.secondaryLight,
                          borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_50)
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary,),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    SizedBox(width: 5,),
                    Expanded(
                      child: SearchAppBar(
                        controller: _searchController,
                        onSubmitted: (value) {
                          _searchBloc.add(SearchQueryChanged(value));
                        },
                      ),
                    ),

                    SizedBox(width: 5,),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondaryLight,
                        borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_50)
                      ),
                      child: IconButton(
                        icon: Icon(Icons.filter_list_rounded, color: AppColors.primary,),
                        onPressed: () => _showFilterSheet(context),
                      ),
                    ),
                  ],
                ),
              ),

              // Filtres actifs
              BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchResultsLoaded && state.activeFilters.hasActiveFilters) {
                    return _buildActiveFilters(state.activeFilters);
                  } else if (state is SearchLoading && state.activeFilters != null && state.activeFilters!.hasActiveFilters) {
                    return _buildActiveFilters(state.activeFilters!);
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Résultats
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchInitial) {
                      return _buildEmptyState('Recherchez un établissement', Icons.search);
                    } else if (state is SearchLoading) {
                      if (state.previousResults != null && state.previousResults!.isNotEmpty) {
                        return _buildResultsList(
                          SearchResultsLoaded(
                            results: state.previousResults!,
                            activeFilters: state.activeFilters ?? const SearchFilterEntity(),
                            hasReachedMax: false,
                          ),
                          isLoadingMore: true,
                        );
                      }
                      return _buildLoadingState();
                    } else if (state is SearchError) {
                      return _buildErrorState(state.message);
                    } else if (state is SearchResultsLoaded) {
                      if (state.results.isEmpty) {
                        return _buildEmptyState('Aucun résultat trouvé', Icons.search_off);
                      }
                      return _buildResultsList(state);
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilters(SearchFilterEntity filters) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (filters.category != null)
              FilterChipWidget(
                label: _getCategoryDisplayName(filters.category!),
                onRemoved: () {
                  _searchBloc.add(SearchFiltersChanged(filters.copyWith(category: null)));
                },
              ),
            if (filters.minRating != null)
              FilterChipWidget(
                label: 'Note ≥ ${filters.minRating}',
                onRemoved: () {
                  _searchBloc.add(SearchFiltersChanged(filters.copyWith(minRating: null)));
                },
              ),
            if (filters.location != null && filters.location!.isNotEmpty)
              FilterChipWidget(
                label: filters.location!,
                onRemoved: () {
                  _searchBloc.add(SearchFiltersChanged(filters.copyWith(location: null)));
                },
              ),
            if (filters.sortBy != SortBy.relevance)
              FilterChipWidget(
                label: 'Tri: ${filters.sortBy.displayName}',
                onRemoved: () {
                  _searchBloc.add(SearchFiltersChanged(filters.copyWith(sortBy: SortBy.relevance)));
                },
              ),
            TextButton(
              onPressed: () {
                _searchBloc.add(SearchClearFilters());
              },
              child: Text('Tout effacer', style: TextStyle(color: AppColors.secondary),),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryDisplayName(BusinessType type) {
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

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Erreur de recherche',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _searchBloc.add(SearchInitialized());
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(SearchResultsLoaded state, {bool isLoadingMore = false}) {
    return Column(
      children: [
        // En-tête avec nombre de résultats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '${state.results.length} résultat(s)',
                style: TextStyle(fontSize: 14, color: AppColors.secondary, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_10)
                ),
                  child: _buildSortDropdown(state),
              ),
            ],
          ),
        ),

        // Liste des résultats
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
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
                child: _buildBusinessCard(business),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingMore() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator(color: AppColors.secondary,)),
    );
  }

  Widget _buildSortDropdown(SearchResultsLoaded state) {
    return DropdownButton<SortBy>(
      borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_20),
      dropdownColor: AppColors.secondaryLight,
      style: TextStyle(color: AppColors.scaffoldBackground),
      value: state.activeFilters.sortBy,
      underline: const SizedBox(),
      items: SortBy.values.map((sortBy) {
        return DropdownMenuItem(
          value: sortBy,
          child: Text(sortBy.displayName),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          _searchBloc.add(SearchFiltersChanged(state.activeFilters.copyWith(sortBy: newValue)));
        }
      },
    );
  }

  Widget _buildBusinessCard(Business business) {
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                business.bgImg,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: uiBusiness.categoryColor.withOpacity(0.2),
                    child: Icon(uiBusiness.categoryIcon, color: uiBusiness.categoryColor, size: 40),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(business.rating.toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: uiBusiness.categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getCategoryDisplayName(business.type),
                          style: TextStyle(color: uiBusiness.categoryColor, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    business.address,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final state = _searchBloc.state;
    SearchFilterEntity currentFilters;

    if (state is SearchResultsLoaded) {
      currentFilters = state.activeFilters;
    } else if (state is SearchLoading && state.activeFilters != null) {
      currentFilters = state.activeFilters!;
    } else {
      currentFilters = const SearchFilterEntity();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SearchFilterSheet(
          currentFilters: currentFilters,
          onFiltersChanged: (filters) {
            _searchBloc.add(SearchFiltersChanged(filters));
            Navigator.pop(context);
          },
        );
      },
    );
  }
}