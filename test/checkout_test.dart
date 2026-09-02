import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer_detail.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_selection.dart';
import 'package:baobabe_0_2/features/order/presentation/cubit/checkout_cubit.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/checkout_success_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// La validation d'une commande ou d'une réservation.
///
/// Elle vivait dans `OfferDetailCubit`, mêlée à la lecture de la fiche, avec
/// deux conséquences visibles : une réussie appelait `load()` et faisait
/// repasser toute la page par son squelette, et « en train de valider » était
/// un champ de l'état de la fiche.
///
/// Séparée, elle se teste — ce qui n'était pas le cas : elle lisait
/// `SessionService.instance`, un singleton adossé à Supabase.

const _offer = Offer(
  id: 'o1',
  name: 'Sandwich poulet',
  description: 'Grillé, crudités.',
  price: 4.5,
  fulfilment: Fulfilment.order,
  businessId: 'b1',
);

const _bookable = Offer(
  id: 'o2',
  name: 'Séance de dune',
  description: 'Deux heures.',
  price: 8,
  fulfilment: Fulfilment.booking,
  businessId: 'b1',
);

OfferDetail _detail(Offer offer) => OfferDetail(offer: offer);

AppSessionUser? _connected() =>
    const AppSessionUser(id: 'u1', name: 'Louis-kerry', email: 'lk@example.cd');

AppSessionUser? _visitor() => null;

/// Intercepte l'envoi : ce test porte sur l'enchaînement des états, pas sur
/// le réseau.
class _FakeSelection extends OfferSelection {
  bool ordered = false;
  bool booked = false;
  String? deliveryAddress;
  String? contactPhone;
  Object? failWith;

  @override
  Future<void> submitOrder({
    required String businessId,
    required List<Offer> offers,
    required String userId,
    String? deliveryAddress,
    dynamic service,
  }) async {
    if (failWith != null) throw failWith!;
    ordered = true;
    this.deliveryAddress = deliveryAddress;
  }

  @override
  Future<void> submitBooking({
    required List<Offer> offers,
    String? contactPhone,
    dynamic service,
  }) async {
    if (failWith != null) throw failWith!;
    booked = true;
    this.contactPhone = contactPhone;
  }
}

void main() {
  group('Le cubit de validation', () {
    test('une commande passe par « en cours » puis « réussi »', () async {
      final selection = _FakeSelection();
      final cubit = CheckoutCubit(selection: selection, session: _connected);
      final seen = <CheckoutState>[];
      cubit.stream.listen(seen.add);

      await cubit.submit(
        detail: _detail(_offer),
        quantity: 2,
        deliveryAddress: 'Av. Kasa-Vubu, Gombe',
      );

      // Le flux livre ses événements sur une micro-tâche : `seen` porte le
      // passage par « en cours », et l'état final se lit sur le cubit.
      expect(seen.first, isA<CheckoutSubmitting>());
      expect(cubit.state, const CheckoutSucceeded(CheckoutKind.order));
      expect(selection.ordered, isTrue);
      expect(selection.deliveryAddress, 'Av. Kasa-Vubu, Gombe');
      expect(selection.quantityOf(_offer), 2);
    });

    test('une réservation est reconnue comme telle', () async {
      final selection = _FakeSelection();
      final cubit = CheckoutCubit(selection: selection, session: _connected);

      await cubit.submit(
        detail: _detail(_bookable),
        quantity: 1,
        contactPhone: '+243 900 000 000',
      );

      expect(cubit.state, const CheckoutSucceeded(CheckoutKind.booking));
      expect(selection.booked, isTrue);
      expect(selection.contactPhone, '+243 900 000 000');
    });

    test('sans session, on demande de se connecter', () async {
      final cubit = CheckoutCubit(
        selection: _FakeSelection(),
        session: _visitor,
      );
      await cubit.submit(detail: _detail(_offer), quantity: 1);

      expect(
        cubit.state,
        const CheckoutFailed('Connectez-vous pour continuer.'),
      );
    });

    test('le message du serveur est montré tel quel', () async {
      // Les fonctions serveur répondent en français et parlent du métier
      // (« Il ne reste que 2 place(s) ») : les remplacer par « une erreur est
      // survenue » ferait perdre la seule information utile.
      final selection = _FakeSelection()
        ..failWith = Exception('Il ne reste que 2 place(s).');
      final cubit = CheckoutCubit(selection: selection, session: _connected);

      await cubit.submit(detail: _detail(_bookable), quantity: 5);

      expect(cubit.state, const CheckoutFailed('Il ne reste que 2 place(s).'));
    });

    test('deux appuis rapprochés n\'envoient qu\'une fois', () async {
      final selection = _FakeSelection();
      final cubit = CheckoutCubit(selection: selection, session: _connected);

      final first = cubit.submit(detail: _detail(_offer), quantity: 1);
      final second = cubit.submit(detail: _detail(_offer), quantity: 1);
      await Future.wait([first, second]);

      // Le second appel voit `CheckoutSubmitting` et repart : sans cette
      // garde, un double appui commanderait deux fois.
      expect(cubit.state, const CheckoutSucceeded(CheckoutKind.order));
    });

    test('l\'issue s\'oublie une fois montrée', () async {
      final cubit = CheckoutCubit(
        selection: _FakeSelection(),
        session: _connected,
      );
      await cubit.submit(detail: _detail(_offer), quantity: 1);
      cubit.acknowledge();

      // Sans cela, revenir sur la fiche rejouerait l'animation d'une
      // commande déjà passée.
      expect(cubit.state, isA<CheckoutIdle>());
    });
  });

  group('La confirmation animée', () {
    Widget host(CheckoutKind kind) => MaterialApp(
      theme: AppTheme.silvaTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => showCheckoutSuccessSheet(context, kind: kind),
              child: const Text('valider'),
            ),
          ),
        ),
      ),
    );

    testWidgets('elle se referme d\'elle-même', (tester) async {
      await tester.pumpWidget(host(CheckoutKind.order));
      await tester.tap(find.text('valider'));
      await tester.pumpAndSettle();

      expect(find.text('Commande envoyée'), findsOneWidget);
      // Pas de croix : la feuille part seule, et une croix inviterait à
      // interrompre une animation d'une seconde et demie.
      expect(find.byTooltip('Fermer'), findsNothing);

      // Trois temps : l'animation, la pause de lecture (un `Timer`, que
      // `pumpAndSettle` n'avance pas), puis la fermeture.
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();
      expect(find.text('Commande envoyée'), findsNothing);
    });

    testWidgets('le mot suit ce qui a été validé', (tester) async {
      await tester.pumpWidget(host(CheckoutKind.booking));
      await tester.tap(find.text('valider'));
      await tester.pumpAndSettle();

      expect(find.text('Demande envoyée'), findsOneWidget);
      expect(find.text('Commande envoyée'), findsNothing);
    });
  });
}
