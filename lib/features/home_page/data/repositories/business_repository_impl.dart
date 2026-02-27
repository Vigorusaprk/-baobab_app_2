import 'package:baobabe_0_2/features/home_page/data/data_sources/local_datasource/local_business_data.dart';
import 'package:baobabe_0_2/features/home_page/data/data_sources/remote_datasource/business_remote_datasource.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';

import '../../domain/repositories/business_repository.dart';
import '../models/business_model.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  final BusinessLocalDataSource localDataSource;
  final BusinessRemoteDataSource remoteDataSource;

  BusinessRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<Business>> getBusinesses() async {
    try {
      final models = await localDataSource.getBusinesses();
      return models.map((model) => model.toEntity()).toList();
    } catch (_) {
      final remoteModels = await remoteDataSource.getBusinesses();
      await localDataSource.cacheBusinesses(remoteModels);
      return remoteModels.map((model) => model.toEntity()).toList();
    }
  }

  @override
  Future<List<Business>> getBusinessesByCategory(String category) async {
    try {
      final models = await localDataSource.getBusinessesByCategory(category);
      return models.map((model) => model.toEntity()).toList();
    } catch (_) {
      final remoteModels = await remoteDataSource.getBusinessesByCategory(category);
      return remoteModels.map((model) => model.toEntity()).toList();
    }
  }

  @override
  Future<Business> getBusinessDetail(String businessId) async {
    try {
      final model = await localDataSource.getBusinessDetail(businessId);
      return model.toEntity();
    } catch (_) {
      final remoteModel = await remoteDataSource.getBusinessDetail(businessId);
      await localDataSource.cacheBusiness(remoteModel);
      return remoteModel.toEntity();
    }
  }

  @override
  Future<List<BusinessReview>> getBusinessReviews(String businessId) async {
    try {
      final business = await getBusinessDetail(businessId);
      return business.reviews;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> toggleFavorite(String businessId) async {
    await localDataSource.toggleFavorite(businessId);
  }

  @override
  Future<bool> isFavorite(String businessId) async {
    return await localDataSource.isFavorite(businessId);
  }

  @override
  Future<List<Business>> searchBusinesses(String query) async {
    final businesses = await getBusinesses();
    return businesses
        .where((business) =>
    business.name.toLowerCase().contains(query.toLowerCase()) ||
        business.address.toLowerCase().contains(query.toLowerCase()) ||
        business.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}