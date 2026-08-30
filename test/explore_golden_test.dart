@Tags(['golden'])
library;

import 'dart:io';

import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/core/widgets/offer_card.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/offer_search_filters.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/explore_filters_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures d'Explorer : la grille à deux colonnes et le panneau de filtres.
///
/// Comme pour [offer_card_golden_test], les photos sont absentes du banc de
/// test — `CachedNetworkImage` télécharge via `http`, qui ne répond pas ici.
/// Ce qui se juge : la densité de la grille, la lisibilité à deux colonnes,
/// et la composition du panneau.

Future<void> _loadPoppins() async {
  final loader = FontLoader('Poppins');
  loader.addFont(
    File(
      'assets/Poppins/Poppins-Regular.ttf',
    ).readAsBytes().then((b) => ByteData.view(b.buffer)),
  );
  await loader.load();
}

Offer _offer(
  String name,
  String business,
  double price,
  Fulfilment f,
  double rating,
) => Offer(
  id: name,
  name: name,
  description: 'Préparé le jour même, servi chaud.',
  price: price,
  fulfilment: f,
  rating: rating,
  reviewCount: 21,
  businessName: business,
);

void main() {
  setUpAll(_loadPoppins);

  testWidgets('la grille à deux colonnes', (tester) async {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final offers = [
      _offer('Riz au poisson', 'Mama Africa', 25, Fulfilment.order, 4.8),
      _offer('Suite Deluxe', 'Hôtel Béatrice', 120, Fulfilment.booking, 4.4),
      _offer('Crème karité', 'Nzuri Cosmetics', 0, Fulfilment.inStore, 4.9),
      _offer('Poulet braisé', 'Chez Nadine', 15, Fulfilment.order, 4.2),
      _offer('Massage relaxant', 'Spa Élégance', 40, Fulfilment.booking, 5.0),
      _offer('Sac en raphia', 'Atelier Kin', 30, Fulfilment.inStore, 4.1),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.silvaTheme,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppTheme.silvaTheme.colorScheme.surface,
          body: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.67,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: offers.length,
            itemBuilder: (_, i) => OfferCard(offer: offers[i], onTap: () {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(GridView),
      matchesGoldenFile('goldens/explore_grid.png'),
    );
  });

  testWidgets('le panneau de filtres', (tester) async {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.silvaTheme,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppTheme.silvaTheme.colorScheme.surface,
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showExploreFiltersSheet(
                  context,
                  const OfferSearchFilters(
                    minPrice: 10,
                    maxPrice: 30,
                    fulfilment: Fulfilment.order,
                  ),
                ),
                child: const Text('ouvrir'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(BottomSheet),
      matchesGoldenFile('goldens/explore_filters.png'),
    );
  });
}
