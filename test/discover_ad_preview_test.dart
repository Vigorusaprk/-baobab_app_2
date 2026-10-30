import 'dart:math';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/discover_entry.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/discover_feed_composer.dart';
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
  test('place un aperçu fictif au sixième emplacement en mode debug', () {
    final items = List.generate(
      6,
      (i) => DiscoverEntry.business(_business('b$i')),
    );
    final result = DiscoverFeedComposer(
      random: Random(6),
    ).compose(items, const [], previewAdvertisement: true);
    expect(result.where((item) => item.isPreviewAdvertisement), hasLength(1));
    expect(result[5].id, 'ad-preview');
  });
}
