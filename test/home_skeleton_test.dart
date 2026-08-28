import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_list_row.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/home_skeleton.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/offer_card_widget.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/offers_carousel_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(
    body: Skeletonizer(enabled: true, child: SingleChildScrollView(child: child)),
  ),
);

void main() {
  group('HomeSkeleton', () {
    testWidgets(
      'annonce le triptyque réel : deux rails d\'offres et des commerçants',
      (tester) async {
        await tester.pumpWidget(_wrap(const HomeSkeleton()));

        // Nouveautés et Découvrir sont deux rails d'offres ; Populaires est
        // une liste de commerçants. C'est exactement ce que l'accueil
        // affiche une fois chargé.
        expect(find.byType(OffersCarouselSkeleton), findsNWidgets(2));
        expect(find.byType(BusinessListRowSkeleton), findsNWidgets(3));
      },
    );

    testWidgets('le rail montre des cartes d\'offre, pas des formes libres', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const HomeSkeleton()));

      expect(find.byType(OfferCardSkeleton), findsWidgets);
    });
  });

  group('OffersCarouselSkeleton', () {
    testWidgets('a exactement la hauteur du carrousel réel', (tester) async {
      late double railHeight;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              railHeight = OffersCarouselSection.railHeight(context);
              return const OffersCarouselSkeleton();
            },
          ),
        ),
      );

      // Un squelette plus haut ou plus court que le contenu réel fait sauter
      // la page au moment du remplacement.
      // Le rail est le SizedBox qui porte la liste horizontale, pas les
      // espaceurs qui l'entourent.
      final rail = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byType(ListView),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(rail.height, railHeight);
    });

    testWidgets('la carte a la largeur de la vraie carte d\'offre', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const OffersCarouselSkeleton()));

      final card = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byType(OfferCardSkeleton).first,
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(card.width, OffersCarouselSection.cardWidth);
    });
  });

  group('Fulfilment', () {
    test('chaque manière d\'obtenir une offre a son étiquette', () {
      expect(Fulfilment.order.badge, 'À commander');
      expect(Fulfilment.booking.badge, 'À réserver');
      expect(Fulfilment.inStore.badge, 'En boutique');
    });

    test('le troisième type fait l\'aller-retour avec le serveur', () {
      expect(Fulfilment.inStore.asJson, 'in_store');
      expect(Fulfilment.fromJson('in_store'), Fulfilment.inStore);
      expect(Fulfilment.fromJson('order'), Fulfilment.order);
      expect(Fulfilment.fromJson('booking'), Fulfilment.booking);
    });
  });
}
