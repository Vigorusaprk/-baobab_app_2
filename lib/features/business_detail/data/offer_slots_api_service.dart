import 'package:baobabe_0_2/features/business_detail/domain/entities/offer_availability.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Les créneaux d'une offre, servis par `get-offer-slots`.
///
/// Lu des deux côtés : le client pour choisir son rendez-vous, le commerçant
/// pour relire ce qu'il a déclaré. Une seule fonction, donc une seule
/// définition de ce qui est libre — deux calculs finiraient par diverger, et
/// c'est le client qui aurait tort au mauvais moment.
///
/// Lisible **sans compte** : on choisit son créneau avant de se connecter.
class OfferSlotsApiService {
  OfferSlotsApiService({SupabaseClient? supabase}) : _override = supabase;

  final SupabaseClient? _override;

  /// Résolu à l'usage et non à la construction : un double de test qui
  /// redéfinit [getAvailability] ne touche jamais au client, et n'a donc
  /// pas besoin d'un Supabase initialisé pour exister.
  SupabaseClient get _supabase => _override ?? Supabase.instance.client;

  Future<OfferAvailability> getAvailability(
    String offerId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await _supabase.functions.invoke(
      'get-offer-slots',
      method: HttpMethod.get,
      queryParameters: {
        'id': offerId,
        if (from != null) 'from': _day(from),
        if (to != null) 'to': _day(to),
      },
    );

    final data = response.data;
    if (data is! Map) {
      throw const OfferSlotsException('Créneaux illisibles');
    }
    final json = Map<String, dynamic>.from(data);
    final error = json['error'];
    if (error != null) throw OfferSlotsException(error.toString());

    return OfferAvailability.fromJson(json);
  }

  static String _day(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

/// Erreur déjà rédigée pour l'utilisateur.
class OfferSlotsException implements Exception {
  const OfferSlotsException(this.message);

  final String message;

  @override
  String toString() => message;
}
