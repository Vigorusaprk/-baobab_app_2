import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';

abstract class BusinessRepository {
  Future<List<Business>> getBusinesses();
  Future<List<Business>> getBusinessesByCategory(String category);
  Future<Business> getBusinessDetail(String businessId);
  Future<List<BusinessReview>> getBusinessReviews(String businessId);
  Future<void> toggleFavorite(String businessId);
  Future<bool> isFavorite(String businessId);
  Future<List<Business>> searchBusinesses(String query);
}