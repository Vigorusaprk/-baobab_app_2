import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/businesses_page.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/home_feed.dart';

abstract class BusinessRepository {
  Future<List<Business>> getBusinesses();
  Future<List<Business>> getBusinessesByCategory(String category);

  /// Toutes les sections de la page d'accueil pour [category] (null =
  /// toutes catégories), déjà filtrées et triées côté serveur.
  Future<HomeFeed> getHomeFeed({String? category});

  /// Page suivante d'une section paginée de l'accueil : `discover` ou `new`.
  Future<OffersPage> getOffersPage({
    required String section,
    required int page,
    String? category,
  });

  Future<BusinessesPage> getBusinessesPage({
    required int page,
    String? category,
  });
  Future<Business> getBusinessDetail(String businessId);
  Future<List<BusinessReview>> getBusinessReviews(String businessId);
  Future<void> toggleFavorite(String businessId);
  Future<bool> isFavorite(String businessId);
  Future<List<Business>> searchBusinesses(String query);
  Future<List<MenuItem>> getMenuByBusiness(String businessId);
  Future<void> createReservation(Reservation reservation);
}
