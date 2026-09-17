import 'package:equatable/equatable.dart';

/// Ce qu'on peut demander à l'annuaire des commerces.
///
/// Des critères qui parlent d'un **commerce**, pas d'une offre : ouvert
/// maintenant, on peut y commander, y réserver, y passer. Le prix et le tri
/// par prix, qui parlent d'une offre, restent aux [OfferSearchFilters] de la
/// page « Toutes les offres ».
///
/// Tous s'appliquent **en base** (`get-home?section=businesses`) : filtrer la
/// page reçue trouerait le défilement infini.
class BusinessSearchFilters extends Equatable {
  const BusinessSearchFilters({
    this.query = '',
    this.categorySlug,
    this.openNow = false,
    this.canOrder = false,
    this.canBook = false,
    this.inStore = false,
  });

  final String query;
  final String? categorySlug;
  final bool openNow;
  final bool canOrder;
  final bool canBook;
  final bool inStore;

  bool get hasFacets => openNow || canOrder || canBook || inStore;

  /// Le nombre de critères posés, pour la pastille du bouton de filtres.
  /// La recherche et la catégorie n'en font pas partie : elles se voient
  /// déjà, dans le champ et sur la bande.
  int get facetCount =>
      (openNow ? 1 : 0) +
      (canOrder ? 1 : 0) +
      (canBook ? 1 : 0) +
      (inStore ? 1 : 0);

  BusinessSearchFilters copyWith({
    String? query,
    String? categorySlug,
    bool clearCategory = false,
    bool? openNow,
    bool? canOrder,
    bool? canBook,
    bool? inStore,
  }) {
    return BusinessSearchFilters(
      query: query ?? this.query,
      categorySlug: clearCategory ? null : (categorySlug ?? this.categorySlug),
      openNow: openNow ?? this.openNow,
      canOrder: canOrder ?? this.canOrder,
      canBook: canBook ?? this.canBook,
      inStore: inStore ?? this.inStore,
    );
  }

  BusinessSearchFilters clearedFacets() =>
      BusinessSearchFilters(query: query, categorySlug: categorySlug);

  Map<String, String> toQueryParameters() => {
    if (query.trim().isNotEmpty) 'q': query.trim(),
    if (categorySlug != null && categorySlug!.isNotEmpty)
      'category': categorySlug!,
    if (openNow) 'openNow': 'true',
    if (canOrder) 'canOrder': 'true',
    if (canBook) 'canBook': 'true',
    if (inStore) 'inStore': 'true',
  };

  @override
  List<Object?> get props => [
    query,
    categorySlug,
    openNow,
    canOrder,
    canBook,
    inStore,
  ];
}
