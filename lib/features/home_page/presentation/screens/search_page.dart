import 'package:baobabe_0_2/core/widgets/custom_card.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/search_filter_entity.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_event.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_state.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/search_active_filters_bar.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/search_bar.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/search_results_list.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/list_skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

/// Standalone route wrapper for `/search` (pushed on top of another page,
/// e.g. from Home's "voir tout"). Owns its own Scaffold since it lives
/// outside MainShell's single Scaffold. The Explore tab uses
/// [SearchPageBody] directly instead.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const SearchPageBody(showBackButton: true),
    );
  }
}

/// Body-only content shared by the Explore tab (inside MainShell) and the
/// standalone `/search` route ([SearchPage]).
class SearchPageBody extends StatefulWidget {
  const SearchPageBody({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  State<SearchPageBody> createState() => _SearchPageBodyState();
}

class _SearchPageBodyState extends State<SearchPageBody> {
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
    return SafeArea(
      child: Column(
        children: [
          // Barre de recherche fixe
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                if (widget.showBackButton)
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: CustomCard(
                      color: Theme.of(context).primaryColor,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLowest,
                      ),
                    ),
                  ),

                SizedBox(width: 5),
                Expanded(
                  child: SearchAppBar(
                    controller: _searchController,
                    onSubmitted: (value) {
                      _searchBloc.add(SearchQueryChanged(value));
                    },
                  ),
                ),

                SizedBox(width: 5),
                // Même destination que l'icône jumelle de l'accueil : c'est la
                // seule porte d'entrée du filtrage dans l'application. Sans
                // GestureDetector, elle était ici purement décorative.
                GestureDetector(
                  onTap: () => context.pushNamed('budgetFinder'),
                  child: Tooltip(
                    message: 'Trouver selon mon budget',
                    child: CustomCard(
                      color: Theme.of(context).primaryColor,
                      child: SvgPicture.asset(
                        'assets/icons/filter.svg',
                        height: 25,
                        width: 25,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.surface,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filtres actifs
          BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state is SearchResultsLoaded &&
                  state.activeFilters.hasActiveFilters) {
                return SearchActiveFiltersBar(
                  filters: state.activeFilters,
                  searchBloc: _searchBloc,
                );
              } else if (state is SearchLoading &&
                  state.activeFilters != null &&
                  state.activeFilters!.hasActiveFilters) {
                return SearchActiveFiltersBar(
                  filters: state.activeFilters!,
                  searchBloc: _searchBloc,
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Résultats
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchInitial) {
                  return _buildEmptyState(
                    "Cherchez un plat, un soin, un concert, "
                    "ou le nom d'un commerce.",
                    Icons.search,
                  );
                } else if (state is SearchLoading) {
                  if (state.previousResults != null &&
                      state.previousResults!.isNotEmpty) {
                    return SearchResultsList(
                      state: SearchResultsLoaded(
                        results: state.previousResults!,
                        activeFilters:
                            state.activeFilters ?? const SearchFilterEntity(),
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
                    return _buildEmptyState(
                      'Aucun résultat. '
                      'Essayez un autre mot, ou retirez un filtre.',
                      Icons.search_off,
                    );
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
    );
  }

  /// Squelette des résultats : la forme exacte des cartes à venir, plutôt
  /// que des rectangles gris de dimensions arbitraires.
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: SearchResultSkeleton(),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'La recherche a échoué',
              style: Theme.of(context).textTheme.bodyLarge!,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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
            Icon(icon, size: 80, color: Theme.of(context).colorScheme.surface),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
