import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/businesses_page.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/business_repository.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses_page.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_list_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

Business _business(String id) => Business(
  id: id,
  name: 'Business $id',
  address: '',
  description: '',
  bgImg: '',
  profilImg: '',
  rating: 4,
  reviewCount: 1,
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

/// Dépôt factice : seule [getBusinessesPage] est utilisée par le cubit, le
/// reste de l'interface est comblé par `noSuchMethod`.
class _FakeRepository implements BusinessRepository {
  _FakeRepository(this._pages);

  /// Réponses successives, une par appel.
  final List<BusinessesPage Function()> _pages;

  final List<int> requestedPages = [];
  final List<String?> requestedCategories = [];
  final List<String?> requestedQueries = [];

  @override
  Future<BusinessesPage> getBusinessesPage({
    required int page,
    String? category,
    String? query,
  }) async {
    requestedPages.add(page);
    requestedCategories.add(category);
    requestedQueries.add(query);
    return _pages[requestedPages.length - 1]();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

BusinessListCubit _cubit(_FakeRepository repo) =>
    BusinessListCubit(getBusinessesPage: GetBusinessesPage(repo));

void main() {
  test('load() remplit la première page et transmet la catégorie', () async {
    final repo = _FakeRepository([
      () => BusinessesPage(
        items: [_business('1'), _business('2')],
        hasMore: true,
      ),
    ]);
    final cubit = _cubit(repo);

    await cubit.load('hotel');

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.businesses.map((b) => b.id), ['1', '2']);
    expect(cubit.state.page, 1);
    expect(cubit.state.hasMore, isTrue);
    expect(repo.requestedPages, [1]);
    expect(repo.requestedCategories, ['hotel']);
  });

  test(
    'loadMore() ajoute la page suivante sans perdre la précédente',
    () async {
      final repo = _FakeRepository([
        () => BusinessesPage(items: [_business('1')], hasMore: true),
        () => BusinessesPage(items: [_business('2')], hasMore: false),
      ]);
      final cubit = _cubit(repo);

      await cubit.load(null);
      await cubit.loadMore();

      expect(cubit.state.businesses.map((b) => b.id), ['1', '2']);
      expect(cubit.state.page, 2);
      expect(cubit.state.hasMore, isFalse);
      expect(cubit.state.isLoadingMore, isFalse);
      expect(repo.requestedPages, [1, 2]);
    },
  );

  test('loadMore() ne fait rien quand il n\'y a plus rien à charger', () async {
    final repo = _FakeRepository([
      () => BusinessesPage(items: [_business('1')], hasMore: false),
    ]);
    final cubit = _cubit(repo);

    await cubit.load(null);
    await cubit.loadMore();
    await cubit.loadMore();

    // Aucune requête au-delà de la première : c'est ce qui protège du
    // martèlement quand la vue redéclenche pendant le scroll.
    expect(repo.requestedPages, [1]);
  });

  test('loadMore() ignore les appels concurrents', () async {
    final repo = _FakeRepository([
      () => BusinessesPage(items: [_business('1')], hasMore: true),
      () => BusinessesPage(items: [_business('2')], hasMore: true),
      () => BusinessesPage(items: [_business('3')], hasMore: true),
    ]);
    final cubit = _cubit(repo);
    await cubit.load(null);

    // Trois déclenchements quasi simultanés, comme le fait le scroll.
    await Future.wait([cubit.loadMore(), cubit.loadMore(), cubit.loadMore()]);

    expect(repo.requestedPages, [1, 2]);
    expect(cubit.state.businesses.map((b) => b.id), ['1', '2']);
  });

  test('un échec de loadMore() laisse la liste intacte et réarmable', () async {
    final repo = _FakeRepository([
      () => BusinessesPage(items: [_business('1')], hasMore: true),
      () => throw Exception('réseau'),
      () => BusinessesPage(items: [_business('2')], hasMore: false),
    ]);
    final cubit = _cubit(repo);

    await cubit.load(null);
    await cubit.loadMore();

    expect(cubit.state.businesses.map((b) => b.id), ['1']);
    expect(cubit.state.isLoadingMore, isFalse);
    expect(cubit.state.hasMore, isTrue, reason: 'doit rester réessayable');

    // Le scroll suivant réussit.
    await cubit.loadMore();
    expect(cubit.state.businesses.map((b) => b.id), ['1', '2']);
  });

  test('load() en erreur expose un message et pas de liste', () async {
    final repo = _FakeRepository([() => throw Exception('boom')]);
    final cubit = _cubit(repo);

    await cubit.load(null);

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.businesses, isEmpty);
    expect(cubit.state.errorMessage, isNotNull);
  });

  test(
    'changer de categorie remplace la liste et refiltre le serveur',
    () async {
      final repo = _FakeRepository([
        () => BusinessesPage(items: [_business('1')], hasMore: true),
        () => BusinessesPage(items: [_business('9')], hasMore: false),
      ]);
      final cubit = _cubit(repo);

      await cubit.load(null);
      await cubit.load('spa');

      expect(cubit.state.businesses.map((b) => b.id), ['9']);
      expect(cubit.state.category, 'spa');
      expect(cubit.state.page, 1);
      expect(repo.requestedCategories, [null, 'spa']);
    },
  );

  test('loadMore() reutilise la categorie affichee', () async {
    final repo = _FakeRepository([
      () => BusinessesPage(items: [_business('1')], hasMore: true),
      () => BusinessesPage(items: [_business('2')], hasMore: false),
    ]);
    final cubit = _cubit(repo);

    await cubit.load('hotel');
    await cubit.loadMore();

    expect(repo.requestedCategories, ['hotel', 'hotel']);
    expect(repo.requestedPages, [1, 2]);
  });

  group('La recherche part au serveur', () {
    test('elle attend une pause dans la frappe', () async {
      // Sans temporisation, « restaurant » enverrait dix requêtes, et les
      // réponses pourraient revenir dans le désordre.
      final repo = _FakeRepository([
        () => BusinessesPage(items: [_business('1')], hasMore: false),
      ]);
      final cubit = _cubit(repo);

      cubit.queryChanged('res');
      cubit.queryChanged('resta');
      cubit.queryChanged('restaurant');

      // Rien n'est encore parti.
      expect(repo.requestedQueries, isEmpty);
      expect(cubit.state.query, 'restaurant');

      await Future.delayed(const Duration(milliseconds: 500));
      expect(repo.requestedQueries, ['restaurant']);

      await cubit.close();
    });

    test('la page suivante répond à la même question', () async {
      // Une page suivante qui oublierait la recherche renverrait des
      // commerces sans rapport à la suite de ceux affichés.
      final repo = _FakeRepository([
        () => BusinessesPage(items: [_business('1')], hasMore: true),
        () => BusinessesPage(items: [_business('2')], hasMore: false),
      ]);
      final cubit = _cubit(repo);

      await cubit.load('restaurant', query: 'chez');
      await cubit.loadMore();

      expect(repo.requestedQueries, ['chez', 'chez']);
      expect(repo.requestedCategories, ['restaurant', 'restaurant']);
      expect(repo.requestedPages, [1, 2]);

      await cubit.close();
    });

    test('changer de catégorie garde la recherche tapée', () async {
      // L'utilisateur affine, il ne recommence pas : effacer son texte au
      // moment où il touche une catégorie serait une perte de travail.
      final repo = _FakeRepository([
        () => BusinessesPage(items: [_business('1')], hasMore: false),
        () => BusinessesPage(items: [_business('2')], hasMore: false),
      ]);
      final cubit = _cubit(repo);

      await cubit.load(null, query: 'chez');
      await cubit.load('spa');

      expect(cubit.state.query, 'chez');
      expect(repo.requestedQueries, ['chez', 'chez']);

      await cubit.close();
    });
  });
}
