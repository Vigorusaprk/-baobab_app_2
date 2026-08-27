import 'package:baobabe_0_2/core/database/local_cache.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Accès au catalogue d'un commerçant : ses offres et ce qu'elles
/// permettent de faire.
///
/// Réutilise `get-business-detail`, qui renvoie déjà tout en un aller-retour
/// — inutile d'ajouter un appel réseau pour ces données.
class OfferApiService {
  final SupabaseClient _supabase;
  final LocalCache _cache;

  OfferApiService({SupabaseClient? supabase, LocalCache? cache})
    : _supabase = supabase ?? Supabase.instance.client,
      _cache = cache ?? LocalCache.instance;

  static String _cacheKey(String businessId) => 'catalogue_$businessId';

  Future<BusinessCatalogue> getCatalogue(String businessId) async {
    try {
      final response = await _supabase.functions.invoke(
        'get-business-detail',
        method: HttpMethod.get,
        queryParameters: {'id': businessId},
      );
      final json = response.data as Map<String, dynamic>;
      await _cache.saveJson(_cacheKey(businessId), {
        'offers': json['offers'],
        'capabilities': json['capabilities'],
      });
      return _parse(json);
    } catch (_) {
      final cached = await _cache.readJson(_cacheKey(businessId));
      if (cached is Map) {
        return _parse(Map<String, dynamic>.from(cached));
      }
      // Catalogue inconnu : on ne prétend pas qu'il est vide, on renvoie
      // simplement aucune capacité — l'écran n'affichera donc aucun bouton
      // plutôt qu'un bouton qui échouerait.
      return const BusinessCatalogue();
    }
  }

  BusinessCatalogue _parse(Map<String, dynamic> json) {
    final rawOffers = (json['offers'] as List?) ?? const [];
    final offers = rawOffers
        .map((e) => Offer.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final rawCapabilities = json['capabilities'];
    final capabilities = rawCapabilities is Map
        ? BusinessCapabilities.fromJson(
            Map<String, dynamic>.from(rawCapabilities),
          )
        // Réponse d'une ancienne version du serveur : on déduit les
        // capacités des offres reçues plutôt que de tout désactiver.
        : BusinessCapabilities(
            canOrder: offers.any((o) => o.isOrderable),
            canBook: offers.any((o) => o.isBookable),
            orderableCount: offers.where((o) => o.isOrderable).length,
            bookableCount: offers.where((o) => o.isBookable).length,
          );

    return BusinessCatalogue(offers: offers, capabilities: capabilities);
  }
}
