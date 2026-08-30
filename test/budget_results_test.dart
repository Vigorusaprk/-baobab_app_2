import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_match.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_results_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// « Trouver selon mon budget » calculait un prix moyen par commerce, décidait
/// s'il tenait dans le budget… et rendait une liste de rectangles vides : la
/// liste s'appuyait sur un `BusinessCardPlaceholder` resté à l'état d'ébauche.
/// L'écran était atteignable, la requête partait, la réponse arrivait, et rien
/// de tout cela n'atteignait l'œil.
///
/// Ces tests tiennent la promesse de l'écran : le résultat de la recherche
/// doit être lisible.

Business _business(String name) => Business(
  id: name.toLowerCase(),
  name: name,
  address: 'Gombe',
  description: '',
  bgImg: '',
  profilImg: '',
  rating: 4.2,
  reviewCount: 12,
  openingHours: const {},
  type: BusinessType.restaurant,
  phone: '',
  images: const [],
  specificData: const {},
  reviews: const [],
  isFavorite: false,
  isSponsored: false,
  createdAt: DateTime(2026, 1, 1),
);

Widget _harness(List<BusinessMatch> matches) => MaterialApp(
  theme: AppTheme.silvaTheme,
  home: Scaffold(
    body: BusinessResultsList(matches: matches, onTap: (_) {}),
  ),
);

void main() {
  testWidgets('chaque résultat porte le nom du commerce', (tester) async {
    await tester.pumpWidget(
      _harness([
        BusinessMatch(
          business: _business('Chez Nadine'),
          averagePrice: 25,
          matchesBudget: true,
        ),
      ]),
    );

    expect(find.text('Chez Nadine'), findsOneWidget);
  });

  testWidgets('le prix moyen — la réponse à la question posée — est visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness([
        BusinessMatch(
          business: _business('Chez Nadine'),
          averagePrice: 25,
          matchesBudget: true,
        ),
      ]),
    );

    expect(find.text('25 \$'), findsOneWidget);
    expect(find.text('en moyenne'), findsOneWidget);
  });

  testWidgets('un commerce sans prix connu le dit au lieu d\'afficher 0', (
    tester,
  ) async {
    // Un commerce sans `menu_items` ni `rooms` n'a pas de prix moyen. « 0 \$ »
    // se lirait comme « gratuit ».
    await tester.pumpWidget(
      _harness([
        BusinessMatch(
          business: _business('Nouveau Commerce'),
          averagePrice: null,
          matchesBudget: false,
        ),
      ]),
    );

    expect(find.text('Prix inconnu'), findsOneWidget);
    expect(find.text('0 \$'), findsNothing);
  });

  testWidgets('une recherche sans résultat explique quoi faire', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(const []));

    expect(
      find.textContaining('Essayez un montant plus élevé'),
      findsOneWidget,
    );
  });
}
