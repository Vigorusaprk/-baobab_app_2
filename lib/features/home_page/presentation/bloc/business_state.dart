part of 'business_bloc.dart';

abstract class BusinessState extends Equatable {
  const BusinessState();

  @override
  List<Object> get props => [];
}

class BusinessInitial extends BusinessState {}

class BusinessLoading extends BusinessState {}

/// Page d'accueil chargée pour [currentSlug].
///
/// Les trois sections viennent telles quelles de `get-home` : déjà filtrées
/// sur la catégorie, triées et tronquées côté serveur. Elles ne montrent
/// délibérément pas la même chose — auparavant les trois affichaient des
/// commerçants, donc sur une catégorie n'en comptant qu'un, on lisait trois
/// fois le même nom.
class BusinessLoaded extends BusinessState {
  /// « Quoi de neuf ? » — offres récentes.
  final List<Offer> newOffers;

  /// Reste-t-il des nouveautés au-delà de ce que le carrousel montre ?
  /// Commande l'affichage du bouton « Voir plus » en fin de liste.
  final bool hasMoreNewOffers;

  /// « À la une » — les commerçants en campagne, section à part.
  final List<FeaturedBusiness> featuredBusinesses;

  /// « Nouveaux sur Baobabe » — inscrits depuis moins de 30 jours.
  final List<Business> newBusinesses;

  /// « Les mieux notés » — le corps de l'accueil.
  final List<Business> popularBusinesses;

  /// « Quoi prendre ? » — les offres les mieux notées, en scroll infini.
  final List<Offer> discoverOffers;

  final String currentSlug;

  /// Dernière page chargée des nouveautés, et chargement en cours.
  final int newOffersPage;
  final bool isLoadingMoreNewOffers;

  /// Dernière page chargée de « Découvrir ».
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  const BusinessLoaded({
    this.newOffers = const [],
    this.hasMoreNewOffers = false,
    this.featuredBusinesses = const [],
    this.newBusinesses = const [],
    this.popularBusinesses = const [],
    this.discoverOffers = const [],
    this.newOffersPage = 1,
    this.isLoadingMoreNewOffers = false,
    required this.currentSlug,
    this.page = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  BusinessLoaded copyWith({
    List<Offer>? newOffers,
    bool? hasMoreNewOffers,
    List<FeaturedBusiness>? featuredBusinesses,
    List<Business>? newBusinesses,
    List<Business>? popularBusinesses,
    List<Offer>? discoverOffers,
    int? newOffersPage,
    bool? isLoadingMoreNewOffers,
    String? currentSlug,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return BusinessLoaded(
      newOffers: newOffers ?? this.newOffers,
      hasMoreNewOffers: hasMoreNewOffers ?? this.hasMoreNewOffers,
      featuredBusinesses: featuredBusinesses ?? this.featuredBusinesses,
      newBusinesses: newBusinesses ?? this.newBusinesses,
      popularBusinesses: popularBusinesses ?? this.popularBusinesses,
      discoverOffers: discoverOffers ?? this.discoverOffers,
      newOffersPage: newOffersPage ?? this.newOffersPage,
      isLoadingMoreNewOffers:
          isLoadingMoreNewOffers ?? this.isLoadingMoreNewOffers,
      currentSlug: currentSlug ?? this.currentSlug,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [
    newOffers,
    hasMoreNewOffers,
    featuredBusinesses,
    newBusinesses,
    popularBusinesses,
    discoverOffers,
    newOffersPage,
    isLoadingMoreNewOffers,
    currentSlug,
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
