part of 'business_bloc.dart';

abstract class BusinessState extends Equatable {
  const BusinessState();

  @override
  List<Object> get props => [];
}

class BusinessInitial extends BusinessState {}

class BusinessLoading extends BusinessState {}

class BusinessLoaded extends BusinessState {
  final List<Business> businesses;
  final BusinessType currentCategory;

  /// Cache non filtré (catégorie "all") maintenu par le bloc en parallèle
  /// de [businesses] — indépendant de la catégorie actuellement
  /// sélectionnée pour le carrousel "Découvrir". Sert de source pour tout
  /// ce qui doit refléter l'ensemble du catalogue plutôt que la vue
  /// filtrée courante (ex: la section "Populaires").
  final List<Business> allBusinesses;

  /// Numéro de la dernière page chargée pour ce flux (1 = premier chargement).
  final int page;

  /// S'il reste des pages à charger sur le serveur.
  final bool hasMore;

  /// Vrai pendant qu'une page suivante se charge en arrière-plan — permet à
  /// l'UI d'éviter de redemander LoadMoreBusinesses en boucle.
  final bool isLoadingMore;

  const BusinessLoaded({
    required this.businesses,
    required this.currentCategory,
    this.allBusinesses = const [],
    this.page = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  BusinessLoaded copyWith({
    List<Business>? businesses,
    BusinessType? currentCategory,
    List<Business>? allBusinesses,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return BusinessLoaded(
      businesses: businesses ?? this.businesses,
      currentCategory: currentCategory ?? this.currentCategory,
      allBusinesses: allBusinesses ?? this.allBusinesses,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [
    businesses,
    currentCategory,
    allBusinesses,
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
