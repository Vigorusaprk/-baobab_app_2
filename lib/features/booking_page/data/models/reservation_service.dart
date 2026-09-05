import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';
import 'package:baobabe_0_2/core/database/local_cache.dart';

class ReservationApiService {
  final SupabaseClient _supabase;
  final LocalCache _db = LocalCache.instance;
  final Connectivity _connectivity = Connectivity();

  ReservationApiService([SupabaseClient? supabase])
    : _supabase = supabase ?? Supabase.instance.client;

  String _resolveUserId(String? userId) {
    final trimmedUserId = userId?.trim();
    final finalUserId = (trimmedUserId != null && trimmedUserId.isNotEmpty)
        ? trimmedUserId
        : _supabase.auth.currentUser?.id;

    if (finalUserId == null || finalUserId.isEmpty) {
      throw Exception('Utilisateur non authentifié.');
    }

    return finalUserId;
  }

  /// [userId] n'est plus envoyé au serveur : l'Edge Function résout
  /// l'utilisateur depuis le JWT de la requête. On garde la résolution
  /// locale juste pour lever une erreur claire avant l'appel réseau si
  /// personne n'est connecté.
  /// Réserve [quantity] unité(s) de l'offre [offerId].
  ///
  /// Le montant n'est plus transmis : le serveur le calcule depuis le
  /// catalogue, vérifie qu'il reste des places et refuse une date passée.
  /// [reservationDate] est ignorée pour une offre déjà datée (séance,
  /// concert), qui impose la sienne.
  Future<Map<String, dynamic>> createReservation({
    required String offerId,
    int quantity = 1,
    DateTime? reservationDate,
    String? notes,
    Map<String, dynamic>? details,
    String? userId,
  }) async {
    _resolveUserId(userId);

    try {
      final response = await _supabase.functions.invoke(
        'create-reservation',
        method: HttpMethod.post,
        body: {
          'offerId': offerId,
          'quantity': quantity,
          // `toUtc()` avant l'ISO, sans quoi `toIso8601String()` d'une date
          // locale sort « 2026-09-07T10:00:00.000 » — sans décalage. Postgres
          // la lit alors comme de l'UTC, et le rendez-vous se décale du
          // fuseau de l'appareil : à Kinshasa, le créneau de 10 h était
          // enregistré à 11 h. Le serveur vérifie désormais que la date
          // tombe sur un créneau déclaré, et refusait donc une heure que le
          // client venait de toucher.
          if (reservationDate != null)
            'reservationDate': reservationDate.toUtc().toIso8601String(),
          'notes': ?notes,
          'details': ?details,
        },
      );
      return (response.data as Map<String, dynamic>)['data']
          as Map<String, dynamic>;
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
      // `reservations-list` renvoie déjà le nom de l'établissement (embed
      // via la FK business_id) — plus besoin du deuxième aller-retour
      // manuel pour les anciennes lignes.
      final response = await _supabase.functions.invoke(
        'get-reservations-client',
        method: HttpMethod.get,
        queryParameters: {'pageSize': '50'},
      );
      final data = (response.data as Map<String, dynamic>)['data'] as List;
      final reservations = data
          .map((json) => Reservation.fromJson(json as Map<String, dynamic>))
          .toList();

      final reservationsJson = jsonEncode(
        reservations.map((e) => e.toJson()).toList(),
      );
      await _db.saveCache('reservations_$finalUserId', reservationsJson);

      return reservations;
    } catch (e) {
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
    _resolveUserId(userId);

    try {
      await _supabase.functions.invoke(
        'delete-reservation',
        method: HttpMethod.post,
        body: {'reservationId': reservationId},
      );
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }
}
