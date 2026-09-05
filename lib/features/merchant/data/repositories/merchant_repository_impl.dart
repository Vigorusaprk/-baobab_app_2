import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer_availability.dart';
import 'package:baobabe_0_2/features/home_page/data/models/business_model.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_extras.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_space.dart';
import 'package:baobabe_0_2/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:baobabe_0_2/features/settings/domain/entities/user_address.dart';

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
    required UserAddress address,
    required String phone,
    String? description,
  }) async {
    await _invoke(
      'create-merchant-application',
      body: {
        'businessName': businessName,
        'categorySlug': categorySlug,
        // L'adresse part **en pieces** : le serveur la range dans ses six
        // colonnes et compose lui-meme la ligne d'affichage. Une chaine
        // unique interdisait de lister les commerces d'une commune.
        'address': address.toJson(),
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

  @override
  Future<void> updateBusiness(String businessId, BusinessDraft draft) =>
      _invoke(
        'update-business',
        body: {'businessId': businessId, ...draft.toBody()},
      );

  @override
  Future<void> setAvailability({
    required String offerId,
    required int? durationMinutes,
    required int? slotCapacity,
    required List<AvailabilityRule> rules,
    required List<AvailabilityException> exceptions,
    int? leadTimeHours,
    int? horizonDays,
  }) => _invoke(
    'update-offer-availability',
    body: {
      'offerId': offerId,
      'durationMinutes': durationMinutes,
      'slotCapacity': slotCapacity,
      'leadTimeHours': ?leadTimeHours,
      'horizonDays': ?horizonDays,
      'rules': rules.map((rule) => rule.toBody()).toList(),
      'exceptions': exceptions.map((item) => item.toBody()).toList(),
    },
  );

  @override
  Future<AdBoard> getCampaigns({String? businessId}) async {
    final json = await _invoke(
      'get-ad-campaigns',
      method: HttpMethod.get,
      query: businessId == null ? null : {'businessId': businessId},
    );

    List<T> parse<T>(String key, T Function(Map<String, dynamic>) build) {
      final list = (json[key] as List?) ?? const [];
      return list
          .map((e) => build(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return AdBoard(
      isAdmin: json['isAdmin'] == true,
      prices: parse('prices', AdPrice.fromJson),
      campaigns: parse('campaigns', AdCampaign.fromJson),
      queue: parse('queue', AdCampaign.fromJson),
      applications: parse('applications', MerchantApplication.fromJson),
    );
  }

  @override
  Future<void> createCampaign({
    required String businessId,
    required AdPlacement placement,
    required DateTime startsOn,
    required DateTime endsOn,
    String? offerId,
  }) => _invoke(
    'create-ad-campaign',
    body: {
      'businessId': businessId,
      'placement': placement.asJson,
      'startsOn': _day(startsOn),
      'endsOn': _day(endsOn),
      'offerId': offerId,
    },
  );

  @override
  Future<void> actOnCampaign(
    String campaignId,
    CampaignAction action, {
    double? amount,
    String? note,
  }) => _invoke(
    'update-ad-campaign',
    body: {
      'campaignId': campaignId,
      'action': action.asJson,
      'amount': ?amount,
      'note': ?note,
    },
  );

  /// Une date sans heure : une campagne se compte en jours entiers, et
  /// envoyer un instant ferait dépendre le devis du fuseau de l'appareil.
  static String _day(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Appelle une Edge Function et remonte son message d'erreur tel quel.
  ///
  /// Les fonctions de l'espace commerçant répondent en français et parlent
  /// du métier (« Vous gérez déjà un commerce ») : ces messages sont faits
  /// pour être montrés, pas remplacés par un « une erreur est survenue ».
  Future<Map<String, dynamic>> _invoke(
    String function, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    HttpMethod method = HttpMethod.post,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        function,
        method: method,
        body: body,
        queryParameters: query,
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
        // Un administrateur de plateforme n'est pas forcément commerçant :
        // sa réponse n'a pas de commerce, et son espace existe quand même.
        isAdmin: json['isAdmin'] == true,
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
      campaigns: parse('campaigns', AdCampaign.fromJson),
      metrics: parse('metrics', DailyMetric.fromJson),
      availability: {
        for (final entry
            in (json['availability'] as Map?)?.entries ?? const <dynamic, dynamic>{}.entries)
          entry.key.toString(): (entry.value as num?)?.toInt() ?? 0,
      },
      isAdmin: json['isAdmin'] == true,
    );
  }
}
