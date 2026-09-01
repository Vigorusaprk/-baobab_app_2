import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_space.dart';
import 'package:baobabe_0_2/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

Business _business() => Business(
  id: 'b1',
  name: 'Chez Mama Nzuzi',
  address: 'Kinshasa',
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

/// Dépôt factice : le cubit n'utilise que ce qui est redéfini ici, le reste
/// de l'interface est comblé par `noSuchMethod`.
class _FakeRepository implements MerchantRepository {
  _FakeRepository({this.space = const MerchantSpace(), this.failWith});

  MerchantSpace space;
  Object? failWith;
  int spaceReads = 0;
  int writes = 0;

  @override
  Future<MerchantSpace> getSpace() async {
    spaceReads++;
    return space;
  }

  @override
  Future<void> createOffer(OfferDraft draft) async {
    writes++;
    if (failWith != null) throw failWith!;
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    writes++;
    if (failWith != null) throw failWith!;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Le cubit lit la session Supabase, indisponible en test : cette variante
/// court-circuite ce seul point pour n'exercer que sa logique d'état.
class _TestableMerchantCubit extends MerchantCubit {
  _TestableMerchantCubit(super.repository, {required this.loggedIn})
    : super.forTest();

  final bool loggedIn;

  @override
  bool get isSignedIn => loggedIn;
}

void main() {
  group('MerchantCubit', () {
    test('un visiteur non connecté n\'est jamais commerçant', () async {
      final repository = _FakeRepository();
      final cubit = _TestableMerchantCubit(repository, loggedIn: false);

      await cubit.refresh();

      expect(cubit.state, isA<NotAMerchant>());
      expect(
        repository.spaceReads,
        0,
        reason: 'inutile d\'interroger le serveur sans session',
      );
      await cubit.close();
    });

    test('un commerce reçu fait basculer l\'état', () async {
      final repository = _FakeRepository(
        space: MerchantSpace(business: _business(), role: 'owner'),
      );
      final cubit = _TestableMerchantCubit(repository, loggedIn: true);

      await cubit.refresh();

      expect(cubit.state, isA<MerchantReady>());
      expect(
        (cubit.state as MerchantReady).space.business?.name,
        'Chez Mama Nzuzi',
      );
      await cubit.close();
    });

    test('sans commerce, la demande en cours est conservée', () async {
      final repository = _FakeRepository(
        space: const MerchantSpace(
          application: MerchantApplication(
            id: 'a1',
            businessName: 'Chez Mama Nzuzi',
            status: ApplicationStatus.pending,
          ),
        ),
      );
      final cubit = _TestableMerchantCubit(repository, loggedIn: true);

      await cubit.refresh();

      final state = cubit.state;
      expect(state, isA<NotAMerchant>());
      expect(
        (state as NotAMerchant).application?.status,
        ApplicationStatus.pending,
      );
      await cubit.close();
    });

    test('une écriture relit toujours l\'espace derrière elle', () async {
      final repository = _FakeRepository(
        space: MerchantSpace(business: _business(), role: 'owner'),
      );
      final cubit = _TestableMerchantCubit(repository, loggedIn: true);
      await cubit.refresh();
      final readsBefore = repository.spaceReads;

      final error = await cubit.updateOrderStatus('o1', 'confirmed');

      expect(error, isNull);
      expect(repository.writes, 1);
      expect(
        repository.spaceReads,
        readsBefore + 1,
        reason: 'les compteurs viennent du serveur, jamais d\'un calcul local',
      );
      await cubit.close();
    });

    test('une écriture refusée remonte le message du serveur', () async {
      final repository = _FakeRepository(
        space: MerchantSpace(business: _business(), role: 'owner'),
        failWith: const MerchantException('Vous gérez déjà un commerce'),
      );
      final cubit = _TestableMerchantCubit(repository, loggedIn: true);
      await cubit.refresh();

      final error = await cubit.createOffer(
        const OfferDraft(name: 'Liboke', fulfilment: Fulfilment.order),
      );

      expect(error, 'Vous gérez déjà un commerce');
      expect(
        cubit.state,
        isA<MerchantReady>(),
        reason: 'un échec ne doit pas vider l\'écran du commerçant',
      );
      await cubit.close();
    });

    test('l\'ouverture sur l\'espace ne se déclenche qu\'une fois', () async {
      final repository = _FakeRepository(
        space: MerchantSpace(business: _business(), role: 'owner'),
      );
      final cubit = _TestableMerchantCubit(repository, loggedIn: true);
      await cubit.refresh();

      expect(cubit.consumeLanding(), isTrue);
      expect(cubit.consumeLanding(), isFalse);
      await cubit.close();
    });
  });

  group('OfferDraft', () {
    test('une offre à commander n\'emporte ni places ni date', () {
      final body = const OfferDraft(
        name: 'Liboke de poisson',
        fulfilment: Fulfilment.order,
        price: 9.5,
      ).toBody();

      expect(body['fulfilment'], 'order');
      expect(body['price'], 9.5);
      expect(body['capacity'], isNull);
      expect(body['startsAt'], isNull);
    });

    test('une date est transmise en UTC', () {
      final body = OfferDraft(
        name: 'Concert',
        fulfilment: Fulfilment.booking,
        capacity: 120,
        startsAt: DateTime.utc(2026, 9, 15, 19),
      ).toBody();

      expect(body['capacity'], 120);
      expect(body['startsAt'], '2026-09-15T19:00:00.000Z');
    });

    test("une offre en boutique n'emporte ni places ni date", () {
      final body = const OfferDraft(
        name: 'Pagne wax 6 yards',
        fulfilment: Fulfilment.inStore,
        price: 22,
        capacity: 10,
      ).toBody();

      expect(body['fulfilment'], 'in_store');
      expect(
        body['capacity'],
        isNull,
        reason: "une jauge de places n'a de sens que pour une réservation",
      );
      expect(body['startsAt'], isNull);
    });

    test('modifier une offre repart de ses valeurs actuelles', () {
      final draft = OfferDraft.from(
        const Offer(
          id: 'o1',
          name: 'Crème hydratante',
          fulfilment: Fulfilment.order,
          price: 12,
          section: 'Soins',
        ),
      );

      expect(draft.name, 'Crème hydratante');
      expect(draft.price, 12);
      expect(draft.section, 'Soins');
    });
  });
}
