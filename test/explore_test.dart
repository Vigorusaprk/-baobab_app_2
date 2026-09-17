import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/data/explore_api_service.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_search_filters.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/businesses_page.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/home_feed.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/offer_search_filters.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/explore_cubit.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/offers_search_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

/// Explorer cherche des **commerces** ; « Toutes les offres » cherche des
/// offres. Les deux font chercher **au serveur**.
///
/// Explorer a un jour chargé cinquante commerçants puis les a filtrés en
/// Dart : au-delà de la première page le filtrage ne portait que sur ce qui
/// était déjà reçu. Un critère qui coexiste avec du défilement infini se
/// filtre au serveur, jamais sur la page déjà chargée.

class _FakeApi implements ExploreApiService {
  _FakeApi({this.pages = const {}, this.fail = false});

  /// Réponse par numéro de page.
  final Map<int, OffersPage> pages;
  bool fail;

  final List<OfferSearchFilters> calls = [];
  final List<int> requestedPages = [];

  @override
  Future<OffersPage> search(OfferSearchFilters filters, {int page = 1}) async {
    calls.add(filters);
    requestedPages.add(page);
    if (fail) throw Exception('réseau indisponible');
    return pages[page] ?? const OffersPage();
  }

  /// Réponse par numéro de page, côté commerces.
  final Map<int, BusinessesPage> businessPages = {};
  final List<BusinessSearchFilters> businessCalls = [];

  @override
  Future<BusinessesPage> searchBusinesses(
    BusinessSearchFilters filters, {
    int page = 1,
  }) async {
    businessCalls.add(filters);
    if (fail) throw Exception('réseau indisponible');
    return businessPages[page] ??
        const BusinessesPage(items: [], hasMore: false);
  }
}

