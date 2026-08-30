import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/core/widgets/offer_card.dart';
import 'package:baobabe_0_2/core/widgets/remote_image.dart';
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

  group('Le texte ne repose jamais sur la photo', () {
    testWidgets('il est posé sur un fond opaque', (tester) async {
      // C'est la promesse structurante de la carte. Tant qu'elle tient, le
      // contraste est celui du thème (16,7:1 pour le nom) et ne dépend plus
      // du visuel. Une version précédente posait le texte sur la photo : il
      // fallait alors doser un voile, ce voile délavait la photo sur les
      // quatre cinquièmes de sa hauteur, et le calcul de contraste avait été
      // fait à la mauvaise hauteur — le titre sortait à 1,79:1.
      await tester.pumpWidget(
        _sized(OfferCard(offer: _offer(), onTap: () {}), _railMin),
      );

      final surface = AppTheme.silvaTheme.colorScheme.surfaceContainerLowest;

      // Le bloc de texte est enveloppé d'un fond plein de la couleur de la
      // carte — sans transparence.
      final fonds = tester
          .widgetList<ColoredBox>(
            find.ancestor(
              of: find.text('Riz au poisson frais'),
              matching: find.byType(ColoredBox),
            ),
          )
          .map((b) => b.color);

      expect(
        fonds.any((c) => c == surface && c.a == 1.0),
        isTrue,
        reason:
            'le texte doit être adossé à un aplat opaque, pas à un dégradé '
            'posé sur la photo.',
      );
    });

    testWidgets('la photo occupe tout ce qui reste au-dessus', (tester) async {
      await tester.pumpWidget(
        _sized(OfferCard(offer: _offer(), onTap: () {}), const Size(190, 280)),
      );

      final photo = tester.getRect(find.byType(RemoteImage).first);
      final texte = tester.getRect(find.text('Riz au poisson frais'));

      // La photo est peinte derrière toute la carte ; ce qui compte est
      // qu'elle soit dégagée au-dessus du texte, sur au moins la moitié.
      final degage = texte.top - photo.top;
      expect(
        degage / photo.height,
        greaterThan(0.5),
        reason:
            'la carte doit montrer le produit : la zone photo dégagée ne fait '
            'que ${(degage / photo.height * 100).round()} % de la carte.',
      );
    });
  });

  group('Photo en haut, texte en bas', () {
    // La carte est franchement séparée en deux blocs : aucun fondu, aucun
    // voile. Quatre versions ont tenté d'adoucir la frontière ; toutes
    // coûtaient de la hauteur de photo sans rien rendre plus lisible.
    const gabarits = <String, Size>{
      'rail court': Size(190, 265),
      'rail moyen': Size(190, 285),
      'rail haut': Size(190, 310),
      'grille Explorer': Size(171, 255),
    };

    gabarits.forEach((nom, taille) {
      testWidgets('la photo garde la plus grosse part de la carte — $nom', (
        tester,
      ) async {
        await tester.pumpWidget(
          _sized(
            OfferCard(
              offer: _offer(name: 'Chambre Deluxe Vue Fleuve'),
              onTap: () {},
            ),
            taille,
          ),
        );

        final carte = tester.getRect(find.byType(OfferCard));
        final photo = tester.getRect(find.byType(RemoteImage));

        // Mesurée entre 49 % (grille d'Explorer) et 58 % (rail haut) : le
        // plancher est posé juste en dessous, pour attraper une régression
        // sans se casser au premier pixel près.
        expect(
          photo.height / carte.height,
          greaterThan(0.45),
          reason:
              'la photo ne fait que '
              '${(photo.height / carte.height * 100).round()} % de la carte : '
              "le texte l'a chassée.",
        );
      });

      testWidgets("le texte commence là où la photo s'arrête — $nom", (
        tester,
      ) async {
        await tester.pumpWidget(
          _sized(
            OfferCard(
              offer: _offer(name: 'Chambre Deluxe Vue Fleuve'),
              onTap: () {},
            ),
            taille,
          ),
        );

        final photo = tester.getRect(find.byType(RemoteImage));
        final titre = tester.getRect(find.text('Chambre Deluxe Vue Fleuve'));

        // Entre le bas de la photo et le titre, il n'y a que la marge du
        // bloc de texte — rien d'autre, et surtout aucune bande vide.
        final ecart = titre.top - photo.bottom;
        expect(
          ecart,
          inInclusiveRange(0, AppDimens.small + 2),
          reason:
              'il y a ${ecart.toStringAsFixed(0)} px entre la photo et le '
              'titre, au lieu de la seule marge du bloc.',
        );
      });
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
