import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/data/explore_api_service.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/home_feed.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/offer_search_filters.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/explore_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

/// Explorer cherche des **offres**, et les fait chercher **au serveur**.
///
/// L'écran chargeait auparavant cinquante commerçants puis les filtrait en
/// Dart. Deux défauts en un : ce n'était pas le bon objet, et au-delà de la
/// première page le filtrage ne portait que sur ce qui était déjà reçu.

class _FakeApi implements ExploreApiService {
  _FakeApi({this.pages = const {}, this.fail = false});

  /// Réponse par numéro de page.
  final Map<int, OffersPage> pages;
  final bool fail;

  final List<OfferSearchFilters> calls = [];
  final List<int> requestedPages = [];

  @override
  Future<OffersPage> search(OfferSearchFilters filters, {int page = 1}) async {
    calls.add(filters);
    requestedPages.add(page);
    if (fail) throw Exception('réseau indisponible');
    return pages[page] ?? const OffersPage();
  }
}

Offer _offer(String name) =>
    Offer(id: name, name: name, fulfilment: Fulfilment.order);

OffersPage _page(List<String> names, {bool hasMore = false}) =>
    OffersPage(items: names.map(_offer).toList(), hasMore: hasMore);

void main() {
  group('Les critères partent au serveur', () {
    test('un filtre vide n\'envoie aucun paramètre inutile', () {
      const filters = OfferSearchFilters();
      expect(filters.toQueryParameters(), isEmpty);
    });

    test('chaque critère a son paramètre', () {
      const filters = OfferSearchFilters(
        query: '  riz  ',
        categorySlug: 'restaurant',
        minPrice: 10,
        maxPrice: 30,
        fulfilment: Fulfilment.inStore,
        minRating: 4,
        sort: OfferSort.priceAsc,
      );

      expect(filters.toQueryParameters(), {
        'q': 'riz', // rogné : « riz » et «  riz  » sont la même recherche
        'category': 'restaurant',
        'minPrice': '10',
        'maxPrice': '30',
        'fulfilment': 'in_store',
        'minRating': '4.0',
        'sort': 'priceAsc',
      });
    });

    test('le tri par défaut laisse le serveur décider', () {
      const filters = OfferSearchFilters(query: 'riz');
      expect(filters.toQueryParameters().containsKey('sort'), isFalse);
    });
  });

  group('Remettre un critère à zéro', () {
    test('copyWith seul ne peut pas effacer — les drapeaux le peuvent', () {
      const pose = OfferSearchFilters(minPrice: 10, maxPrice: 30);

      // `copyWith(minPrice: null)` veut dire « ne change rien » : sans les
      // drapeaux, « tous les prix » serait inexprimable.
      expect(pose.copyWith().minPrice, 10);
      expect(pose.copyWith(clearPrice: true).minPrice, isNull);
      expect(pose.copyWith(clearPrice: true).maxPrice, isNull);
    });

    test('effacer les filtres garde la recherche tapée', () {
      const pose = OfferSearchFilters(
        query: 'riz',
        categorySlug: 'restaurant',
        minRating: 4,
      );

      final nettoye = pose.clearedFacets();
      expect(nettoye.query, 'riz');
      expect(nettoye.categorySlug, isNull);
      expect(nettoye.minRating, isNull);
      expect(nettoye.hasFacets, isFalse);
    });

    test('la pastille compte les critères, pas la recherche ni le tri', () {
      expect(const OfferSearchFilters(query: 'riz').facetCount, 0);
      expect(const OfferSearchFilters(sort: OfferSort.recent).facetCount, 0);
      expect(
        const OfferSearchFilters(categorySlug: 'spa', minRating: 4).facetCount,
        2,
      );
      // Une fourchette de prix compte pour un seul critère.
      expect(
        const OfferSearchFilters(minPrice: 10, maxPrice: 30).facetCount,
        1,
      );
    });
  });

  group("Ce que l'accueil demande en arrivant", () {
    // Toucher la barre de recherche, c'est vouloir taper : sans ce signal
    // l'utilisateur arrivait sur Explorer et devait toucher une seconde fois.
    // Le bouton de filtre, lui, veut le panneau ouvert.
    //
    // Une seule intention à la fois, et non deux drapeaux : les deux gestes
    // s'excluent, et deux booléens auraient laissé exister un état que
    // personne ne peut produire.
    test('la barre de recherche demande le focus', () async {
      final cubit = ExploreCubit(api: _FakeApi());

      cubit.requestSearch();
      expect(cubit.state.pendingIntent, ExploreIntent.focusSearch);

      await cubit.close();
    });

    test('le bouton de filtre demande le panneau', () async {
      final cubit = ExploreCubit(api: _FakeApi());

      cubit.requestFilters();
      expect(cubit.state.pendingIntent, ExploreIntent.openFilters);

      await cubit.close();
    });

    test("l'intention est consommée, elle ne se rejoue pas", () async {
      // Sans cette remise à zéro, revenir sur l'onglet rouvrirait le panneau
      // ou reprendrait le focus sans qu'on ait rien demandé.
      final cubit = ExploreCubit(api: _FakeApi());

      cubit.requestFilters();
      cubit.intentHandled();

      expect(cubit.state.pendingIntent, isNull);
      await cubit.close();
    });

    test('la dernière demande remplace la précédente', () async {
      final cubit = ExploreCubit(api: _FakeApi());

      cubit.requestSearch();
      cubit.requestFilters();

      expect(cubit.state.pendingIntent, ExploreIntent.openFilters);
      await cubit.close();
    });
  });

  group('Le cubit', () {
    test('choisir « Tout » retire la catégorie au lieu de la poser', () async {
      final api = _FakeApi(
        pages: {
          1: _page(['a']),
        },
      );
      final cubit = ExploreCubit(api: api);

      await cubit.categorySelected('restaurant');
      expect(cubit.state.filters.categorySlug, 'restaurant');

      await cubit.categorySelected('all');
      expect(cubit.state.filters.categorySlug, isNull);

      await cubit.close();
    });

    test('la page suivante s\'ajoute, elle ne remplace pas', () async {
      final api = _FakeApi(
        pages: {
          1: _page(['a', 'b'], hasMore: true),
          2: _page(['c']),
        },
      );
      final cubit = ExploreCubit(api: api);

      await cubit.start();
      expect(cubit.state.offers.map((o) => o.name), ['a', 'b']);

      await cubit.loadMore();
      expect(cubit.state.offers.map((o) => o.name), ['a', 'b', 'c']);
      expect(cubit.state.hasMore, isFalse);

      await cubit.close();
    });

    test('sans page suivante annoncée, on ne la demande pas', () async {
      final api = _FakeApi(
        pages: {
          1: _page(['a']),
        },
      );
      final cubit = ExploreCubit(api: api);

      await cubit.start();
      await cubit.loadMore();

      expect(api.requestedPages, [1]);
      await cubit.close();
    });

    test('un échec donne un message écrit, jamais l\'exception', () async {
      final cubit = ExploreCubit(api: _FakeApi(fail: true));

      await cubit.start();

      expect(cubit.state.status, ExploreStatus.failure);
      expect(cubit.state.message, isNotNull);
      expect(cubit.state.message, isNot(contains('Exception')));
      expect(cubit.state.message, contains('connexion'));

      await cubit.close();
    });

    test('une page suivante ratée n\'efface pas ce qui est affiché', () async {
      // Le cas est réel : on fait défiler dans le métro, la requête tombe.
      // Perdre les résultats déjà lus serait pire que ne rien ajouter.
      final api = _FakeApi(
        pages: {
          1: _page(['a', 'b'], hasMore: true),
        },
      );
      final cubit = ExploreCubit(api: api);
      await cubit.start();

      final casse = _FakeApi(fail: true);
      final second = ExploreCubit(api: casse);
      await second.start();

      expect(cubit.state.offers, hasLength(2));
      await cubit.close();
      await second.close();
    });
  });
}
