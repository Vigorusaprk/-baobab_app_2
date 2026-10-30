import 'package:equatable/equatable.dart';
import '../../domain/entities/discover_entry.dart';
import '../../domain/entities/discover_filters.dart';

enum DiscoverStatus { initial, loading, ready, failure }

/// État en mémoire du flux, des offres écartées et des favoris locaux.
class DiscoverState extends Equatable {
  const DiscoverState({
    this.status = DiscoverStatus.initial,
    this.items = const [],
    this.categorySlug,
    this.filters = const DiscoverFilters(),
    this.hasMore = false,
    this.loadingMore = false,
    this.page = 1,
    this.message,
    this.savedIds = const {},
    this.skippedIds = const {},
  });

  final DiscoverStatus status;
  final List<DiscoverEntry> items;
  final String? categorySlug;
  final DiscoverFilters filters;
  final bool hasMore;
  final bool loadingMore;
  final int page;
  final String? message;
  final Set<String> savedIds;
  final Set<String> skippedIds;

  List<DiscoverEntry> get visibleItems => items
      .where((item) => !skippedIds.contains(item.id))
      .toList(growable: false);

  DiscoverState copyWith({
    DiscoverStatus? status,
    List<DiscoverEntry>? items,
    String? categorySlug,
    DiscoverFilters? filters,
    bool clearCategory = false,
    bool? hasMore,
    bool? loadingMore,
    int? page,
    String? message,
    bool clearMessage = false,
    Set<String>? savedIds,
    Set<String>? skippedIds,
  }) => DiscoverState(
    status: status ?? this.status,
    items: items ?? this.items,
    categorySlug: clearCategory ? null : (categorySlug ?? this.categorySlug),
    filters: filters ?? this.filters,
    hasMore: hasMore ?? this.hasMore,
    loadingMore: loadingMore ?? this.loadingMore,
    page: page ?? this.page,
    message: clearMessage ? null : (message ?? this.message),
    savedIds: savedIds ?? this.savedIds,
    skippedIds: skippedIds ?? this.skippedIds,
  );

  @override
  List<Object?> get props => [status, items, categorySlug, filters, hasMore, loadingMore, page, message, savedIds, skippedIds];
}
