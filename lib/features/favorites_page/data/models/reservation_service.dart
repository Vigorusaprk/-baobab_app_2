import 'package:baobabe_0_2/features/favorites_page/data/models/reservation_model.dart';
import 'package:dio/dio.dart';


class ReservationApiService {
  final Dio _dio;
  final String _baseUrl;

  ReservationApiService({Dio? dio, String baseUrl = 'http://10.0.2.2:3000/api'})
      : _dio = dio ?? Dio(),
        _baseUrl = baseUrl;

  Future<List<Reservation>> getReservations(String userId) async {
    try {
      final response = await _dio.get('$_baseUrl/reservations', queryParameters: {
        'user_id': userId,
      });
      final List data = response.data;
      return data.map((json) => Reservation.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des réservations : $e');
    }
  }

  Future<void> deleteReservation(String reservationId) async {
    try {
      await _dio.delete('$_baseUrl/reservations/$reservationId');
    } catch (e) {
      throw Exception('Erreur lors de la suppression : $e');
    }
  }
}