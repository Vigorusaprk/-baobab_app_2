import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';
import 'package:baobabe_0_2/core/database/database_helper.dart';

class ReservationApiService {
  final SupabaseClient _supabase;
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Connectivity _connectivity = Connectivity();

  ReservationApiService([SupabaseClient? supabase])
    : _supabase = supabase ?? Supabase.instance.client;

  String _resolveUserId(String? userId) {
    final trimmedUserId = userId?.trim();
    final finalUserId = (trimmedUserId != null && trimmedUserId.isNotEmpty)
        ? trimmedUserId
        : _supabase.auth.currentUser?.id;

    if (finalUserId == null || finalUserId.isEmpty) {
      final currentSessionUserId = _supabase.auth.currentUser?.id;
      throw Exception(
        'Utilisateur non authentifié. userId param=${userId ?? 'null'} currentSupabaseUser=$currentSessionUserId',
      );
    }

    return finalUserId;
  }

  Future<Map<String, dynamic>> createReservation({
    required String businessId,
    required String type,
    required DateTime reservationDate,
    required double totalAmount,
    required Map<String, dynamic> details,
    String? establishmentName,
    String? userId,
  }) async {
    final finalUserId = _resolveUserId(userId);
    if (kDebugMode) {
      print('ReservationApiService.createReservation: user_id=$finalUserId');
    }

    final payload = {
      'business_id': businessId,
      'user_id': finalUserId,
      'type': type,
      'reservation_date': reservationDate.toIso8601String(),
      'total_amount': totalAmount,
      'details': {...details, 'establishment_name': ?establishmentName},
    };

    try {
      final response = await _supabase
          .from('reservations')
          .insert(payload)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Erreur lors de la création de la réservation: $e');
    }
  }

  Future<List<Reservation>> getReservations({String? userId}) async {
    final finalUserId = _resolveUserId(userId);

    final connectivityResult = await _connectivity.checkConnectivity();
    final isOnline = connectivityResult.any(
      (element) => element != ConnectivityResult.none,
    );

    if (!isOnline) {
      final cached = await _db.getCache('reservations_$finalUserId');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded
            .map((json) => Reservation.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    try {
      final response = await _supabase
          .from('reservations')
          .select('*')
          .eq('user_id', finalUserId)
          .order('reservation_date', ascending: false);

      final data = response as List<dynamic>;
      if (kDebugMode) {
        print(
          'ReservationApiService.getReservations: fetched ${data.length} rows from Supabase.',
        );
      }

      // Si le join a été retiré, on tente un chargement manuel des noms pour les anciennes lignes
      final needManualBusinessLoad = data.any(
        (item) =>
            (item['establishment_name'] == null ||
                item['establishment_name'].toString().isEmpty) &&
            (item['details'] == null ||
                (item['details'] as Map)['establishment_name'] == null) &&
            item['business_id'] != null,
      );

      if (needManualBusinessLoad) {
        final businessIds = data
            .map((item) => item['business_id']?.toString())
            .whereType<String>()
            .toSet()
            .toList();

        if (businessIds.isNotEmpty) {
          final businessResponse = await _supabase
              .from('business')
              .select('id, name')
              .inFilter('id', businessIds);

          final businessNames = {
            for (var b in (businessResponse as List))
              b['id'].toString(): b['name'].toString(),
          };

          for (var item in data) {
            final bId = item['business_id']?.toString();
            if (item['business'] == null &&
                bId != null &&
                businessNames.containsKey(bId)) {
              item['business'] = {'name': businessNames[bId]};
            }
          }
        }
      }

      final reservations = data
          .map((json) => Reservation.fromJson(json as Map<String, dynamic>))
          .toList();

      // Sauvegarder dans le cache
      final reservationsJson = jsonEncode(
        reservations.map((e) => e.toJson()).toList(),
      );
      await _db.saveCache('reservations_$finalUserId', reservationsJson);

      return reservations;
    } catch (e) {
      // Fallback au cache en cas d'erreur API
      final cached = await _db.getCache('reservations_$finalUserId');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded
            .map((json) => Reservation.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Erreur lors du chargement des réservations: $e');
    }
  }

  Future<void> deleteReservation(String reservationId, {String? userId}) async {
    final finalUserId = _resolveUserId(userId);

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
