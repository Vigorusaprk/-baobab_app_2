import 'dart:math' as math;

import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/core/widgets/offer_card.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// La carte d'offre, dans les tailles où elle vit réellement.
///
/// Elle apparaît dans deux contextes très différents : un rail horizontal de
/// 190 px sur l'accueil, et une grille à deux colonnes sur Explorer où chaque
/// carte tombe à ~173 px sur un téléphone. Ce qui tient à 236 px peut déborder
/// à 173 — d'où les tests de contenance ci-dessous.

/// Le plus petit gabarit réel : la largeur du rail et la hauteur minimale que
/// `railHeight` peut rendre sur un écran court.
const Size _railMin = Size(190, 220);

/// Une carte de la grille d'Explorer sur un téléphone de 375 px.
const Size _gridCell = Size(171, 225);

Offer _offer({
  String name = 'Riz au poisson frais',
  String? business = 'Mama Africa Resto',
  double price = 25,
  Fulfilment fulfilment = Fulfilment.order,
  double rating = 4.8,
  int reviewCount = 32,
  DateTime? startsAt,
}) => Offer(
  id: 'o1',
  name: name,
  description: 'Servi avec légumes de saison.',
  price: price,
  fulfilment: fulfilment,
  rating: rating,
  reviewCount: reviewCount,
  businessName: business,
  startsAt: startsAt,
);

Widget _sized(Widget child, Size size) => MaterialApp(
  theme: AppTheme.silvaTheme,
  home: Scaffold(
    body: Center(
      child: SizedBox(width: size.width, height: size.height, child: child),
    ),
  ),
);

void main() {
  group('Ce que la carte dit', () {
    testWidgets('le nom, chez qui, le prix et la note', (tester) async {
      await tester.pumpWidget(
        _sized(OfferCard(offer: _offer(), onTap: () {}), _railMin),
      );

      expect(find.text('Riz au poisson frais'), findsOneWidget);
      expect(find.text('chez Mama Africa Resto'), findsOneWidget);
      expect(find.text('25 \$'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
    });

    testWidgets('le mode de retrait, en badge', (tester) async {
      await tester.pumpWidget(
        _sized(
          OfferCard(
            offer: _offer(fulfilment: Fulfilment.inStore),
            onTap: () {},
          ),
          _railMin,
        ),
      );

      expect(find.text('En boutique'), findsOneWidget);
    });

    testWidgets('une offre sans prix ne dit pas « 0 \$ »', (tester) async {
      // `isFree` veut dire « prix sur demande », pas « gratuit ». Afficher
      // zéro serait une promesse que le commerçant n'a pas faite.
      await tester.pumpWidget(
        _sized(OfferCard(offer: _offer(price: 0), onTap: () {}), _railMin),
      );

      expect(find.text('Sur demande'), findsOneWidget);
      expect(find.text('0 \$'), findsNothing);
    });

    testWidgets('une offre sans avis n\'affiche pas de note', (tester) async {
      // Une note de 0,0 sur une offre que personne n'a notée se lit comme un
      // mauvais avis.
      await tester.pumpWidget(
        _sized(
          OfferCard(offer: _offer(rating: 0, reviewCount: 0), onTap: () {}),
          _railMin,
        ),
      );

      expect(find.text('0.0'), findsNothing);
      expect(find.byIcon(Icons.star_rounded), findsNothing);
    });

    testWidgets('une offre datée porte sa date', (tester) async {
      await tester.pumpWidget(
        _sized(
          OfferCard(
            offer: _offer(startsAt: DateTime(2026, 3, 14)),
            onTap: () {},
          ),
          _railMin,
        ),
      );

      expect(find.text('14/03'), findsOneWidget);
    });

    testWidgets('toute la carte est le bouton', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _sized(
          OfferCard(offer: _offer(), onTap: () => tapped = true),
          _railMin,
        ),
      );

      await tester.tap(find.byType(OfferCard));
      expect(tapped, isTrue);
    });
  });

  group('La carte tient dans sa boîte', () {
    testWidgets('au plus petit gabarit du rail', (tester) async {
      await tester.pumpWidget(
        _sized(
          OfferCard(
            // Le pire cas : un nom long, une date, et un commerçant long.
            offer: _offer(
              name: 'Séance de cinéma en salle climatisée',
              business: 'CineKin Gombe Centre-ville',
              startsAt: DateTime(2026, 8, 29),
            ),
            onTap: () {},
          ),
          _railMin,
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('dans une case de la grille à deux colonnes', (tester) async {
      await tester.pumpWidget(
        _sized(
          OfferCard(
            offer: _offer(
              name: 'Séance de cinéma en salle climatisée',
              business: 'CineKin Gombe Centre-ville',
              startsAt: DateTime(2026, 8, 29),
            ),
            onTap: () {},
          ),
          _gridCell,
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('avec le texte agrandi une fois et demie', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.silvaTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: _railMin.width,
                height: _railMin.height,
                child: OfferCard(offer: _offer(), onTap: () {}),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('Le voile rend le texte lisible', () {
    // Le voile est blanc : le pire cas pour du texte foncé est donc une photo
    // entièrement noire dessous, qui donne le fond le plus sombre.
    double canal(double c) {
      final v = c / 255.0;
      return v <= 0.04045
          ? v / 12.92
          : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    }

    double luminance(Color c) =>
        0.2126 * canal(c.r * 255) +
        0.7152 * canal(c.g * 255) +
        0.0722 * canal(c.b * 255);

    double contraste(Color texte, double voile) {
      final fond = luminance(
        Color.fromARGB(
          255,
          (voile * 255).round(),
          (voile * 255).round(),
          (voile * 255).round(),
        ),
      );
      final t = luminance(texte);
      final haut = math.max(fond, t);
      final bas = math.min(fond, t);
      return (haut + 0.05) / (bas + 0.05);
    }

    final scheme = AppTheme.silvaTheme.colorScheme;

    // Hauteur à laquelle chaque ligne se trouve dans la carte.
    final lignes = <String, (double, Color)>{
      'le nom': (0.46, scheme.onSurface),
      '« chez X »': (0.66, scheme.onSurfaceVariant),
      'le prix': (0.80, scheme.primary),
    };

    lignes.forEach((nom, position) {
      test('$nom atteint 4,5:1 sur une photo noire', () {
        final (hauteur, couleur) = position;
        final voile = OfferCard.scrimAlphaAt(hauteur);
        final ratio = contraste(couleur, voile);

        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason:
              "à $hauteur de hauteur le voile vaut "
              "${voile.toStringAsFixed(2)}, ce qui ne donne que "
              "${ratio.toStringAsFixed(2)}:1.",
        );
      });
    });

    test('le voile ne commence pas avant le haut de la photo', () {
      // La photo doit rester intacte en haut : c'est elle qu'on regarde.
      expect(OfferCard.scrimAlphaAt(0.0), 0);
      expect(OfferCard.scrimAlphaAt(0.15), 0);
    });
  });

  group('Le squelette', () {
    testWidgets('ne déborde pas non plus', (tester) async {
      // La règle du projet : un squelette d'une autre taille que le contenu
      // réel fait sauter la page au moment où les données arrivent.
      await tester.pumpWidget(
        _sized(
          const Skeletonizer(enabled: true, child: OfferCardSkeleton()),
          _railMin,
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
