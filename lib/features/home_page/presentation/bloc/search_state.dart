import 'package:baobabe_0_2/features/home_page/domain/entities/search_filter_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {
  final List<Business>? previousResults;
  final SearchFilterEntity? activeFilters;

  const SearchLoading({this.previousResults, this.activeFilters});

  @override
  List<Object?> get props => [previousResults, activeFilters];
}

class SearchResultsLoaded extends SearchState {
  final List<Business> results;
  final SearchFilterEntity activeFilters;
  final bool hasReachedMax;

  const SearchResultsLoaded({
    required this.results,
    required this.activeFilters,
    this.hasReachedMax = false,
  });

  SearchResultsLoaded copyWith({
    List<Business>? results,
    SearchFilterEntity? activeFilters,
    bool? hasReachedMax,
  }) {
    return SearchResultsLoaded(
      results: results ?? this.results,
      activeFilters: activeFilters ?? this.activeFilters,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [results, activeFilters, hasReachedMax];
}

class SearchError extends SearchState {
  final String message;
  const SearchError({required this.message});
  @override
  List<Object> get props => [message];
}
