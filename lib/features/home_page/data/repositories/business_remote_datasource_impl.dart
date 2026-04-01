import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/home_page/data/data_sources/remote_datasource/business_remote_datasource.dart';
import 'package:baobabe_0_2/features/home_page/data/models/business_model.dart';
// AJOUT DE L'IMPORT
import 'package:baobabe_0_2/features/business_detail/data/models/reservation_model.dart';
import 'package:dio/dio.dart';

class BusinessRemoteDataSourceImpl implements BusinessRemoteDataSource {
  final Dio _dio;
  final String _baseUrl;

  BusinessRemoteDataSourceImpl({Dio? dio, String baseUrl = 'http://10.0.2.2:3000/api'})
      : _dio = dio ?? Dio(),
        _baseUrl = baseUrl;

  @override
  Future<List<BusinessModel>> getBusinesses() async {
    try {
      final response = await _dio.get('$_baseUrl/businesses');
      return (response.data as List)
          .map((json) => BusinessModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load businesses: $e');
    }
  }

  // AJOUT DE LA MÉTHODE createReservation
  @override
  Future<void> createReservation(ReservationModel reservation) async {
    try {
      // Envoi du JSON au endpoint /reservations
      final response = await _dio.post(
        '$_baseUrl/reservations',
        data: reservation.toJson(),
      );

      // Vérification du statut (201 Created ou 200 OK)
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Erreur serveur lors de la création de la réservation');
      }
    } on DioException catch (e) {
      // Gestion spécifique des erreurs Dio
      final errorMessage = e.response?.data?['error'] ?? e.message;
      throw Exception('Erreur réseau : $errorMessage');
    } catch (e) {
      throw Exception('Échec de la réservation : $e');
    }
  }

  @override
  Future<BusinessModel> getBusinessDetail(String businessId) async {
    final response = await _dio.get('$_baseUrl/businesses/$businessId');
    return BusinessModel.fromJson(response.data);
  }

  @override
  Future<List<BusinessModel>> getBusinessesByCategory(String category) async {
    final response = await _dio.get(
      '$_baseUrl/businesses',
      queryParameters: {'category': category},
    );
    return (response.data as List)
        .map((json) => BusinessModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<MenuItem>> getMenuByBusiness(String businessId) async {
    try {
      // Appel à votre route Node.js (ex: /businesses/res_01/menu)
      final response = await _dio.get('$_baseUrl/businesses/$businessId/menu');

      if (response.statusCode == 200) {
        final List data = response.data;
        // Utilisation du constructeur fromJson adapté au snake_case SQL
        return data.map((json) => MenuItem.fromJson(json)).toList();
      } else {
        throw Exception('Erreur serveur lors de la récupération du menu');
      }
    } catch (e) {
      throw Exception('Erreur de connexion API: $e');
    }
  }
}