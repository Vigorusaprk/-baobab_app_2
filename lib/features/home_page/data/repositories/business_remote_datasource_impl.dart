import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/favorites_page/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/home_page/data/data_sources/remote_datasource/business_remote_datasource.dart';
import 'package:baobabe_0_2/features/home_page/data/models/business_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BusinessRemoteDataSourceImpl implements BusinessRemoteDataSource {
  final SupabaseClient _supabase;

  BusinessRemoteDataSourceImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  // REMARQUE : Vérifiez bien dans votre tableau de bord Supabase si la table
  // s'appelle 'business' ou 'businesses'. J'ai utilisé 'business' ci-dessous.
  static const String _tableName = 'business';

  @override
  Future<List<BusinessModel>> getBusinesses() async {
    try {
      final response = await _supabase.from(_tableName).select();

      return (response as List)
          .map((json) => BusinessModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur Supabase lors du chargement des businesses : $e');
    }
  }

  @override
  Future<BusinessModel> getBusinessDetail(String businessId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', businessId)
          .maybeSingle(); // Utilisation de maybeSingle pour éviter les crashs si non trouvé

      if (response == null) {
        throw Exception('Business non trouvé avec l\'ID : $businessId');
      }

      return BusinessModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erreur Supabase lors du chargement du détail business : $e');
    }
  }

  @override
  Future<List<BusinessModel>> getBusinessesByCategory(String category) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('type', category);

      return (response as List)
          .map((json) => BusinessModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur Supabase lors de la recherche par catégorie : $e');
    }
  }

  @override
  Future<List<MenuItem>> getMenuByBusiness(String businessId) async {
    try {
      final response = await _supabase
          .from('menu_items')
          .select()
          .eq('business_id', businessId);

      return (response as List)
          .map((json) => MenuItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur Supabase lors de la récupération du menu : $e');
    }
  }

  @override
  Future<void> createReservation(Reservation reservation) async {
    try {
      await _supabase
          .from('reservations')
          .insert(reservation.toJson());
    } catch (e) {
      throw Exception('Erreur Supabase lors de la création de la réservation : $e');
    }
  }
}