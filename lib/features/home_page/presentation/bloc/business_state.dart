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

  /// « Chez qui aller ? » — les meilleurs commerçants.
  final List<Business> popularBusinesses;

  /// « Quoi prendre ? » — les offres les mieux notées, en scroll infini.
  final List<Offer> discoverOffers;

  /// Les mises en avant payées, tenues à part : elles ne se mêlent à aucune
  /// autre section et portent leur étiquette.
  final List<SponsoredOffer> sponsoredOffers;

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
    this.popularBusinesses = const [],
    this.discoverOffers = const [],
    this.sponsoredOffers = const [],
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
    List<Business>? popularBusinesses,
    List<Offer>? discoverOffers,
    List<SponsoredOffer>? sponsoredOffers,
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
      popularBusinesses: popularBusinesses ?? this.popularBusinesses,
      discoverOffers: discoverOffers ?? this.discoverOffers,
      sponsoredOffers: sponsoredOffers ?? this.sponsoredOffers,
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
    popularBusinesses,
    discoverOffers,
    sponsoredOffers,
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
