import 'package:supabase_flutter/supabase_flutter.dart';

class VehicleService {
  static Future<List<Map<String, dynamic>>> getVehicles(String businessId) async {
    try {
      final response = await Supabase.instance.client
          .from('vehicles')
          .select()
          .eq('business_id', businessId);

      return (response as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des véhicules: $e');
    }
  }
}
