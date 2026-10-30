import 'dart:math';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/discover_entry.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/discover_feed_composer.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/home_feed.dart';
import 'package:flutter_test/flutter_test.dart';

Business _business(String id) => Business(
  id: id,
  name: id,
  address: '',
  description: '',
  bgImg: '',
  profilImg: '',
  rating: 4,
  reviewCount: 1,
  openingHours: const {},
  type: BusinessType.other,
  phone: '',
  images: const [],
  specificData: const {},
  reviews: const [],
  isFavorite: false,
  isSponsored: false,
  createdAt: DateTime(2026),
);

void main() {
  test('mélange le flux sans reprendre l’ordre du serveur', () {
    final items = List.generate(
      8,
      (i) => DiscoverEntry.business(_business('b$i')),
    );
    final result = DiscoverFeedComposer(
      random: Random(4),
    ).compose(items, const []);
    expect(
      result.map((item) => item.id),
      isNot(orderedEquals(items.map((item) => item.id))),
    );
  });

  test('espace un commerce répété quand d’autres cartes sont disponibles', () {
    final ids = List.generate(
      6,
      (i) => 'b$i',
    ).followedBy(List.generate(6, (i) => 'b$i'));
    final items = ids
        .map((id) => DiscoverEntry.business(_business(id)))
        .toList();
    final result = DiscoverFeedComposer(
      random: Random(8),
    ).compose(items, const []);
    for (var index = 1; index < result.length; index++) {
      final start = max(0, index - 4);
      final recent = result.skip(start).take(index - start);
      expect(
        recent.map((entry) => entry.businessId),
        isNot(contains(result[index].businessId)),
        reason: result.map((entry) => entry.businessId).toList().toString(),
      );
    }
  });

  test(
    'insère une campagne après cinq cartes organiques, tous les six emplacements',
    () {
      final items = List.generate(
        12,
        (i) => DiscoverEntry.business(_business('b$i')),
      );
      final campaign = FeaturedBusiness(
        business: _business('ad'),
        campaignId: 'c1',
      );
      final result = DiscoverFeedComposer(
        random: Random(2),
      ).compose(items, [campaign]);
      expect(result.length, 14);
      expect(result[5].isAdvertisement, isTrue);
      expect(result[11].isAdvertisement, isTrue);
    },
  );

  test('n’insère pas une campagne déjà passée pour la session', () {
    final items = List.generate(
      6,
      (i) => DiscoverEntry.business(_business('b$i')),
    );
    final campaign = FeaturedBusiness(
      business: _business('ad'),
      campaignId: 'c1',
    );
    final result = DiscoverFeedComposer(
      random: Random(2),
    ).compose(items, [campaign], skippedIds: const {'ad:c1'});
    expect(result.where((item) => item.isAdvertisement), isEmpty);
  });
}
