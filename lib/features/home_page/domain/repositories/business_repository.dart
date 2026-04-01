import 'package:baobabe_0_2/features/business_detail/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';

abstract class BusinessRepository {
  Future<List<Business>> getBusinesses();
  Future<List<Business>> getBusinessesByCategory(String category);
  Future<Business> getBusinessDetail(String businessId);
  Future<List<BusinessReview>> getBusinessReviews(String businessId);
  Future<void> toggleFavorite(String businessId);
  Future<bool> isFavorite(String businessId);
  Future<List<Business>> searchBusinesses(String query);
  Future<List<MenuItem>> getMenuByBusiness(String businessId);
  Future<void> createReservation(ReservationModel reservation);
}