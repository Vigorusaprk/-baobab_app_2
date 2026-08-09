import 'dart:convert';
import 'package:baobabe_0_2/core/database/database_helper.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/home_page/data/data_sources/remote_datasource/business_remote_datasource.dart';
import 'package:baobabe_0_2/features/home_page/data/models/business_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Toute la lecture/écriture passe par des Edge Functions (voir
/// supabase/functions dans le projet Supabase) plutôt que par des appels
/// `.from('table')` directs : ça laisse la place à de la pagination, de
/// l'agrégation multi-tables en un aller-retour, et une logique métier
/// centralisée côté serveur plutôt que dupliquée dans chaque client.
class BusinessRemoteDataSourceImpl implements BusinessRemoteDataSource {
  final SupabaseClient _supabase;
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Connectivity _connectivity = Connectivity();

  BusinessRemoteDataSourceImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  Future<bool> get _isOnline async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult.any(
      (element) => element != ConnectivityResult.none,
    );
  }

  @override
  Future<List<BusinessModel>> getBusinesses() async {
    if (!await _isOnline) {
      final cached = await _db.getCache('all_businesses');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded
            .map((json) => BusinessModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    try {
      final response = await _supabase.functions.invoke(
        'get-home',
        method: HttpMethod.get,
        queryParameters: {'pageSize': '50'},
      );
      final data = (response.data as Map<String, dynamic>)['data'] as List;
      final businesses = data
          .map((json) => BusinessModel.fromJson(json as Map<String, dynamic>))
          .toList();

      await _db.saveCache(
        'all_businesses',
        jsonEncode(businesses.map((e) => e.toJson()).toList()),
      );
      return businesses;
    } catch (e) {
      final cached = await _db.getCache('all_businesses');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded
            .map((json) => BusinessModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception(
        'Erreur Edge Function (home-feed) lors du chargement des businesses : $e',
      );
    }
  }

  @override
  Future<BusinessModel> getBusinessDetail(String businessId) async {
    if (!await _isOnline) {
      final cached = await _db.getCache('business_detail_$businessId');
      if (cached != null) {
        return BusinessModel.fromJson(jsonDecode(cached));
      }
      throw Exception(
        'Mode hors-ligne : détail non disponible pour cet établissement.',
      );
    }

    try {
      final response = await _supabase.functions.invoke(
        'get-business-detail',
        method: HttpMethod.get,
        queryParameters: {'id': businessId},
      );
      final json =
          (response.data as Map<String, dynamic>)['business']
              as Map<String, dynamic>;
      final business = BusinessModel.fromJson(json);

      await _db.saveCache(
        'business_detail_$businessId',
        jsonEncode(business.toJson()),
      );
      return business;
    } catch (e) {
      final cached = await _db.getCache('business_detail_$businessId');
      if (cached != null) {
        return BusinessModel.fromJson(jsonDecode(cached));
      }
      throw Exception(
        'Erreur Edge Function (business-detail) lors du chargement du détail business : $e',
      );
    }
  }

  @override
  Future<List<BusinessModel>> getBusinessesByCategory(String category) async {
    if (!await _isOnline) {
      final cached = await _db.getCache('businesses_cat_$category');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded
            .map((json) => BusinessModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    try {
      final response = await _supabase.functions.invoke(
        'get-home',
        method: HttpMethod.get,
        queryParameters: {'category': category, 'pageSize': '50'},
      );
      final data = (response.data as Map<String, dynamic>)['data'] as List;
      final businesses = data
          .map((json) => BusinessModel.fromJson(json as Map<String, dynamic>))
          .toList();

      await _db.saveCache(
        'businesses_cat_$category',
        jsonEncode(businesses.map((e) => e.toJson()).toList()),
      );
      return businesses;
    } catch (e) {
      final cached = await _db.getCache('businesses_cat_$category');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded
            .map((json) => BusinessModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception(
        'Erreur Edge Function (home-feed) lors de la recherche par catégorie : $e',
      );
    }
  }

  @override
  Future<({List<BusinessModel> items, bool hasMore})> getBusinessesPage({
    required int page,
    String? category,
  }) async {
    // Pas de secours hors-ligne ici : la 1ère page (getBusinesses) a déjà
    // son cache, "charger plus" est un enrichissement progressif, pas le
    // contenu principal de l'écran.
    final response = await _supabase.functions.invoke(
      'get-home',
      method: HttpMethod.get,
      queryParameters: {
        'page': '$page',
        if (category != null && category.isNotEmpty) 'category': category,
      },
    );
    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as List;
    final items = data
        .map((item) => BusinessModel.fromJson(item as Map<String, dynamic>))
        .toList();
    return (items: items, hasMore: json['hasMore'] as bool? ?? false);
  }

  @override
  Future<List<MenuItem>> getMenuByBusiness(String businessId) async {
    if (!await _isOnline) {
      final cached = await _db.getCache('menu_$businessId');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded
            .map((json) => MenuItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    try {
      final response = await _supabase.functions.invoke(
        'get-business-detail',
        method: HttpMethod.get,
        queryParameters: {'id': businessId},
      );
      final data = (response.data as Map<String, dynamic>)['menuItems'] as List;
      final menu = data
          .map((json) => MenuItem.fromJson(json as Map<String, dynamic>))
          .toList();

      await _db.saveCache(
        'menu_$businessId',
        jsonEncode(menu.map((e) => e.toJson()).toList()),
      );
      return menu;
    } catch (e) {
      final cached = await _db.getCache('menu_$businessId');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded
            .map((json) => MenuItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception(
        'Erreur Edge Function (business-detail) lors de la récupération du menu : $e',
      );
    }
  }

  @override
  Future<void> createReservation(Reservation reservation) async {
    try {
      await _supabase.functions.invoke(
        'create-reservation',
        method: HttpMethod.post,
        body: {
          'businessId': reservation.businessId,
          'type': reservation.type,
          'reservationDate': reservation.reservationDate.toIso8601String(),
          'totalAmount': reservation.totalAmount,
          'details': reservation.details,
          'establishmentName': reservation.establishmentName,
        },
      );
    } catch (e) {
      throw Exception(
        'Erreur Edge Function (create-reservation) lors de la création de la réservation : $e',
      );
    }
  }
}
