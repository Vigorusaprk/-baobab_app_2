import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/core/widgets/offer_card.dart';
import 'package:baobabe_0_2/features/business_detail/data/offer_slots_api_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer_availability.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_detail_parts.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_slot_picker.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_extras.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/opening_hours_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// L'espace commerçant, et ce qu'il change côté client.
///
/// Trois choses sont tenues ici :
///
/// - un commerçant **déclare** ses créneaux, et le client ne choisit plus
///   qu'entre ceux-là — il pouvait auparavant demander 3 h du matin, et le
///   commerçant découvrait le rendez-vous impossible dans sa boîte ;
/// - une offre qui ne déclare rien garde le **choix libre** de sa date : les
///   offres publiées avant les créneaux continuent de fonctionner ;
/// - une mise en avant payée se **voit comme telle**, sans quoi de la
///   publicité passerait pour du mérite.

/// Un service de créneaux qui ne parle à personne.
class _Slots extends OfferSlotsApiService {
  _Slots(this.availability);

  final OfferAvailability availability;

  @override
  Future<OfferAvailability> getAvailability(
    String offerId, {
    DateTime? from,
    DateTime? to,
  }) async => availability;
}

/// Un service qui échoue, pour l'écran de secours.
class _BrokenSlots extends OfferSlotsApiService {
  @override
  Future<OfferAvailability> getAvailability(
    String offerId, {
    DateTime? from,
    DateTime? to,
  }) async => throw const OfferSlotsException('Créneaux injoignables');
}

/// Un lendemain fixe : un test qui tombe sur aujourd'hui vieillit mal.
final DateTime _day = DateTime(2026, 10, 14);

OfferAvailability _declared({int capacity = 8}) => OfferAvailability(
  declaresSlots: true,
  durationMinutes: 90,
  slotCapacity: capacity,
  slots: [
    OfferSlot(at: DateTime(2026, 10, 14, 9), remaining: capacity),
    OfferSlot(at: DateTime(2026, 10, 14, 10, 30), remaining: 2),
    OfferSlot(at: DateTime(2026, 10, 15, 9), remaining: capacity),
  ],
);

