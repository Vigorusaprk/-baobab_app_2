import 'package:baobabe_0_2/features/home_page/domain/entities/budget_filter.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_match.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/budget_finder_repository.dart';

/// Implémentation temporaire en dur, le temps de brancher Supabase
/// (voir vue `business_with_avg_price` créée sur le projet).
class MockBudgetFinderRepository implements BudgetFinderRepository {
  /// Prix moyen par business, simulé ici. Dans la vraie implémentation
  /// Supabase, cette valeur viendra directement de la colonne
  /// `average_price` renvoyée par la vue `business_with_avg_price`.
  final Map<String, double> _mockAveragePrices = {
    '1': 12000,
    '2': 28000,
    '3': 55000,
  };

  @override
  Future<List<BusinessMatch>> findMatches(BudgetFilter budget) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final matches = _mockBusinesses().map((business) {
      final averagePrice = _mockAveragePrices[business.id];
      return BusinessMatch(
        business: business,
        averagePrice: averagePrice,
        matchesBudget: budget.matches(averagePrice),
      );
    }).toList();

    // Ceux qui matchent le budget en premier.
    matches.sort((a, b) {
      if (a.matchesBudget != b.matchesBudget) {
        return a.matchesBudget ? -1 : 1;
      }
      return 0;
    });

    return matches;
  }

  // TODO: remplacer par un vrai appel Supabase sur `business_with_avg_price`.
  List<Business> _mockBusinesses() => [
    Business(
      id: '1',
      name: 'Chez Fatou',
      address: '12 Avenue de la Paix, Gombe',
      description: 'Cuisine congolaise traditionnelle.',
      bgImg: '',
      profilImg: '',
      rating: 4.5,
      reviewCount: 32,
      openingHours: const {},
      type: BusinessType.restaurant,
      phone: '+243900000001',
      images: const [],
      specificData: const {},
      reviews: const [],
      isFavorite: false,
      isSponsored: false,
      createdAt: DateTime.now(),
    ),
    Business(
      id: '2',
      name: 'Spa Lumière',
      address: '45 Boulevard du 30 Juin, Gombe',
      description: 'Spa et bien-être en plein centre.',
      bgImg: '',
      profilImg: '',
      rating: 4.8,
      reviewCount: 51,
      openingHours: const {},
      type: BusinessType.spa,
      phone: '+243900000002',
      images: const [],
      specificData: const {},
      reviews: const [],
      isFavorite: false,
      isSponsored: true,
      createdAt: DateTime.now(),
    ),
    Business(
      id: '3',
      name: 'Hôtel Baobab',
      address: '3 Avenue Kalemie, Gombe',
      description: 'Hôtel confortable proche du fleuve.',
      bgImg: '',
      profilImg: '',
      rating: 4.2,
      reviewCount: 19,
      openingHours: const {},
      type: BusinessType.hotel,
      phone: '+243900000003',
      images: const [],
      specificData: const {},
      reviews: const [],
      isFavorite: false,
      isSponsored: false,
      createdAt: DateTime.now(),
    ),
  ];
}