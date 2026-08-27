part of 'business_bloc.dart';

abstract class BusinessState extends Equatable {
  const BusinessState();

  @override
  List<Object> get props => [];
}

class BusinessInitial extends BusinessState {}

class BusinessLoading extends BusinessState {}

/// Page d'accueil chargée pour [currentSlug]. Les trois listes viennent
/// telles quelles de l'Edge Function `get-home` : elles sont déjà filtrées
/// sur cette catégorie, triées et tronquées côté serveur. Aucune vue ne
/// doit re-filtrer ou re-trier — changer de catégorie recharge le tout.
class BusinessLoaded extends BusinessState {
  /// Section "Découvrir" : la liste paginée (scroll infini).
  final List<Business> businesses;

  /// Slug de la catégorie affichée. `all` = aucun filtre.
  final String currentSlug;

  /// Section "Nouveautés" : établissements récents de la catégorie.
  final List<Business> newBusinesses;

  /// Section "Populaires" : meilleures notes de la catégorie.
  final List<Business> popularBusinesses;

  /// Numéro de la dernière page chargée pour ce flux (1 = premier chargement).
  final int page;

  /// S'il reste des pages à charger sur le serveur.
  final bool hasMore;

  /// Vrai pendant qu'une page suivante se charge en arrière-plan — permet à
  /// l'UI d'éviter de redemander LoadMoreBusinesses en boucle.
  final bool isLoadingMore;

  const BusinessLoaded({
    required this.businesses,
    required this.currentSlug,
    this.newBusinesses = const [],
    this.popularBusinesses = const [],
    this.page = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  BusinessLoaded copyWith({
    List<Business>? businesses,
    String? currentSlug,
    List<Business>? newBusinesses,
    List<Business>? popularBusinesses,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return BusinessLoaded(
      businesses: businesses ?? this.businesses,
      currentSlug: currentSlug ?? this.currentSlug,
      newBusinesses: newBusinesses ?? this.newBusinesses,
      popularBusinesses: popularBusinesses ?? this.popularBusinesses,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [
    businesses,
    currentSlug,
    newBusinesses,
    popularBusinesses,
    page,
    hasMore,
    isLoadingMore,
  ];
}

class BusinessError extends BusinessState {
  final String message;

  const BusinessError(this.message);

  @override
  List<Object> get props => [message];
}
