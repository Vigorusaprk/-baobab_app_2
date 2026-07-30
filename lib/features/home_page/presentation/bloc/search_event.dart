import 'package:baobabe_0_2/features/home_page/domain/entities/search_filter_entity.dart';
import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchInitialized extends SearchEvent {}

class SearchQueryChanged extends SearchEvent {
  final String query;
  const SearchQueryChanged(this.query);
  @override
  List<Object> get props => [query];
}

class SearchFiltersChanged extends SearchEvent {
  final SearchFilterEntity filters;
  const SearchFiltersChanged(this.filters);
  @override
  List<Object> get props => [filters];
}

class SearchClearFilters extends SearchEvent {}

class LoadMoreResults extends SearchEvent {}
