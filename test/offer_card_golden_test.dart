@Tags(['golden'])
library;

import 'dart:io';

import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/core/widgets/offer_card.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rend le rail de cartes d'offres en image, avec les vraies polices.
///
/// **Ce que cette capture ne montre pas :** la photo. `RemoteImage` passe par
/// `CachedNetworkImage`, qui télécharge via le paquet `http` — ni
/// `HttpOverrides` ni l'absence de réseau du banc de test ne lui font rendre
/// une image, et son placeholder est un shimmer qui tourne sans fin. Les
/// cartes sont donc capturées sur leur repli. La mise en page, la hiérarchie
/// du texte et la rangée de statistiques se jugent ; le flou sur photo, lui,
/// demande l'application lancée.
///
/// `flutter test --update-goldens test/offer_card_golden_test.dart` régénère
/// les images de `test/goldens/`.

Future<void> _loadPoppins() async {
  final loader = FontLoader('Poppins');
  loader.addFont(
    File(
      'assets/Poppins/Poppins-Regular.ttf',
    ).readAsBytes().then((b) => ByteData.view(b.buffer)),
  );
  await loader.load();
}

Offer _offer({
  required String name,
  String description = '',
  String? business,
  double price = 25,
  Fulfilment fulfilment = Fulfilment.order,
  double rating = 4.8,
  int reviewCount = 32,
  DateTime? startsAt,
}) => Offer(
  id: name,
  name: name,
  description: description,
  price: price,
  fulfilment: fulfilment,
  rating: rating,
  reviewCount: reviewCount,
  businessName: business,
  startsAt: startsAt,
);

void main() {
  setUpAll(_loadPoppins);

  testWidgets('le rail de cartes d\'offres', (tester) async {
    tester.view.physicalSize = const Size(1560, 700);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final offers = [
      _offer(
        name: 'Riz au poisson frais',
        description: 'Servi avec légumes de saison et sauce maison.',
        business: 'Mama Africa Resto',
      ),
      _offer(
        name: 'Suite Deluxe',
        description: 'Vue sur le fleuve, petit-déjeuner inclus.',
        business: 'Hôtel Béatrice',
        price: 120,
        fulfilment: Fulfilment.booking,
        rating: 4.4,
        reviewCount: 8,
      ),
      _offer(
        name: 'Crème hydratante karité',
        business: 'Nzuri Cosmetics',
        price: 0,
        fulfilment: Fulfilment.inStore,
        reviewCount: 0,
      ),
      _offer(
        name: 'Concert Fally Ipupa',
        description: 'Portes à 18h, première partie assurée.',
        business: 'Stade des Martyrs',
        price: 45,
        fulfilment: Fulfilment.booking,
        startsAt: DateTime(2026, 3, 14),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.silvaTheme,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppTheme.silvaTheme.colorScheme.surface,
          body: Center(
            child: SizedBox(
              height: 250,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: offers.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) => SizedBox(
                  width: 190,
                  child: OfferCard(offer: offers[i], onTap: () {}),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ListView),
      matchesGoldenFile('goldens/offer_card_rail.png'),
    );
  });
}
