import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/home_page/data/data_sources/remote_datasource/business_remote_datasource.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/businesses_page.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/home_feed.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/business_repository.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  final BusinessRemoteDataSource remoteDataSource;

  BusinessRepositoryImpl({required this.remoteDataSource});

  // AJOUT DE LA MÉTHODE createReservation
  @override
  Future<void> createReservation(Reservation reservation) async {
    try {
      // Transmet la demande à la source de données remote
      await remoteDataSource.createReservation(reservation);
    } catch (e) {
      // Vous pouvez logger l'erreur ici
      rethrow; // Propulser l'erreur pour que l'UI puisse la gérer
    }
  }

  @override
  Future<List<Business>> getBusinesses() async {
    final models = await remoteDataSource.getBusinesses();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Business>> getBusinessesByCategory(String category) async {
    final models = await remoteDataSource.getBusinessesByCategory(category);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<HomeFeed> getHomeFeed({String? category}) =>
      remoteDataSource.getHomeFeed(category: category);

  @override
  Future<OffersPage> getOffersPage({
    required String section,
    required int page,
    String? category,
  }) => remoteDataSource.getOffersPage(
    section: section,
    page: page,
    category: category,
  );

  @override
  Future<BusinessesPage> getBusinessesPage({
    required int page,
    String? category,
  }) async {
    final result = await remoteDataSource.getBusinessesPage(
      page: page,
      category: category,
    );
    return BusinessesPage(
      items: result.items.map((model) => model.toEntity()).toList(),
      hasMore: result.hasMore,
    );
  }

  @override
  Future<Business> getBusinessDetail(String businessId) async {
    final model = await remoteDataSource.getBusinessDetail(businessId);
    return model.toEntity();
  }

  @override
  Future<List<BusinessReview>> getBusinessReviews(String businessId) async {
    final business = await getBusinessDetail(businessId);
    return business.reviews;
  }

  @override
  Future<void> toggleFavorite(String businessId) async {
    // À implémenter avec une API /favorites
  }

  @override
  Future<bool> isFavorite(String businessId) async {
    return false;
  }

  @override
  Future<List<Business>> searchBusinesses(String query) async {
    final all = await getBusinesses();
    return all
        .where(
          (b) =>
              b.name.toLowerCase().contains(query.toLowerCase()) ||
              b.address.toLowerCase().contains(query.toLowerCase()) ||
              b.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // NOUVELLE MÉTHODE IMPLÉMENTÉE
  @override
  Future<List<MenuItem>> getMenuByBusiness(String businessId) async {
    try {
      // On récupère les modèles depuis la source de données
      return await remoteDataSource.getMenuByBusiness(businessId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du menu: $e');
    }
  }
}
