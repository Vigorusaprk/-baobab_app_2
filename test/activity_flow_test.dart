import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/activity/domain/activity_entry.dart';
import 'package:baobabe_0_2/features/activity/presentation/widgets/activity_empty.dart';
import 'package:baobabe_0_2/features/activity/presentation/widgets/activity_flow.dart';
import 'package:baobabe_0_2/features/activity/presentation/widgets/activity_receipt.dart';
import 'package:baobabe_0_2/features/activity/presentation/widgets/activity_skeleton.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// La refonte de l'écran d'activité.
///
/// Ce qui change, et ce que ces tests tiennent :
///
/// - **un seul flux**, chronologique, au lieu de deux onglets. On ne se
///   souvient pas d'une catégorie, on se souvient d'un commerce et d'un
///   moment ;
/// - une **ligne** par activité, pas une carte : commandes et réservations
///   se lisent dans la même colonne ;
/// - toucher une ligne déplie son **reçu**, avec le code à présenter ;
/// - un code de réservation non confirmée est **verrouillé** : le montrer
///   actif enverrait quelqu'un au comptoir pour rien.

Order _order({
  String id = 'o1',
  String name = 'Le Grill du Boulevard',
  OrderStatus status = OrderStatus.preparing,
  DateTime? at,
}) => Order(
  id: id,
  establishmentId: 'b1',
  establishmentName: name,
  orderDate: at ?? DateTime.now(),
  items: [
    OrderItem(
      menuItemId: 'm1',
      name: 'Poulet moambe',
      price: 12,
      quantity: 2,
      offerId: 'of1',
    ),
  ],
  subtotal: 24,
  tax: 0,
  totalAmount: 24,
  status: status,
);