Business _business(String name) => Business(
  id: name,
  name: name,
  address: 'Gombe',
  description: '',
  bgImg: '',
  profilImg: '',
  rating: 4,
  reviewCount: 2,
  openingHours: const {},
  type: BusinessType.restaurant,
  phone: '',
  images: const [],
  specificData: const {},
  reviews: const [],
  isFavorite: false,
  isSponsored: false,
  createdAt: DateTime(2026),
);

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

  group('Explorer : des commerces', () {
    test("Explorer s'ouvre sur les commerces, et rien d'autre", () async {
      final api = _FakeApi();
      api.businessPages[1] = BusinessesPage(
        items: [_business('Chez Flore')],
        hasMore: false,
      );
      final cubit = ExploreCubit(api: api);

      await cubit.start();

      expect(cubit.state.businesses.map((b) => b.name), ['Chez Flore']);
      // Les offres ne sont jamais interrogées depuis Explorer.
      expect(api.calls, isEmpty);
      await cubit.close();
    });

    test('la frappe est temporisée, puis part au serveur', () async {
      final api = _FakeApi();
      final cubit = ExploreCubit(api: api);
      await cubit.start();

      cubit.queryChanged('r');
      cubit.queryChanged('ri');
      cubit.queryChanged('riz');
      expect(api.businessCalls, hasLength(1));

      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(api.businessCalls, hasLength(2));
      expect(api.businessCalls.last.query, 'riz');
      await cubit.close();
    });

    test('un critère de commerce part en base', () {
      const filters = BusinessSearchFilters(
        query: 'riz',
        categorySlug: 'restaurant',
        openNow: true,
        canBook: true,
      );
      expect(filters.toQueryParameters(), {
        'q': 'riz',
        'category': 'restaurant',
        'openNow': 'true',
        'canBook': 'true',
      });
    });

    test('la pastille compte les critères, pas la recherche', () {
      expect(const BusinessSearchFilters(query: 'riz').facetCount, 0);
      expect(
        const BusinessSearchFilters(openNow: true, canOrder: true).facetCount,
        2,
      );
      // Effacer garde la recherche et la catégorie : on affine, on ne
      // recommence pas.
      final cleared = const BusinessSearchFilters(
        query: 'riz',
        categorySlug: 'spa',
        inStore: true,
      ).clearedFacets();
      expect(cleared.query, 'riz');
      expect(cleared.categorySlug, 'spa');
      expect(cleared.hasFacets, isFalse);
    });

    test(
      "« Voir tout » de l'accueil pose la catégorie avant d'arriver",
      () async {
        final api = _FakeApi();
        final cubit = ExploreCubit(api: api);

        await cubit.categorySelected('restaurant');
        expect(api.businessCalls.last.categorySlug, 'restaurant');

        // `start()` à l'arrivée sur l'onglet ne recharge pas par-dessus.
        await cubit.start();
        expect(api.businessCalls, hasLength(1));

        await cubit.categorySelected('all');
        expect(cubit.state.filters.categorySlug, isNull);
        await cubit.close();
      },
    );

    test("un échec donne un message écrit, jamais l'exception", () async {
      final cubit = ExploreCubit(api: _FakeApi(fail: true));

      await cubit.start();

      expect(cubit.state.status, ExploreStatus.failure);
      expect(cubit.state.message, isNot(contains('Exception')));
      expect(cubit.state.message, contains('connexion'));
      await cubit.close();
    });
  });

  group('Toutes les offres', () {
    test("la catégorie de l'accueil arrive par la route", () async {
      final api = _FakeApi(
        pages: {
          1: _page(['a']),
        },
      );
      final cubit = OffersSearchCubit(api: api, categorySlug: 'restaurant');

      await cubit.start();
      expect(api.calls.last.categorySlug, 'restaurant');

      // « all » n'est pas une catégorie : il ne part pas au serveur.
      final tout = OffersSearchCubit(api: api, categorySlug: 'all');
      await tout.start();
      expect(api.calls.last.categorySlug, isNull);

      await cubit.close();
      await tout.close();
    });

    test('choisir « Tout » retire la catégorie au lieu de la poser', () async {
      final api = _FakeApi(
        pages: {
          1: _page(['a']),
        },
      );
      final cubit = OffersSearchCubit(api: api);

      await cubit.categorySelected('restaurant');
      expect(cubit.state.filters.categorySlug, 'restaurant');

      await cubit.categorySelected('all');
      expect(cubit.state.filters.categorySlug, isNull);

      await cubit.close();
    });

    test("la page suivante s'ajoute, elle ne remplace pas", () async {
      final api = _FakeApi(
        pages: {
          1: _page(['a', 'b'], hasMore: true),
          2: _page(['c']),
        },
      );
      final cubit = OffersSearchCubit(api: api);

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
      final cubit = OffersSearchCubit(api: api);

      await cubit.start();
      await cubit.loadMore();

      expect(api.requestedPages, [1]);
      await cubit.close();
    });

    test("un échec donne un message écrit, jamais l'exception", () async {
      final cubit = OffersSearchCubit(api: _FakeApi(fail: true));

      await cubit.start();

      expect(cubit.state.status, OffersSearchStatus.failure);
      expect(cubit.state.message, isNotNull);
      expect(cubit.state.message, isNot(contains('Exception')));
      expect(cubit.state.message, contains('connexion'));

      await cubit.close();
    });

    test("une page suivante ratée n'efface pas ce qui est affiché", () async {
      // Le cas est réel : on fait défiler dans le métro, la requête tombe.
      // Perdre les résultats déjà lus serait pire que ne rien ajouter.
      final api = _FakeApi(
        pages: {
          1: _page(['a', 'b'], hasMore: true),
        },
      );
      final cubit = OffersSearchCubit(api: api);
      await cubit.start();

      api.fail = true;
      await cubit.loadMore();

      expect(cubit.state.offers, hasLength(2));
      expect(cubit.state.hasMore, isFalse);
      await cubit.close();
    });
  });
}
