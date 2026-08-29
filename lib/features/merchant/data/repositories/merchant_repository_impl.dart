import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/data/models/business_model.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_space.dart';
import 'package:baobabe_0_2/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Accès à l'espace commerçant, entièrement via Edge Functions.
///
/// Aucun `.from('table')` ici : le commerce du demandeur est déterminé côté
/// serveur à partir de sa ligne `business_staff`. Le client n'a donc jamais
/// à transmettre — ni à pouvoir falsifier — l'identifiant du commerce sous
/// lequel il publie.
class MerchantRepositoryImpl implements MerchantRepository {
  final SupabaseClient _supabase;

  MerchantRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<MerchantSpace> getSpace() async {
    final json = await _invoke('get-merchant-space', method: HttpMethod.get);
    return _parseSpace(json);
  }

  @override
  Future<MerchantSpace> apply({
    required String businessName,
    required String categorySlug,
    required String address,
    required String phone,
    String? description,
  }) async {
    await _invoke(
      'create-merchant-application',
      body: {
        'businessName': businessName,
        'categorySlug': categorySlug,
        'address': address,
        'phone': phone,
        'description': description,
      },
    );
    // La demande est acceptée à la volée : on relit l'espace pour repartir
    // de ce que le serveur a réellement créé, jamais d'une supposition.
    return getSpace();
  }

  @override
  Future<void> createOffer(OfferDraft draft) =>
      _invoke('create-offer', body: draft.toBody());

  @override
  Future<void> updateOffer(String offerId, OfferDraft draft) =>
      _invoke('update-offer', body: {'offerId': offerId, ...draft.toBody()});

  @override
  Future<void> setOfferActive(String offerId, bool isActive) =>
      _invoke('update-offer', body: {'offerId': offerId, 'isActive': isActive});

  @override
  Future<void> updateOrderStatus(String orderId, String status) => _invoke(
    'update-order-status',
    body: {'orderId': orderId, 'status': status},
  );

  @override
  Future<void> updateReservationStatus(String reservationId, String status) =>
      _invoke(
        'update-reservation-status',
        body: {
          // L'identifiant d'une réservation est un entier en base ; le
          // transmettre en texte le ferait échouer à la comparaison.
          'reservationId': int.tryParse(reservationId) ?? reservationId,
          'status': status,
        },
      );

  /// Appelle une Edge Function et remonte son message d'erreur tel quel.
  ///
  /// Les fonctions de l'espace commerçant répondent en français et parlent
  /// du métier (« Vous gérez déjà un commerce ») : ces messages sont faits
  /// pour être montrés, pas remplacés par un « une erreur est survenue ».
  Future<Map<String, dynamic>> _invoke(
    String function, {
    Map<String, dynamic>? body,
    HttpMethod method = HttpMethod.post,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        function,
        method: method,
        body: body,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final error = data['error'];
        if (error != null) throw MerchantException(error.toString());
        return data;
      }
      return const {};
    } on FunctionException catch (e) {
      final details = e.details;
      final message = details is Map ? details['error']?.toString() : null;
      throw MerchantException(message ?? 'Opération refusée par le serveur');
    }
  }

  MerchantSpace _parseSpace(Map<String, dynamic> json) {
    final business = json['business'];
    if (business is! Map<String, dynamic>) {
      final application = json['application'];
      return MerchantSpace(
        application: application is Map<String, dynamic>
            ? MerchantApplication.fromJson(application)
            : null,
      );
    }

    List<T> parse<T>(String key, T Function(Map<String, dynamic>) build) {
      final list = (json[key] as List?) ?? const [];
      return list
          .map((e) => build(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return MerchantSpace(
      business: BusinessModel.fromJson(business).toEntity(),
      role: json['role']?.toString(),
      offers: parse('offers', Offer.fromJson),
      orders: parse('orders', ReceivedOrder.fromJson),
      reservations: parse('reservations', ReceivedReservation.fromJson),
      stats: MerchantStats.fromJson(
        Map<String, dynamic>.from((json['stats'] as Map?) ?? const {}),
      ),
    );
  }
}
