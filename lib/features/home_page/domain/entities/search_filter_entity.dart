import 'package:equatable/equatable.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';

enum SortBy {
  relevance,
  ratingDesc,
  ratingAsc,
  priceDesc,
  priceAsc,
  newest,
}

extension SortByExtension on SortBy {
  String get displayName {
    switch (this) {
      case SortBy.relevance:
        return 'Pertinence';
      case SortBy.ratingDesc:
        return 'Meilleures notes';
      case SortBy.ratingAsc:
        return 'Moins bonnes notes';
      case SortBy.priceDesc:
        return 'Plus cher';
      case SortBy.priceAsc:
        return 'Moins cher';
      case SortBy.newest:
        return 'Plus récents';
    }
  }
}

class SearchFilterEntity extends Equatable {
  final String query;
  final BusinessType? category;
  final double? minRating;
  final String? location;
  final SortBy sortBy;

  const SearchFilterEntity({
    this.query = '',
    this.category,
    this.minRating,
    this.location,
    this.sortBy = SortBy.relevance,
  });

  SearchFilterEntity copyWith({
    String? query,
    BusinessType? category,
    double? minRating,
    String? location,
    SortBy? sortBy,
  }) {
    return SearchFilterEntity(
      query: query ?? this.query,
      category: category ?? this.category,
      minRating: minRating ?? this.minRating,
      location: location ?? this.location,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters {
    return query.isNotEmpty ||
        category != null ||
        minRating != null ||
        location != null ||
        sortBy != SortBy.relevance;
  }

  @override
  List<Object?> get props => [
    query,
    category,
    minRating,
    location,
    sortBy,
  ];
}