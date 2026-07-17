import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/search_filter_entity.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_event.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_state.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/search_active_filters_bar.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/search_bar.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/search_filter_sheet.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/search_results_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter_svg/svg.dart';

import '../../../main/presentation/widgets/app_background.dart';

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
    return authBackground(
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
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.canvasBackground,),
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
                      padding: EdgeInsets.symmetric(horizontal: AppDimens.PADDING_10, vertical: AppDimens.PADDING_10),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryLight,
                        borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_50)
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/filter.svg',
                        height: 25,
                        width: 25,
                        colorFilter: const ColorFilter.mode(
                          AppColors.canvasBackground,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filtres actifs
              BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchResultsLoaded && state.activeFilters.hasActiveFilters) {
                    return SearchActiveFiltersBar(filters: state.activeFilters, searchBloc: _searchBloc);
                  } else if (state is SearchLoading && state.activeFilters != null && state.activeFilters!.hasActiveFilters) {
                    return SearchActiveFiltersBar(filters: state.activeFilters!, searchBloc: _searchBloc);
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
                        return SearchResultsList(
                          state: SearchResultsLoaded(
                            results: state.previousResults!,
                            activeFilters: state.activeFilters ?? const SearchFilterEntity(),
                            hasReachedMax: false,
                          ),
                          scrollController: _scrollController,
                          searchBloc: _searchBloc,
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
                      return SearchResultsList(
                        state: state,
                        scrollController: _scrollController,
                        searchBloc: _searchBloc,
                      );
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
            Icon(icon, size: 80, color: AppColors.canvasBackground),
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