Offer _offer({String id = 'o1'}) => Offer(
  id: id,
  name: 'Soin du visage',
  description: 'Une heure trente, produits fournis.',
  price: 45,
  fulfilment: Fulfilment.booking,
  businessId: 'b1',
  businessName: 'Institut Kivu',
);

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.silvaTheme,
  home: Scaffold(
    body: SingleChildScrollView(child: child),
  ),
);

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  group('Le choix du rendez-vous', () {
    testWidgets('les créneaux déclarés remplacent le choix libre', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          OfferSlotPicker(
            offerId: 'o1',
            chosen: null,
            onPickSlot: (_) {},
            onPickDay: (_) {},
            onOpenCalendar: () {},
            service: _Slots(_declared()),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('JOUR'), findsOneWidget);
      expect(find.text('HEURE'), findsOneWidget);
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('10:30'), findsOneWidget);
      // Le calendrier libre n'a plus lieu d'être : il menait à des heures
      // que le commerçant n'honore pas.
      expect(find.text('DATE'), findsNothing);
    });

    testWidgets('seuls les jours ouverts sont proposés', (tester) async {
      await tester.pumpWidget(
        _host(
          OfferSlotPicker(
            offerId: 'o1',
            chosen: null,
            onPickSlot: (_) {},
            onPickDay: (_) {},
            onOpenCalendar: () {},
            service: _Slots(_declared()),
          ),
        ),
      );
      await tester.pump();

      // Deux jours portent des créneaux, pas trois : une pastille pour un
      // jour fermé, c'est faire toucher pour rien.
      expect(find.byType(OfferDayChip), findsNWidgets(2));
    });

    testWidgets('toucher un créneau donne l\'heure, sans la redemander', (
      tester,
    ) async {
      DateTime? picked;
      await tester.pumpWidget(
        _host(
          OfferSlotPicker(
            offerId: 'o1',
            chosen: null,
            onPickSlot: (value) => picked = value,
            onPickDay: (_) {},
            onOpenCalendar: () {},
            service: _Slots(_declared()),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('10:30'));
      await tester.pump();

      expect(picked, DateTime(2026, 10, 14, 10, 30));
    });

    testWidgets('le nombre de places n\'apparaît que lorsqu\'il est bas', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          OfferSlotPicker(
            offerId: 'o1',
            chosen: null,
            onPickSlot: (_) {},
            onPickDay: (_) {},
            onOpenCalendar: () {},
            service: _Slots(_declared()),
          ),
        ),
      );
      await tester.pump();

      // « 8 places » sous chaque créneau ne dit rien ; « 2 places » décide.
      expect(find.text('2 places'), findsOneWidget);
      expect(find.text('8 places'), findsNothing);
    });

    testWidgets('sans rien de déclaré, le choix libre demeure', (tester) async {
      await tester.pumpWidget(
        _host(
          OfferSlotPicker(
            offerId: 'o1',
            chosen: null,
            onPickSlot: (_) {},
            onPickDay: (_) {},
            onOpenCalendar: () {},
            service: _Slots(const OfferAvailability()),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('DATE'), findsOneWidget);
      expect(find.text('HEURE'), findsNothing);
    });

    testWidgets('des créneaux déclarés mais tous pris se disent', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          OfferSlotPicker(
            offerId: 'o1',
            chosen: null,
            onPickSlot: (_) {},
            onPickDay: (_) {},
            onOpenCalendar: () {},
            service: _Slots(const OfferAvailability(declaresSlots: true)),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Aucun créneau libre'), findsOneWidget);
    });

    testWidgets('une lecture manquée propose de réessayer', (tester) async {
      await tester.pumpWidget(
        _host(
          OfferSlotPicker(
            offerId: 'o1',
            chosen: null,
            onPickSlot: (_) {},
            onPickDay: (_) {},
            onOpenCalendar: () {},
            service: _BrokenSlots(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Créneaux injoignables'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
    });
  });

  group('La mise en avant', () {
    testWidgets('une offre poussée porte son étiquette', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.silvaTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 190,
                height: 260,
                child: OfferCard(
                  offer: _offer(),
                  sponsored: true,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Sponsorisé'), findsOneWidget);
    });

    testWidgets('une offre ordinaire n\'en porte pas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.silvaTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 190,
                height: 260,
                child: OfferCard(offer: _offer(), onTap: () {}),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Sponsorisé'), findsNothing);
    });
  });

  group('Ce que le commerçant déclare', () {
    test('un placement dit ce qu\'il achète', () {
      for (final placement in AdPlacement.values) {
        expect(placement.label, isNotEmpty);
        expect(placement.explanation, isNotEmpty);
      }
    });

    test('un état de campagne dit où elle en est', () {
      expect(CampaignStatus.inReview.isLive, isFalse);
      expect(CampaignStatus.running.isLive, isTrue);
      expect(CampaignStatus.finished.isOver, isTrue);
      expect(CampaignStatus.cancelled.isOver, isTrue);
      expect(CampaignStatus.approved.isOver, isFalse);
    });

    testWidgets('les horaires se déclarent jour par jour', (tester) async {
      Map<String, dynamic>? saved;
      await tester.pumpWidget(
        _host(
          OpeningHoursEditor(
            value: const {'lundi': '09:00-18:00'},
            onChanged: (value) => saved = value,
          ),
        ),
      );

      expect(find.textContaining('Lundi'), findsOneWidget);
      expect(saved, isNull);
    });
  });

  group('Les créneaux, côté outils', () {
    test('une heure se lit et se réécrit sans se déformer', () {
      expect(formatTime(parseTime('09:30')), '09:30');
      // Postgres rend « 09:00:00 » : les secondes ne doivent pas se
      // retrouver dans l'heure affichée.
      expect(formatTime(parseTime('14:05:00')), '14:05');
      // Une ligne illisible retombe sur 9 h plutôt que de faire échouer
      // l'écran : le commerçant voit une heure fausse et la corrige, là où
      // une exception lui aurait fermé la page.
      expect(formatTime(parseTime('bancal')), '09:00');
      expect(formatTime(parseTime(null)), '09:00');
    });

    test('les jours de la semaine ont tous un nom', () {
      for (var weekday = 1; weekday <= 7; weekday++) {
        expect(weekdayName(weekday), isNotEmpty);
        expect(weekdayShort(weekday), isNotEmpty);
      }
    });

    test('les créneaux se regroupent par jour', () {
      final availability = _declared();
      expect(availability.slotsOn(_day).length, 2);
      expect(availability.openDays.length, 2);
      expect(availability.openDays.first, _day);
    });
  });
}
