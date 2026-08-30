import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:equatable/equatable.dart';

/// L'ordre dans lequel Explorer présente les offres.
///
/// Les valeurs `apiValue` sont celles que `get-home` comprend ; `null` laisse
/// le serveur appliquer son ordre par défaut (les mieux notées).
enum OfferSort {
  relevance('Pertinence', null),
  recent('Plus récentes', 'recent'),
  rating('Mieux notées', 'rating'),
  priceAsc('Prix croissant', 'priceAsc'),
  priceDesc('Prix décroissant', 'priceDesc');

  const OfferSort(this.label, this.apiValue);

  final String label;
  final String? apiValue;
}

/// Ce que l'utilisateur a demandé à Explorer.
///
/// Tous ces critères sont appliqués **en base**, par `get-home`. Les filtrer
/// côté client ne porterait que sur la page déjà reçue : dès qu'on fait
/// défiler, le résultat serait faux.
class OfferSearchFilters extends Equatable {
  const OfferSearchFilters({
    this.query = '',
    this.categorySlug,
    this.minPrice,
    this.maxPrice,
    this.fulfilment,
    this.minRating,
    this.sort = OfferSort.relevance,
  });

  final String query;

  /// Le slug venu du serveur, pas une valeur d'énumération : les catégories
  /// sont créées en base et l'application n'en connaît pas la liste.
  final String? categorySlug;

  final double? minPrice;
  final double? maxPrice;
  final Fulfilment? fulfilment;
  final double? minRating;
  final OfferSort sort;

  /// Les seuls filtres que l'utilisateur pose depuis le panneau — la
  /// recherche textuelle et le tri ont leur propre place à l'écran.
  bool get hasFacets =>
      categorySlug != null ||
      minPrice != null ||
      maxPrice != null ||
      fulfilment != null ||
      minRating != null;

  bool get isEmpty =>
      query.isEmpty && !hasFacets && sort == OfferSort.relevance;

  /// Combien de critères sont posés, pour la pastille du bouton de filtres.
  int get facetCount => [
    categorySlug,
    minPrice ?? maxPrice,
    fulfilment,
    minRating,
  ].where((f) => f != null).length;

  /// `copyWith` ne peut pas remettre un critère à zéro — passer `null` veut
  /// dire « ne change rien ». Les remises à zéro passent donc par des drapeaux
  /// explicites, sans quoi « tous les prix » serait impossible à exprimer.
  OfferSearchFilters copyWith({
    String? query,
    String? categorySlug,
    double? minPrice,
    double? maxPrice,
    Fulfilment? fulfilment,
    double? minRating,
    OfferSort? sort,
    bool clearCategory = false,
    bool clearPrice = false,
    bool clearFulfilment = false,
    bool clearRating = false,
  }) {
    return OfferSearchFilters(
      query: query ?? this.query,
      categorySlug: clearCategory ? null : (categorySlug ?? this.categorySlug),
      minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
      fulfilment: clearFulfilment ? null : (fulfilment ?? this.fulfilment),
      minRating: clearRating ? null : (minRating ?? this.minRating),
      sort: sort ?? this.sort,
    );
  }

  /// Ce que garde la remise à zéro du panneau : la recherche tapée, qui n'est
  /// pas un filtre mais la question elle-même.
  OfferSearchFilters clearedFacets() => OfferSearchFilters(query: query);

  /// Les paramètres à joindre à l'appel `get-home`. Un critère absent est
  /// omis plutôt qu'envoyé vide : le serveur ignore ce qu'il ne reçoit pas.
  Map<String, String> toQueryParameters() => {
    if (query.trim().isNotEmpty) 'q': query.trim(),
    if (categorySlug != null && categorySlug!.isNotEmpty)
      'category': categorySlug!,
    if (minPrice != null) 'minPrice': '${minPrice!.round()}',
    if (maxPrice != null) 'maxPrice': '${maxPrice!.round()}',
    if (fulfilment != null) 'fulfilment': fulfilment!.apiValue,
    if (minRating != null) 'minRating': '$minRating',
    if (sort.apiValue != null) 'sort': sort.apiValue!,
  };

  @override
  List<Object?> get props => [
    query,
    categorySlug,
    minPrice,
    maxPrice,
    fulfilment,
    minRating,
    sort,
  ];
}
