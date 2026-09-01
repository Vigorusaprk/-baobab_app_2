import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/home_page/data/models/business_model.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/home_feed.dart';

abstract class BusinessRemoteDataSource {
  Future<List<BusinessModel>> getBusinesses();
  Future<BusinessModel> getBusinessDetail(String businessId);
  Future<List<BusinessModel>> getBusinessesByCategory(String category);

  /// Toutes les sections de la page d'accueil pour [category], en un seul
  /// aller-retour (voir l'Edge Function `get-home`).
  Future<HomeFeed> getHomeFeed({String? category});

  /// Page suivante d'une section paginée de l'accueil : `discover` (les
  /// mieux notées) ou `new` (les nouveautés, derrière « Voir plus »).
  Future<OffersPage> getOffersPage({
    required String section,
    required int page,
    String? category,
  });

  Future<({List<BusinessModel> items, bool hasMore})> getBusinessesPage({
    required int page,
    String? category,
    String? query,
  });
  Future<List<MenuItem>> getMenuByBusiness(String businessId);
  Future<void> createReservation(Reservation reservation);
}
