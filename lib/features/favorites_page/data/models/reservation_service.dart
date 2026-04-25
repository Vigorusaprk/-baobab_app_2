import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';

class ReservationApiService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api';
  
  // Pour web: http://localhost:3000/api
  // Pour émulateur Android: http://10.0.2.2:3000/api
  // Pour émulateur iOS: http://localhost:3000/api

  /// Récupérer l'ID utilisateur depuis SharedPreferences
  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  /// Récupérer le token d'authentification depuis SharedPreferences
  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// Headers HTTP avec authentification
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Créer une nouvelle réservation
  Future<Map<String, dynamic>> createReservation({
    required String businessId,
    required String type,
    required DateTime reservationDate,
    required double totalAmount,
    required Map<String, dynamic> details,
    String? userId,
  }) async {
    // Utiliser l'userId fourni, sinon le récupérer depuis SharedPreferences
    final finalUserId = userId ?? await _getUserId();
    if (finalUserId == null) {
      throw Exception('Utilisateur non authentifié. Veuillez vous connecter.');
    }

    final headers = await _getHeaders();
    
    final payload = {
      'business_id': businessId,
      'user_id': finalUserId,
      'type': type,
      'reservation_date': reservationDate.toIso8601String(),
      'total_amount': totalAmount,
      'details': details,
    };

    print('📤 Envoi de la réservation: ${jsonEncode(payload)}');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reservations'),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Erreur ${response.statusCode}: ${response.body}'
        );
      }
    } catch (e) {
      throw Exception('Erreur lors de la création de la réservation: $e');
    }
  }

  /// Récupérer toutes les réservations de l'utilisateur
  Future<List<Reservation>> getReservations({String? userId}) async {
    // Utiliser l'userId fourni, sinon le récupérer depuis SharedPreferences
    final finalUserId = userId ?? await _getUserId();
    if (finalUserId == null) {
      throw Exception('Utilisateur non authentifié');
    }

    final headers = await _getHeaders();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reservations').replace(
          queryParameters: {'user_id': finalUserId},
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => Reservation.fromMap(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Erreur ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des réservations: $e');
    }
  }

  /// Supprimer une réservation
  Future<void> deleteReservation(String reservationId, {String? userId}) async {
    final headers = await _getHeaders();

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/reservations/$reservationId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }
}