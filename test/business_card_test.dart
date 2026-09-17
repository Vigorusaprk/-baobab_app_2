import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/core/widgets/business_card.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// La carte d'un commerce, telle qu'elle vit réellement : une tuile de
/// 190 px dans une grille à deux colonnes, une ligne pleine largeur dans
/// « Voir tout ».
///
/// Ce que ces tests tiennent :
///
/// - la carte **ne ment pas** : « Ouvert » ne s'affiche que si le serveur l'a
///   dit, et un commerce sans avis dit « Pas encore d'avis », jamais « 0,0 » ;
/// - elle dit **ce qu'on peut y faire**, et seulement ce qui est vrai ;
/// - rien ne déborde aux tailles réelles.

Business _business({
  String name = 'Chez Flore',
  String? commune = 'Gombe',
  double rating = 4.8,
  int reviewCount = 32,
  bool? isOpenNow,
  String? opensAt,
  String? closesAt,
  bool canOrder = false,
  bool canBook = false,
  bool hasInStore = false,
  DateTime? createdAt,
}) => Business(
  id: 'b1',
  name: name,
  address: '1015 Avenue Tombalbaye, Gombe, Kinshasa',
  description: '',
  bgImg: '',
  profilImg: '',
  rating: rating,
  reviewCount: reviewCount,
  openingHours: const {},
  type: BusinessType.restaurant,
  phone: '',
  images: const [],
  specificData: const {},
  reviews: const [],
  isFavorite: false,
  isSponsored: false,
  createdAt: createdAt ?? DateTime(2026, 1, 1),
  commune: commune,
  isOpenNow: isOpenNow,
  opensAt: opensAt,
  closesAt: closesAt,
  canOrder: canOrder,
  canBook: canBook,
  hasInStore: hasInStore,
);

/// Une tuile de grille sur un téléphone de 411 px : deux colonnes, marges
/// comprises.
const double _tileWidth = 183;

Widget _sized(Widget child, {double width = _tileWidth}) => MaterialApp(
  theme: AppTheme.silvaTheme,
  home: Scaffold(
    body: Center(
      child: SizedBox(width: width, child: child),
    ),
  ),
);

void main() {
  group('Ce que la carte dit', () {
    testWidgets('qui, quoi, où, c\'est bien', (tester) async {
      await tester.pumpWidget(
        _sized(BusinessCard.tile(business: _business(), onTap: () {})),
      );

      expect(find.text('Chez Flore'), findsOneWidget);
      expect(find.text('Restaurant · Gombe'), findsOneWidget);
      expect(find.text('4,8 (32)'), findsOneWidget);
    });

    testWidgets('sans commune, la catégorie seule', (tester) async {
      await tester.pumpWidget(
        _sized(
          BusinessCard.tile(business: _business(commune: null), onTap: () {}),
        ),
      );

      expect(find.text('Restaurant'), findsOneWidget);
    });

    testWidgets('sans avis, elle ne dit pas « 0,0 »', (tester) async {
      await tester.pumpWidget(
        _sized(
          BusinessCard.tile(
            business: _business(rating: 0, reviewCount: 0),
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Pas encore d\'avis'), findsOneWidget);
      expect(find.textContaining('0,0'), findsNothing);
    });

    testWidgets('« Nouveau » sur un commerce de moins d\'un mois', (
      tester,
    ) async {
      await tester.pumpWidget(
        _sized(
          BusinessCard.tile(
            business: _business(createdAt: DateTime.now()),
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Nouveau'), findsOneWidget);
    });
  });

  group('L\'ouverture vient du serveur', () {
    testWidgets('ouvert, jusqu\'à l\'heure dite', (tester) async {
      await tester.pumpWidget(
        _sized(
          BusinessCard.tile(
            business: _business(isOpenNow: true, closesAt: '22:00'),
            onTap: () {},
          ),
        ),
      );

      expect(find.textContaining('Ouvert'), findsOneWidget);
      expect(find.textContaining('22:00'), findsOneWidget);
    });

    testWidgets('fermé, avec l\'heure d\'ouverture', (tester) async {
      await tester.pumpWidget(
        _sized(
          BusinessCard.tile(
            business: _business(isOpenNow: false, opensAt: '10:00'),
            onTap: () {},
          ),
        ),
      );

      expect(find.textContaining('Fermé'), findsOneWidget);
      expect(find.textContaining('10:00'), findsOneWidget);
    });

    testWidgets('sans réponse du serveur, elle se tait', (tester) async {
      // L'ancienne ligne disait « Ouvert » en dur. Mieux vaut un silence
      // qu'un « Ouvert » inventé.
      await tester.pumpWidget(
        _sized(
          BusinessCard.tile(business: _business(isOpenNow: null), onTap: () {}),
        ),
      );

      expect(find.textContaining('Ouvert'), findsNothing);
      expect(find.textContaining('Fermé'), findsNothing);
    });
  });

  group('Ce qu\'on peut y faire', () {
    testWidgets('seules les pastilles vraies s\'affichent', (tester) async {
      await tester.pumpWidget(
        _sized(
          BusinessCard.tile(
            business: _business(canOrder: true, canBook: true),
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Commander'), findsOneWidget);
      expect(find.text('Réserver'), findsOneWidget);
      expect(find.text('En boutique'), findsNothing);
    });

    testWidgets('rien à faire, rien à dire', (tester) async {
      await tester.pumpWidget(
        _sized(BusinessCard.tile(business: _business(), onTap: () {})),
      );

      expect(find.text('Commander'), findsNothing);
      expect(find.text('Réserver'), findsNothing);
    });
  });

  group('Aux tailles réelles', () {
    testWidgets('une tuile de grille avec tout dessus ne déborde pas', (
      tester,
    ) async {
      await tester.pumpWidget(
        _sized(
          BusinessCard.tile(
            business: _business(
              name: 'Restaurant Le Grand Baobab de la Gombe',
              isOpenNow: true,
              closesAt: '23:00',
              canOrder: true,
              canBook: true,
              hasInStore: true,
            ),
            featuredOffer: 'Poulet moambe du dimanche',
            onTap: () {},
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(
        find.text('Met en avant : Poulet moambe du dimanche'),
        findsOneWidget,
      );
    });

    testWidgets('une ligne pleine largeur non plus', (tester) async {
      await tester.pumpWidget(
        _sized(
          BusinessCard.row(
            business: _business(
              isOpenNow: false,
              opensAt: '09:00',
              canOrder: true,
              canBook: true,
              hasInStore: true,
            ),
            onTap: () {},
          ),
          width: 379,
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Chez Flore'), findsOneWidget);
    });

    testWidgets('la tuile et son squelette ont la même photo', (tester) async {
      // Un squelette plus haut ou plus court que le contenu réel fait sauter
      // la page au remplacement : la photo, qui fait l'essentiel de la
      // hauteur, doit avoir la même proportion des deux côtés.
      await tester.pumpWidget(
        _sized(BusinessCard.tile(business: _business(), onTap: () {})),
      );
      final photo = tester.getSize(find.byType(AspectRatio).first);

      // Un squelette ne vit jamais hors d'un `Skeletonizer` : c'est lui qui
      // donne aux os leur peinture — et leurs contraintes.
      await tester.pumpWidget(
        _sized(
          const Skeletonizer(enabled: true, child: BusinessCardSkeleton.tile()),
        ),
      );
      final bone = tester.getSize(find.byType(AspectRatio).first);

      expect(bone.height, moreOrLessEquals(photo.height, epsilon: 0.5));
    });
  });
}