Reservation _booking({
  String id = 'r1',
  String name = 'Salon Ndako Beauté',
  String status = 'pending',
  DateTime? at,
}) => Reservation(
  id: id,
  businessId: 'b2',
  establishmentName: name,
  reservationType: 'Soin du visage',
  customerName: 'Louis-kerry',
  phoneNumber: '+243 900 000 000',
  totalAmount: 18,
  reservationDate: DateTime(2026, 9, 6, 14, 30),
  status: status,
  createdAt: at ?? DateTime.now(),
);

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.silvaTheme,
  home: Scaffold(body: child),
);

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  group('Le flux', () {
    testWidgets('mêle commandes et réservations dans une seule colonne', (
      tester,
    ) async {
      final entries = [
        ActivityEntry.fromOrder(_order()),
        ActivityEntry.fromReservation(_booking()),
      ];

      await tester.pumpWidget(
        _host(ActivityFlow(entries: entries, onOpen: (_) {})),
      );

      // Les deux natures cohabitent : c'est tout l'objet de la refonte.
      expect(find.text('Le Grill du Boulevard'), findsOneWidget);
      expect(find.text('Salon Ndako Beauté'), findsOneWidget);
      // Et il n'y a plus d'onglets à choisir avant de chercher.
      expect(find.byType(TabBar), findsNothing);
    });

    testWidgets('regroupe l\'historique par repère de temps, du récent à '
        'l\'ancien', (tester) async {
      final now = DateTime.now();
      final entries = [
        ActivityEntry.fromOrder(
          _order(
            id: 'vieux',
            status: OrderStatus.delivered,
            at: now.subtract(const Duration(days: 4)),
          ),
        ),
        ActivityEntry.fromOrder(
          _order(id: 'neuf', status: OrderStatus.delivered, at: now),
        ),
      ];

      await tester.pumpWidget(
        _host(ActivityFlow(entries: entries, onOpen: (_) {})),
      );

      expect(find.text('AUJOURD\'HUI'), findsOneWidget);
      expect(find.text('CETTE SEMAINE'), findsOneWidget);
      // Le plus récent d'abord : on cherche presque toujours le dernier.
      expect(
        tester.getTopLeft(find.text('AUJOURD\'HUI')).dy,
        lessThan(tester.getTopLeft(find.text('CETTE SEMAINE')).dy),
      );
    });

    testWidgets('ce qui est en cours passe devant, quelle que soit sa date', (
      tester,
    ) async {
      final now = DateTime.now();
      final entries = [
        // Livrée aujourd'hui : réglée, donc dans l'historique.
        ActivityEntry.fromOrder(
          _order(id: 'reglee', status: OrderStatus.delivered, at: now),
        ),
        // En préparation depuis six jours : c'est elle qu'on vient voir.
        ActivityEntry.fromOrder(
          _order(
            id: 'attente',
            status: OrderStatus.preparing,
            at: now.subtract(const Duration(days: 6)),
          ),
        ),
      ];

      await tester.pumpWidget(
        _host(ActivityFlow(entries: entries, onOpen: (_) {})),
      );

      // Sans ce groupe, la ligne qui attend quelque chose se retrouvait
      // enterrée sous les commandes d'hier.
      expect(
        tester.getTopLeft(find.text('EN COURS')).dy,
        lessThan(tester.getTopLeft(find.text('AUJOURD\'HUI')).dy),
      );
      // Une ligne réglée n'attend rien : elle reste dans la chronologie.
      expect(find.text('CETTE SEMAINE'), findsNothing);
    });

    testWidgets('l\'en-tête dit l\'état, pas un chiffre nu', (tester) async {
      final entries = [
        ActivityEntry.fromOrder(_order(id: 'a')),
        ActivityEntry.fromOrder(_order(id: 'b', status: OrderStatus.delivered)),
        ActivityEntry.fromOrder(_order(id: 'c', status: OrderStatus.delivered)),
      ];

      await tester.pumpWidget(_host(ActivityHeader(entries: entries)));

      // Une pastille « 3 » ne disait pas de quoi elle était le compte.
      expect(find.textContaining('1 en cours'), findsOneWidget);
      expect(find.textContaining('2 terminées'), findsOneWidget);
    });

    testWidgets('pendant le chargement, l\'en-tête n\'annonce pas un compte '
        'faux', (tester) async {
      // La liste est vide tant que rien n\'est chargé : l\'en-tête disait
      // donc « Aucune activité », sur une ligne, avant de sauter à deux.
      await tester.pumpWidget(
        _host(const ActivityHeader(entries: [], loading: true)),
      );

      expect(find.text('Aucune activité'), findsNothing);
    });

    testWidgets('toucher une ligne l\'ouvre', (tester) async {
      ActivityEntry? opened;
      final entry = ActivityEntry.fromOrder(_order());

      await tester.pumpWidget(
        _host(ActivityFlow(entries: [entry], onOpen: (e) => opened = e)),
      );
      await tester.tap(find.text('Le Grill du Boulevard'));
      await tester.pumpAndSettle();

      expect(opened?.id, entry.id);
    });
  });

  group('Le reçu', () {
    testWidgets('montre le code à présenter', (tester) async {
      final entry = ActivityEntry.fromOrder(_order());

      await tester.pumpWidget(
        _host(ActivityReceipt(entry: entry, onBack: () {})),
      );

      expect(find.text('À PRÉSENTER AU COMMERCE'), findsOneWidget);
      expect(find.text(entry.code), findsOneWidget);
      expect(find.textContaining('scanne le code'), findsOneWidget);
    });

    testWidgets('une réservation non confirmée a son code verrouillé', (
      tester,
    ) async {
      final entry = ActivityEntry.fromReservation(_booking());

      await tester.pumpWidget(
        _host(ActivityReceipt(entry: entry, onBack: () {})),
      );

      // Montrer un code actif enverrait quelqu'un au comptoir pour rien.
      expect(
        find.textContaining('dès que la réservation est confirmée'),
        findsOneWidget,
      );
    });

    testWidgets('confirmée, le code est utilisable', (tester) async {
      final entry = ActivityEntry.fromReservation(
        _booking(status: 'confirmed'),
      );

      await tester.pumpWidget(
        _host(ActivityReceipt(entry: entry, onBack: () {})),
      );

      expect(find.textContaining('scanne le code'), findsOneWidget);
      expect(find.textContaining('dès que la réservation'), findsNothing);
    });

    testWidgets('une demande annulée ne présente plus de code', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          ActivityReceipt(
            entry: ActivityEntry.fromOrder(
              _order(status: OrderStatus.cancelled),
            ),
            onBack: () {},
          ),
        ),
      );

      // Le talon restait affiché, code lisible et QR actif, au bas du reçu
      // d\'une commande annulée.
      expect(find.text('À PRÉSENTER AU COMMERCE'), findsNothing);
      expect(find.textContaining('plus rien à présenter'), findsOneWidget);
    });

    testWidgets('l\'annulation est un bouton tracé, pleine largeur', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          ActivityReceipt(
            entry: ActivityEntry.fromOrder(_order()),
            onBack: () {},
            onCancel: () {},
          ),
        ),
      );

      // L'action est au pied du reçu : la liste la construit à l'approche.
      await tester.scrollUntilVisible(
        find.text('Annuler la commande'),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      final button = find.widgetWithText(OutlinedButton, 'Annuler la commande');
      expect(button, findsOneWidget);
      // Au pied d'une page entière, un bouton court flotte sans appui.
      expect(
        tester.getSize(button).width,
        tester.getSize(find.byType(ListView)).width - AppDimens.large * 2,
      );
    });

    testWidgets('le retour revient au flux', (tester) async {
      var back = false;
      await tester.pumpWidget(
        _host(
          ActivityReceipt(
            entry: ActivityEntry.fromOrder(_order()),
            onBack: () => back = true,
          ),
        ),
      );

      await tester.tap(find.byTooltip('Retour au flux'));
      expect(back, isTrue);
    });
  });

  group('Le code', () {
    test('est stable pour un même identifiant', () {
      final a = ActivityEntry.fromOrder(_order(id: 'abc-123'));
      final b = ActivityEntry.fromOrder(_order(id: 'abc-123'));
      expect(a.code, b.code);
    });

    test('ne contient que des chiffres', () {
      // Il mêlait lettres et chiffres : au comptoir, il fallait l'épeler et
      // distinguer un O d'un zéro.
      final code = ActivityEntry.fromOrder(_order()).code;
      expect(code.replaceAll(' ', ''), matches(RegExp(r'^[0-9]{8}$')));
    });

    test('distingue une commande d\'une réservation', () {
      // Le même identifiant côté commande et côté réservation ne doit pas
      // donner le même code à présenter.
      expect(
        ActivityEntry.fromOrder(_order(id: 'x1')).code,
        isNot(ActivityEntry.fromReservation(_booking(id: 'x1')).code),
      );
    });

    test('le QR encode un identifiant réel', () {
      // Pour qu'un scanner à venir ait quelque chose à interroger, plutôt
      // qu'une chaîne décorative.
      final entry = ActivityEntry.fromOrder(_order(id: 'o42'));
      expect(entry.qrPayload, 'baobabe:order:o42');
    });
  });

  group('Les états', () {
    testWidgets('le squelette a la forme du flux', (tester) async {
      // Un squelette d'une autre forme que son contenu fait sauter la page
      // quand les données arrivent.
      await tester.pumpWidget(_host(const ActivityFlowSkeleton()));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('le squelette remplit la hauteur disponible', (tester) async {
      // Quatre lignes en haut d'un écran vide laissaient un grand blanc en
      // dessous, qui se remplissait d'un coup à l'arrivée des données. Le
      // squelette dépasse donc la hauteur qu'on lui donne, quelle qu'elle
      // soit.
      for (final height in [300.0, 900.0]) {
        await tester.pumpWidget(
          _host(
            SizedBox(
              height: height,
              child: ActivityFlowSkeleton(key: ValueKey(height)),
            ),
          ),
        );
        await tester.pump();

        final position = tester
            .state<ScrollableState>(find.byType(Scrollable))
            .position;
        expect(
          position.maxScrollExtent,
          greaterThan(0),
          reason: 'à $height px de haut, le squelette laisse un blanc',
        );
      }
    });

    testWidgets('l\'état vide propose un geste', (tester) async {
      await tester.pumpWidget(_host(const ActivityEmpty()));

      expect(find.text('Rien encore ici'), findsOneWidget);
      expect(find.text('Explorer les commerces'), findsOneWidget);
    });
  });
}
