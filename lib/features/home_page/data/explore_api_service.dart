import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/data/models/business_model.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_search_filters.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/businesses_page.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/home_feed.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/offer_search_filters.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Les deux recherches d'Explorer : les commerces, et les offres.
///
/// Elle s'appuie sur `get-home?section=discover`, qui accepte le texte
/// cherché, la catégorie, une fourchette de prix, le mode de retrait, une
/// note minimale et un ordre de tri — **tous appliqués en base**. La
/// recherche précédente chargeait cinquante commerçants puis les filtrait en
/// Dart : au-delà de la première page, le résultat ne voulait plus rien dire.
class ExploreApiService {
  ExploreApiService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<OffersPage> search(OfferSearchFilters filters, {int page = 1}) async {
    final response = await _supabase.functions.invoke(
      'get-home',
      method: HttpMethod.get,
      queryParameters: {
        'section': 'discover',
        'page': '$page',
        ...filters.toQueryParameters(),
      },
    );

    final json = Map<String, dynamic>.from(response.data as Map);
    if (json['error'] != null) {
      throw Exception(json['error'].toString());
    }
    return _decode(json['discoverOffers']);
  }

  /// L'annuaire des commerces : `get-home?section=businesses`, avec les
  /// critères qui parlent d'un commerce — ouvert maintenant, on peut y
  /// commander, y réserver, y passer — tous appliqués en base.
  Future<BusinessesPage> searchBusinesses(
    BusinessSearchFilters filters, {
    int page = 1,
  }) async {
    final response = await _supabase.functions.invoke(
      'get-home',
      method: HttpMethod.get,
      queryParameters: {
        'section': 'businesses',
        'page': '$page',
        ...filters.toQueryParameters(),
      },
    );
    final json = Map<String, dynamic>.from(response.data as Map);
    if (json['error'] != null) {
      throw Exception(json['error'].toString());
    }
    final raw = json['businesses'];
    if (raw is! Map) return const BusinessesPage(items: [], hasMore: false);
    final map = Map<String, dynamic>.from(raw);
    return BusinessesPage(
      items: ((map['data'] as List?) ?? const [])
          .map(
            (e) => BusinessModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ).toEntity(),
          )
          .toList(),
      hasMore: map['hasMore'] == true,
    );
  }

  OffersPage _decode(Object? raw) {
    if (raw is! Map) return const OffersPage();
    final map = Map<String, dynamic>.from(raw);
    return OffersPage(
      items: ((map['data'] as List?) ?? const [])
          .map((e) => Offer.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      hasMore: map['hasMore'] == true,
    );
  }
}
