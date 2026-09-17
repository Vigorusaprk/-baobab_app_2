import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';

/// Une page d'offres, avec l'information « y en a-t-il d'autres ? ».
class OffersPage {
  final List<Offer> items;
  final bool hasMore;

  const OffersPage({this.items = const [], this.hasMore = false});

  bool get isEmpty => items.isEmpty;
}

/// L'offre qu'une campagne visait, quand elle en visait une.
class FeaturedOffer {
  final String id;
  final String name;

  const FeaturedOffer({required this.id, required this.name});
}

/// Un commerçant à la une, et la campagne qui l'y a mis.
///
/// C'est toujours le **commerce** qui est à la une. Si la campagne visait une
/// offre précise, elle est nommée sur la carte et c'est elle que le toucher
/// ouvre — mais la vedette reste le commerçant.
class FeaturedBusiness {
  final Business business;
  final String campaignId;
  final FeaturedOffer? offer;

  const FeaturedBusiness({
    required this.business,
    required this.campaignId,
    this.offer,
  });
}

/// Contenu de la page d'accueil pour une catégorie, renvoyé par l'Edge
/// Function `get-home` en un seul appel.
///
/// L'accueil met en avant des **commerçants** : à la une, nouveaux, les
/// mieux notés. Les offres n'y gardent qu'un rail en bas et ont leur propre
/// page — Explorer, mode Offres.
class HomeFeed {
  /// « À la une » — les commerçants en campagne. Section à part, jamais
  /// mêlée aux autres.
  final List<FeaturedBusiness> featuredBusinesses;

  /// « Nouveaux sur Baobabe » — inscrits depuis moins de 30 jours.
  final List<Business> newBusinesses;

  /// « Les mieux notés » — le corps de la page.
  final List<Business> popularBusinesses;

  /// « Offres du moment » — un rail, en bas. Les offres ont leur page.
  final OffersPage newOffers;

  /// La page des offres (Explorer, mode Offres), paginée.
  final OffersPage discoverOffers;

  const HomeFeed({
    this.featuredBusinesses = const [],
    this.newBusinesses = const [],
    this.popularBusinesses = const [],
    this.newOffers = const OffersPage(),
    this.discoverOffers = const OffersPage(),
  });
}
