import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:equatable/equatable.dart';
import 'offer_search_filters.dart';

/// Critères partagés entre commerces et offres dans le même flux.
class DiscoverFilters extends Equatable {
  const DiscoverFilters({
    this.openNow = false,
    this.fulfilment,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.sort = OfferSort.relevance,
  });

  final bool openNow;
  final Fulfilment? fulfilment;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final OfferSort sort;

  int get facetCount => (openNow ? 1 : 0) +
      (fulfilment == null ? 0 : 1) +
      (minPrice == null && maxPrice == null ? 0 : 1) +
      (minRating == null ? 0 : 1);

  Map<String, String> get businessParameters => {
    if (openNow) 'openNow': 'true',
    if (fulfilment == Fulfilment.order) 'canOrder': 'true',
    if (fulfilment == Fulfilment.booking) 'canBook': 'true',
    if (fulfilment == Fulfilment.inStore) 'inStore': 'true',
  };

  Map<String, String> get offerParameters => {
    if (fulfilment != null) 'fulfilment': fulfilment!.apiValue,
    if (minPrice != null) 'minPrice': '${minPrice!.round()}',
    if (maxPrice != null) 'maxPrice': '${maxPrice!.round()}',
    if (minRating != null) 'minRating': '$minRating',
    if (sort.apiValue != null) 'sort': sort.apiValue!,
  };

  DiscoverFilters copyWith({
    bool? openNow,
    Fulfilment? fulfilment,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    OfferSort? sort,
    bool clearFulfilment = false,
    bool clearPrice = false,
    bool clearRating = false,
  }) => DiscoverFilters(
    openNow: openNow ?? this.openNow,
    fulfilment: clearFulfilment ? null : (fulfilment ?? this.fulfilment),
    minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
    maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
    minRating: clearRating ? null : (minRating ?? this.minRating),
    sort: sort ?? this.sort,
  );

  @override
  List<Object?> get props => [openNow, fulfilment, minPrice, maxPrice, minRating, sort];
}
