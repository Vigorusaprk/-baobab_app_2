import 'dart:convert';
import 'package:baobabe_0_2/core/database/database_helper.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/home_page/data/data_sources/remote_datasource/business_remote_datasource.dart';
import 'package:baobabe_0_2/features/home_page/data/models/business_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BusinessRemoteDataSourceImpl implements BusinessRemoteDataSource {
  final SupabaseClient _supabase;
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Connectivity _connectivity = Connectivity();

  BusinessRemoteDataSourceImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  // REMARQUE : Vérifiez bien dans votre tableau de bord Supabase si la table
  // s'appelle 'business' ou 'businesses'. J'ai utilisé 'business' ci-dessous.
  static const String _tableName = 'business';

  @override
  Future<List<BusinessModel>> getBusinesses() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final isOnline = connectivityResult.any((element) => element != ConnectivityResult.none);

    if (!isOnline) {
      final cached = await _db.getCache('all_businesses');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded.map((json) => BusinessModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    }

    try {
      final response = await _supabase.from(_tableName).select();
      final businesses = (response as List)
          .map((json) => BusinessModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Sauvegarde Cache
      await _db.saveCache('all_businesses', jsonEncode(businesses.map((e) => e.toJson()).toList()));

      return businesses;
    } catch (e) {
      final cached = await _db.getCache('all_businesses');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded.map((json) => BusinessModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw Exception('Erreur Supabase lors du chargement des businesses : $e');
    }
  }

  @override
  Future<BusinessModel> getBusinessDetail(String businessId) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final isOnline = connectivityResult.any((element) => element != ConnectivityResult.none);

    if (!isOnline) {
      final cached = await _db.getCache('business_detail_$businessId');
      if (cached != null) {
        return BusinessModel.fromJson(jsonDecode(cached));
      }
      throw Exception('Mode hors-ligne : détail non disponible pour cet établissement.');
    }

    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', businessId)
          .maybeSingle();

      if (response == null) {
        throw Exception('Business non trouvé avec l\'ID : $businessId');
      }

      final business = BusinessModel.fromJson(response as Map<String, dynamic>);
      
      // Sauvegarde Cache
      await _db.saveCache('business_detail_$businessId', jsonEncode(business.toJson()));

      return business;
    } catch (e) {
      final cached = await _db.getCache('business_detail_$businessId');
      if (cached != null) {
        return BusinessModel.fromJson(jsonDecode(cached));
      }
      throw Exception('Erreur Supabase lors du chargement du détail business : $e');
    }
  }

  @override
  Future<List<BusinessModel>> getBusinessesByCategory(String category) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final isOnline = connectivityResult.any((element) => element != ConnectivityResult.none);

    if (!isOnline) {
      final cached = await _db.getCache('businesses_cat_$category');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded.map((json) => BusinessModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    }

    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('type', category);

      final businesses = (response as List)
          .map((json) => BusinessModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Sauvegarde Cache
      await _db.saveCache('businesses_cat_$category', jsonEncode(businesses.map((e) => e.toJson()).toList()));

      return businesses;
    } catch (e) {
      final cached = await _db.getCache('businesses_cat_$category');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded.map((json) => BusinessModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw Exception('Erreur Supabase lors de la recherche par catégorie : $e');
    }
  }

  @override
  Future<List<MenuItem>> getMenuByBusiness(String businessId) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final isOnline = connectivityResult.any((element) => element != ConnectivityResult.none);

    if (!isOnline) {
      final cached = await _db.getCache('menu_$businessId');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded.map((json) => MenuItem.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    }

    try {
      final response = await _supabase
          .from('menu_items')
          .select()
          .eq('business_id', businessId);

      final menu = (response as List)
          .map((json) => MenuItem.fromJson(json as Map<String, dynamic>))
          .toList();

      // Sauvegarde Cache
      await _db.saveCache('menu_$businessId', jsonEncode(menu.map((e) => e.toJson()).toList()));

      return menu;
    } catch (e) {
      final cached = await _db.getCache('menu_$businessId');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded.map((json) => MenuItem.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw Exception('Erreur Supabase lors de la récupération du menu : $e');
    }
  }

  @override
  Future<void> createReservation(Reservation reservation) async {
    // La logique de création est déjà gérée par le SyncService globalement
    // mais si on appelle directement ce repository, on garde le comportement online
    try {
      await _supabase
          .from('reservations')
          .insert(reservation.toJson(isNew: true));
    } catch (e) {
      throw Exception('Erreur Supabase lors de la création de la réservation : $e');
    }
  }
}
