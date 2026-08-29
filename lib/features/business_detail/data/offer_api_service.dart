import 'package:baobabe_0_2/core/database/local_cache.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/data/models/business_model.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Ce que `get-business-detail` renvoie : le commerçant **et** son catalogue.
class BusinessPage {
  final Business business;
  final BusinessCatalogue catalogue;

  const BusinessPage({required this.business, required this.catalogue});
}

/// La fiche d'un commerçant, en **un seul** aller-retour.
///
/// L'écran et sa section catalogue interrogeaient chacun
/// `get-business-detail`, pour la même réponse : deux fois ~0,7 s et ~10 Ko à
/// chaque ouverture, sur un réseau que le produit sait irrégulier. Le fetch
/// vit désormais ici seul, et le bloc distribue.
class OfferApiService {
  final SupabaseClient _supabase;
  final LocalCache _cache;

  OfferApiService({SupabaseClient? supabase, LocalCache? cache})
    : _supabase = supabase ?? Supabase.instance.client,
      _cache = cache ?? LocalCache.instance;

  static String _cacheKey(String businessId) => 'business_page_$businessId';

  Future<BusinessPage> getPage(String businessId) async {
    try {
      final response = await _supabase.functions.invoke(
        'get-business-detail',
        method: HttpMethod.get,
        queryParameters: {'id': businessId},
      );
      final json = Map<String, dynamic>.from(response.data as Map);
      if (json['error'] != null) {
        throw Exception(json['error'].toString());
      }
      await _cache.saveJson(_cacheKey(businessId), {
        'business': json['business'],
        'offers': json['offers'],
        'capabilities': json['capabilities'],
      });
      return _parse(json);
    } catch (e) {
      final cached = await _cache.readJson(_cacheKey(businessId));
      if (cached is Map) {
        return _parse(Map<String, dynamic>.from(cached));
      }
      rethrow;
    }
  }

  BusinessPage _parse(Map<String, dynamic> json) {
    final rawBusiness = json['business'];
    if (rawBusiness is! Map) {
      throw Exception('Établissement introuvable');
    }

    final rawOffers = (json['offers'] as List?) ?? const [];
    final offers = rawOffers
        .map((e) => Offer.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final rawCapabilities = json['capabilities'];
    final capabilities = rawCapabilities is Map
        ? BusinessCapabilities.fromJson(
            Map<String, dynamic>.from(rawCapabilities),
          )
        // Réponse d'une ancienne version du serveur : on déduit les capacités
        // des offres reçues plutôt que de tout désactiver.
        : BusinessCapabilities(
            canOrder: offers.any((o) => o.isOrderable),
            canBook: offers.any((o) => o.isBookable),
            hasInStore: offers.any((o) => o.isInStoreOnly),
            orderableCount: offers.where((o) => o.isOrderable).length,
            bookableCount: offers.where((o) => o.isBookable).length,
            inStoreCount: offers.where((o) => o.isInStoreOnly).length,
          );

    return BusinessPage(
      business: BusinessModel.fromJson(
        Map<String, dynamic>.from(rawBusiness),
      ).toEntity(),
      catalogue: BusinessCatalogue(offers: offers, capabilities: capabilities),
    );
  }
}
