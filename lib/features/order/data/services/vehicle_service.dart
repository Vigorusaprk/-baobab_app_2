import 'dart:convert';
import 'package:http/http.dart' as http;

class VehicleService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  /// Récupérer les véhicules disponibles pour un commerce
  static Future<List<Map<String, dynamic>>> getVehicles(String businessId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/businesses/$businessId/vehicles'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des véhicules: $e');
    }
  }
}
