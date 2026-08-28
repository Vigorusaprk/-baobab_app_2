import 'package:baobabe_0_2/core/database/local_cache.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer_detail.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/review.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Fiche d'une offre, servie par `get-offer-detail`.
///
/// L'offre est une destination à part entière : on y arrive depuis
/// l'accueil ou la recherche sans être passé par la fiche du commerçant.
/// Tout ce qu'il faut pour décider tient donc dans un seul aller-retour.
class OfferDetailApiService {
  final SupabaseClient _supabase;
  final LocalCache _cache;

  OfferDetailApiService({SupabaseClient? supabase, LocalCache? cache})
    : _supabase = supabase ?? Supabase.instance.client,
      _cache = cache ?? LocalCache.instance;

  static String _cacheKey(String offerId) => 'offer_$offerId';

  Future<OfferDetail> getDetail(String offerId) async {
    try {
      final response = await _supabase.functions.invoke(
        'get-offer-detail',
        method: HttpMethod.get,
        queryParameters: {'id': offerId},
      );
      final json = Map<String, dynamic>.from(response.data as Map);
      if (json['error'] != null) {
        throw OfferDetailException(json['error'].toString());
      }
      await _cache.saveJson(_cacheKey(offerId), json);
      return _parse(json);
    } on OfferDetailException {
      rethrow;
    } catch (_) {
      // Le cache permet de rouvrir une offre déjà consultée hors ligne. La
      // jauge de places n'y est plus fiable, mais le serveur la revérifie
      // de toute façon au moment de valider.
      final cached = await _cache.readJson(_cacheKey(offerId));
      if (cached is Map) {
        return _parse(Map<String, dynamic>.from(cached));
      }
      throw const OfferDetailException(
        'Cette offre n\'a pas pu être chargée.',
      );
    }
  }

  OfferDetail _parse(Map<String, dynamic> json) {
    final rawOffer = json['offer'];
    if (rawOffer is! Map) {
      throw const OfferDetailException('Offre introuvable.');
    }

    List<T> parse<T>(String key, T Function(Map<String, dynamic>) build) {
      final list = (json[key] as List?) ?? const [];
      return list
          .map((e) => build(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    final merchant = json['business'];

    return OfferDetail(
      offer: Offer.fromJson(Map<String, dynamic>.from(rawOffer)),
      merchant: merchant is Map
          ? OfferMerchant.fromJson(Map<String, dynamic>.from(merchant))
          : null,
      reviews: parse('reviews', Review.fromJson),
      otherOffers: parse('otherOffers', Offer.fromJson),
      remainingCapacity: (json['remainingCapacity'] as num?)?.toInt(),
    );
  }
}

/// Erreur déjà rédigée pour l'utilisateur.
class OfferDetailException implements Exception {
  final String message;
  const OfferDetailException(this.message);

  @override
  String toString() => message;
}
