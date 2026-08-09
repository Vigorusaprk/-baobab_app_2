import 'package:supabase_flutter/supabase_flutter.dart';

class VehicleService {
  static Future<List<Map<String, dynamic>>> getVehicles(
    String businessId,
  ) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'get-business-detail',
        method: HttpMethod.get,
        queryParameters: {'id': businessId},
      );
      final data = (response.data as Map<String, dynamic>)['vehicles'] as List;

      return data
          .map(
            (item) => Map<String, dynamic>.from(item as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des véhicules: $e');
    }
  }
}
