import 'package:baobabe_0_2/core/errors/exeptions.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/search_filter_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/search_repository.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_event.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/search_state.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository searchRepository;
  static const int _resultsPerPage = 10;
  SearchFilterEntity _currentFilters = const SearchFilterEntity();

  SearchBloc({required this.searchRepository}) : super(SearchInitial()) {
    on<SearchInitialized>(_onSearchInitialized);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchFiltersChanged>(_onSearchFiltersChanged);
    on<SearchClearFilters>(_onSearchClearFilters);
    on<LoadMoreResults>(_onLoadMoreResults);
  }

  Future<void> _onSearchInitialized(
      SearchInitialized event,
      Emitter<SearchState> emit,
      ) async {
    emit(SearchLoading(activeFilters: _currentFilters));
    try {
      final results = await searchRepository.searchBusinesses(_currentFilters);
      emit(SearchResultsLoaded(
        results: results.take(_resultsPerPage).toList(),
        activeFilters: _currentFilters,
        hasReachedMax: results.length <= _resultsPerPage,
      ));
    } on CacheExeption catch (e) {
      emit(SearchError(message: e.message));
    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }

  Future<void> _onSearchQueryChanged(
      SearchQueryChanged event,
      Emitter<SearchState> emit,
      ) async {
    _currentFilters = _currentFilters.copyWith(query: event.query);
    if (state is SearchResultsLoaded) {
      final currentState = state as SearchResultsLoaded;
      emit(SearchLoading(previousResults: currentState.results, activeFilters: _currentFilters));
    } else {
      emit(SearchLoading(activeFilters: _currentFilters));
    }
    try {
      final results = await searchRepository.searchBusinesses(_currentFilters);
      emit(SearchResultsLoaded(
        results: results.take(_resultsPerPage).toList(),
        activeFilters: _currentFilters,
        hasReachedMax: results.length <= _resultsPerPage,
      ));
    } on CacheExeption catch (e) {
      emit(SearchError(message: e.message));
    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }

  Future<void> _onSearchFiltersChanged(
      SearchFiltersChanged event,
      Emitter<SearchState> emit,
      ) async {
    _currentFilters = event.filters;
    if (state is SearchResultsLoaded) {
      final currentState = state as SearchResultsLoaded;
      emit(SearchLoading(previousResults: currentState.results, activeFilters: _currentFilters));
    } else {
      emit(SearchLoading(activeFilters: _currentFilters));
    }
    try {
      final results = await searchRepository.searchBusinesses(_currentFilters);
      emit(SearchResultsLoaded(
        results: results.take(_resultsPerPage).toList(),
        activeFilters: _currentFilters,
        hasReachedMax: results.length <= _resultsPerPage,
      ));
    } on CacheExeption catch (e) {
      emit(SearchError(message: e.message));
    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }

  Future<void> _onSearchClearFilters(
      SearchClearFilters event,
      Emitter<SearchState> emit,
      ) async {
    _currentFilters = const SearchFilterEntity();
    emit(SearchLoading(activeFilters: _currentFilters));
    try {
      final results = await searchRepository.searchBusinesses(_currentFilters);
      emit(SearchResultsLoaded(
        results: results.take(_resultsPerPage).toList(),
        activeFilters: _currentFilters,
        hasReachedMax: results.length <= _resultsPerPage,
      ));
    } on CacheExeption catch (e) {
      emit(SearchError(message: e.message));
    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreResults(
      LoadMoreResults event,
      Emitter<SearchState> emit,
      ) async {
    if (state is SearchResultsLoaded) {
      final currentState = state as SearchResultsLoaded;
      if (currentState.hasReachedMax) return;

      emit(SearchLoading(
        previousResults: currentState.results,
        activeFilters: currentState.activeFilters,
      ));

      try {
        final allResults = await searchRepository.searchBusinesses(_currentFilters);
        final currentCount = currentState.results.length;
        final newResults = allResults.skip(currentCount).take(_resultsPerPage).toList();
        final updatedResults = [...currentState.results, ...newResults];

        emit(SearchResultsLoaded(
          results: updatedResults,
          activeFilters: _currentFilters,
          hasReachedMax: updatedResults.length >= allResults.length,
        ));
      } on CacheExeption catch (e) {
        emit(SearchError(message: e.message));
      } catch (e) {
        emit(SearchError(message: e.toString()));
      }
    }
  }
}