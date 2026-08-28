import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';

/// Une page d'offres, avec l'information « y en a-t-il d'autres ? ».
class OffersPage {
  final List<Offer> items;
  final bool hasMore;

  const OffersPage({this.items = const [], this.hasMore = false});

  bool get isEmpty => items.isEmpty;
}

/// Contenu de la page d'accueil pour une catégorie, renvoyé par l'Edge
/// Function `get-home` en un seul appel.
///
/// Les trois sections répondent chacune à une question différente, et ne
/// montrent délibérément pas la même chose : elles affichaient auparavant
/// toutes les trois des commerçants, si bien qu'on ne pouvait pas les
/// distinguer — sur une catégorie ne comptant qu'un commerçant, on voyait
/// trois fois le même nom.
class HomeFeed {
  /// « Quoi de neuf ? » — offres publiées récemment. [OffersPage.hasMore]
  /// indique s'il en reste au-delà de ce que le carrousel montre.
  final OffersPage newOffers;

  /// « Chez qui aller ? » — les meilleurs commerçants.
  final List<Business> popularBusinesses;

  /// « Quoi prendre ? » — les offres les mieux notées, paginées.
  final OffersPage discoverOffers;

  const HomeFeed({
    this.newOffers = const OffersPage(),
    this.popularBusinesses = const [],
    this.discoverOffers = const OffersPage(),
  });
}
