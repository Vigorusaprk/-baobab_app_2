import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer_detail.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/review.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/offer_detail_cubit.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_identity.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/business_offer_board.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_detail_views.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_purchase_bar.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/review_list_item.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// La refonte de la fiche commerce et de la fiche offre.
///
/// Ce qui change, et ce que ces tests tiennent :
///
/// - le catalogue est **filtré par ce qu'on peut en faire**, et le filtre
///   n'apparaît que s'il trie quelque chose ;
/// - une offre a **trois fiches**, une par mode : ce qui se commande demande
///   une quantité, ce qui se réserve une date, ce qui se prend en boutique
///   ne demande rien ;
/// - une offre en boutique n'a **aucun bouton d'achat** : il n'y a rien à
///   valider, et un bouton qui promet une transaction inexistante ment.

Offer _offer({
  String id = 'o1',
  String name = 'Poulet moambe',
  Fulfilment fulfilment = Fulfilment.order,
  double price = 24,
  String description = 'Sauce à la noix de palme, riz, chikwangue',
  int? capacity,
  DateTime? startsAt,
  int reviewCount = 0,
}) => Offer(
  id: id,
  name: name,
  description: description,
  price: price,
  fulfilment: fulfilment,
  capacity: capacity,
  startsAt: startsAt,
  rating: reviewCount > 0 ? 4.8 : 0,
  reviewCount: reviewCount,
  businessId: 'b1',
  businessName: 'Le Grill du Boulevard',
);

Business _business({
  String phone = '+243 900 000 000',
  Map<String, String> hours = const {},
  double rating = 4.6,
  int reviewCount = 12,
}) => Business(
  id: 'b1',
  name: 'Le Grill du Boulevard',
  address: 'Av. de la Libération 14, Gombe',
  description: '',
  bgImg: '',
  profilImg: '',
  rating: rating,
  reviewCount: reviewCount,
  openingHours: hours,
  type: BusinessType.restaurant,
  phone: phone,
  images: const [],
  specificData: const {},
  reviews: const [],
  isFavorite: false,
  isSponsored: false,
  createdAt: DateTime(2026, 1, 1),
);

OfferDetailLoaded _loaded(
  Offer offer, {
  int quantity = 1,
  DateTime? chosenDate,
  int? remaining,
  List<Review> reviews = const [],
}) => OfferDetailLoaded(
  OfferDetail(
    offer: offer,
    merchant: const OfferMerchant(
      id: 'b1',
      name: 'Le Grill du Boulevard',
      address: 'Av. de la Libération 14, Gombe',
      phone: '+243 900 000 000',
    ),
    reviews: reviews,
    remainingCapacity: remaining,
  ),
  quantity: quantity,
  chosenDate: chosenDate,
);

Review _review({
  int id = 1,
  String name = 'Josué B.',
  int rating = 5,
  String comment = 'La sauce est celle qu on cherche.',
}) => Review(
  id: id,
  businessId: 'b1',
  userId: 'u1',
  rating: rating,
  comment: comment,
  createdAt: DateTime.now().subtract(const Duration(days: 1)),
  userName: name,
);

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.silvaTheme,
  home: Scaffold(body: child),
);

