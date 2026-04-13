import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/favorites_page/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/home_page/data/models/business_model.dart';

abstract class BusinessRemoteDataSource {
  Future<List<BusinessModel>> getBusinesses();
  Future<BusinessModel> getBusinessDetail(String businessId);
  Future<List<BusinessModel>> getBusinessesByCategory(String category);
  Future<List<MenuItem>> getMenuByBusiness(String businessId);
  Future<void> createReservation(ReservationModel reservation);
}