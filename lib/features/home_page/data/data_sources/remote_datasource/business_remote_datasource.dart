// lib/features/business/data/datasources/business_remote_datasource.dart
import 'package:baobabe_0_2/features/home_page/data/models/business_model.dart';

abstract class BusinessRemoteDataSource {
  Future<List<BusinessModel>> getBusinesses();
  Future<BusinessModel> getBusinessDetail(String businessId);
  Future<List<BusinessModel>> getBusinessesByCategory(String category);
}