/// Le tableau rend un sliver : il lui faut donc un `CustomScrollView`.
Widget _hostSliver(Widget sliver) => MaterialApp(
  theme: AppTheme.silvaTheme,
  home: Scaffold(body: CustomScrollView(slivers: [sliver])),
);

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  group('Le catalogue du commerce', () {
    testWidgets('groupe les offres par ce qu on peut en faire', (tester) async {
      await tester.pumpWidget(
        _hostSliver(
          BusinessOfferBoard(
            offers: [
              _offer(),
              _offer(
                id: 'o2',
                name: 'Soirée grillades',
                fulfilment: Fulfilment.booking,
              ),
              _offer(
                id: 'o3',
                name: 'Sauce piment maison',
                fulfilment: Fulfilment.inStore,
              ),
            ],
          ),
        ),
      );

      expect(find.text('À COMMANDER'), findsOneWidget);
      expect(find.text('À RÉSERVER'), findsOneWidget);
      expect(find.text('EN BOUTIQUE'), findsOneWidget);
    });

    testWidgets('le filtre ne trie que ce qui est triable', (tester) async {
      // Un seul mode : un filtre à deux pastilles dont l une ne retire rien
      // ne fait que demander un choix inutile.
      await tester.pumpWidget(
        _hostSliver(
          BusinessOfferBoard(
            offers: [
              _offer(),
              _offer(id: 'o2'),
            ],
          ),
        ),
      );
      expect(find.textContaining('Tout ·'), findsNothing);

      await tester.pumpWidget(
        _hostSliver(
          BusinessOfferBoard(
            offers: [
              _offer(),
              _offer(id: 'o2', fulfilment: Fulfilment.booking),
            ],
          ),
        ),
      );
      expect(find.text('Tout · 2'), findsOneWidget);
      expect(find.text('Commander'), findsOneWidget);
      expect(find.text('Réserver'), findsOneWidget);
      // Pas de pastille « Boutique » : rien ne s y rangerait.
      expect(find.text('Boutique'), findsNothing);
    });

    testWidgets('choisir un filtre retire le reste', (tester) async {
      await tester.pumpWidget(
        _hostSliver(
          BusinessOfferBoard(
            offers: [
              _offer(),
              _offer(
                id: 'o2',
                name: 'Soirée grillades',
                fulfilment: Fulfilment.booking,
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Réserver'));
      await tester.pumpAndSettle();

      expect(find.text('Soirée grillades'), findsOneWidget);
      expect(find.text('Poulet moambe'), findsNothing);
    });

    testWidgets('un commerce sans offre le dit', (tester) async {
      // La section disparaissait, et la fiche s arrêtait sur les horaires.
      await tester.pumpWidget(
        _hostSliver(const BusinessOfferBoard(offers: [])),
      );
      expect(find.textContaining('ne propose encore rien'), findsOneWidget);
    });
  });

  group('L identité du commerce', () {
    testWidgets('dit si le commerce est ouvert, et jusqu à quand', (
      tester,
    ) async {
      const days = {
        1: 'Lundi',
        2: 'Mardi',
        3: 'Mercredi',
        4: 'Jeudi',
        5: 'Vendredi',
        6: 'Samedi',
        7: 'Dimanche',
      };
      final business = _business(
        hours: {days[DateTime.now().weekday]!: '00:00 - 23:59'},
      );

      await tester.pumpWidget(
        _host(
          BusinessIdentity(
            business: business,
            uiBusiness: UIBusiness(business),
            ratedOffers: 3,
          ),
        ),
      );

      expect(find.textContaining('Ouvert · jusqu'), findsOneWidget);
      expect(find.text('3 offres notées'), findsOneWidget);
    });

    testWidgets('une ligne d horaire illisible est reprise telle quelle', (
      tester,
    ) async {
      const days = {
        1: 'Lundi',
        2: 'Mardi',
        3: 'Mercredi',
        4: 'Jeudi',
        5: 'Vendredi',
        6: 'Samedi',
        7: 'Dimanche',
      };
      // Le commerçant saisit du texte libre : on ne devine pas à sa place.
      final business = _business(
        hours: {days[DateTime.now().weekday]!: 'Sur rendez-vous'},
      );

      await tester.pumpWidget(
        _host(
          BusinessIdentity(
            business: business,
            uiBusiness: UIBusiness(business),
            ratedOffers: 0,
          ),
        ),
      );

      expect(find.text('Sur rendez-vous'), findsOneWidget);
    });

    testWidgets('sans téléphone, pas de bouton Appeler', (tester) async {
      final business = _business(phone: '');

      await tester.pumpWidget(
        _host(
          BusinessIdentity(
            business: business,
            uiBusiness: UIBusiness(business),
            ratedOffers: 0,
          ),
        ),
      );

      expect(find.text('Appeler'), findsNothing);
      expect(find.text('Itinéraire'), findsOneWidget);
    });
  });

  group('Les trois fiches d offre', () {
    testWidgets('commander demande une quantité, pas une date', (tester) async {
      await tester.pumpWidget(
        _host(
          OfferOrderView(state: _loaded(_offer()), onQuantityChanged: (_) {}),
        ),
      );

      expect(find.text('Quantité'), findsOneWidget);
      expect(find.text('DATE'), findsNothing);
      expect(find.textContaining('Se commande'), findsOneWidget);
    });

    testWidgets('réserver demande une date, et prévient de l attente', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          OfferBookingView(
            state: _loaded(
              _offer(
                name: 'Soirée grillades',
                fulfilment: Fulfilment.booking,
                capacity: 5,
              ),
              remaining: 4,
            ),
            onQuantityChanged: (_) {},
            onPickDay: (_) {},
            onOpenCalendar: () {},
          ),
        ),
      );

      expect(find.text('DATE'), findsOneWidget);
      expect(find.text('PLACES'), findsOneWidget);
      expect(find.text('4 restantes sur 5'), findsOneWidget);
      // Le mot manquait : une réservation partait sans dire qu elle n était
      // pas ferme.
      expect(find.textContaining('en attente'), findsOneWidget);
      expect(find.text('Nombre de places'), findsOneWidget);
    });

    testWidgets('une séance impose son heure au lieu de la demander', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          OfferBookingView(
            state: _loaded(
              _offer(
                name: 'Séance : Dune',
                fulfilment: Fulfilment.booking,
                startsAt: DateTime(2026, 9, 12, 20, 30),
              ),
            ),
            onQuantityChanged: (_) {},
            onPickDay: (_) {},
            onOpenCalendar: () {},
          ),
        ),
      );

      expect(find.text('DATE'), findsNothing);
      expect(find.textContaining('12 septembre'), findsOneWidget);
    });

    testWidgets('en boutique ne demande rien du tout', (tester) async {
      await tester.pumpWidget(
        _host(
          OfferInStoreView(
            state: _loaded(
              _offer(name: 'Sauce piment', fulfilment: Fulfilment.inStore),
            ),
          ),
        ),
      );

      expect(find.text('Disponible en boutique'), findsOneWidget);
      expect(find.text('Quantité'), findsNothing);
      expect(find.text('DATE'), findsNothing);
    });
  });

  group('La barre du bas', () {
    testWidgets('porte le total et le geste, plus la quantité', (tester) async {
      await tester.pumpWidget(
        _host(
          OfferPurchaseBar(
            state: _loaded(_offer(), quantity: 2),
            onSubmit: () {},
          ),
        ),
      );

      expect(find.text('TOTAL'), findsOneWidget);
      expect(find.text('48,00 \$'), findsOneWidget);
      expect(find.text('Commander'), findsOneWidget);
      // Le compteur est remonté dans la page, avec ce qu il compte.
      expect(find.text('Quantité'), findsNothing);
    });

    testWidgets('une réservation annonce sa date au lieu du mot Total', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          OfferPurchaseBar(
            state: _loaded(
              _offer(fulfilment: Fulfilment.booking, price: 15),
              chosenDate: DateTime(2026, 9, 6, 19),
            ),
            onSubmit: () {},
          ),
        ),
      );

      expect(find.text('TOTAL'), findsNothing);
      expect(find.textContaining('19:00'), findsOneWidget);
      expect(find.text('Réserver'), findsOneWidget);
    });

    testWidgets('sans date choisie, la barre le dit', (tester) async {
      await tester.pumpWidget(
        _host(
          OfferPurchaseBar(
            state: _loaded(_offer(fulfilment: Fulfilment.booking)),
            onSubmit: () {},
          ),
        ),
      );

      expect(find.text('DATE À CHOISIR'), findsOneWidget);
    });

    testWidgets('en boutique, aucun bouton d achat', (tester) async {
      await tester.pumpWidget(
        _host(
          OfferPurchaseBar(
            state: _loaded(_offer(fulfilment: Fulfilment.inStore)),
            onSubmit: () {},
          ),
        ),
      );

      expect(find.text('Commander'), findsNothing);
      expect(find.text('Réserver'), findsNothing);
      expect(find.text('Voir le commerce'), findsOneWidget);
    });

    testWidgets('une offre complète ne se valide pas', (tester) async {
      await tester.pumpWidget(
        _host(
          OfferPurchaseBar(
            state: _loaded(
              _offer(fulfilment: Fulfilment.booking, capacity: 5),
              remaining: 0,
            ),
            onSubmit: () {},
          ),
        ),
      );

      expect(find.text('Complet'), findsOneWidget);
    });
  });

  group('Les avis', () {
    testWidgets('suivent un rail, le premier en couleur d action', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          Column(
            children: [
              ReviewListItem(review: _review(), accent: true),
              ReviewListItem(review: _review(id: 2, name: 'Nadine T.')),
            ],
          ),
        ),
      );

      expect(find.text('Josué B.'), findsOneWidget);
      expect(find.text('Nadine T.'), findsOneWidget);
      // Une date d avis se lit en repères, pas en chiffres.
      expect(find.text('hier'), findsNWidgets(2));
      // Plus d avatar : souvent absent, il occupait la place du texte pour
      // n afficher qu une silhouette grise.
      expect(find.byType(CircleAvatar), findsNothing);
    });
  });
}
