// reservation_service.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'reservation_model.dart';

class ReservationService {
  static const String _reservationsKey = 'user_reservations';

  // Sauvegarder une réservation
  static Future<void> saveReservation(Reservation reservation) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> reservations = prefs.getStringList(_reservationsKey) ?? [];

    reservations.add(json.encode(reservation.toMap()));
    await prefs.setStringList(_reservationsKey, reservations);
  }

  // Récupérer toutes les réservations
  static Future<List<Reservation>> getReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> reservationsData = prefs.getStringList(_reservationsKey) ?? [];

    return reservationsData.map((data) {
      final map = json.decode(data);
      return Reservation.fromMap(Map<String, dynamic>.from(map));
    }).toList();
  }

  // Supprimer une réservation
  static Future<void> deleteReservation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> reservations = prefs.getStringList(_reservationsKey) ?? [];

    reservations.removeWhere((data) {
      final map = json.decode(data);
      return map['id'] == id;
    });

    await prefs.setStringList(_reservationsKey, reservations);
  }
}