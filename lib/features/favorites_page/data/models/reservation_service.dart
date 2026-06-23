import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';

class ReservationApiService {
  final SupabaseClient _supabase;

  ReservationApiService([SupabaseClient? supabase])
      : _supabase = supabase ?? Supabase.instance.client;

  Future<Map<String, dynamic>> createReservation({
    required String businessId,
    required String type,
    required DateTime reservationDate,
    required double totalAmount,
    required Map<String, dynamic> details,
    String? userId,
  }) async {
    final finalUserId = userId ?? _supabase.auth.currentUser?.id;
    if (finalUserId == null) {
      throw Exception('Utilisateur non authentifié. Veuillez vous connecter.');
    }

    final payload = {
      'business_id': businessId,
      'user_id': finalUserId,
      'type': type,
      'reservation_date': reservationDate.toIso8601String(),
      'total_amount': totalAmount,
      'details': details,
    };

    try {
      final response = await _supabase
          .from('reservations')
          .insert(payload)
          .select()
          .single();

      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Erreur lors de la création de la réservation: $e');
    }
  }

  Future<List<Reservation>> getReservations({String? userId}) async {
    final finalUserId = userId ?? _supabase.auth.currentUser?.id;
    if (finalUserId == null) {
      throw Exception('Utilisateur non authentifié');
    }

    try {
      final response = await _supabase
          .from('reservations')
          .select()
          .eq('user_id', finalUserId)
          .order('reservation_date', ascending: false);

      final data = response as List<dynamic>;
        return data
          .map((json) => Reservation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des réservations: $e');
    }
  }

  Future<void> deleteReservation(String reservationId, {String? userId}) async {
    final finalUserId = userId ?? _supabase.auth.currentUser?.id;
    if (finalUserId == null) {
      throw Exception('Utilisateur non authentifié');
    }

    try {
      await _supabase
          .from('reservations')
          .delete()
          .eq('id', reservationId)
          .eq('user_id', finalUserId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }
}
