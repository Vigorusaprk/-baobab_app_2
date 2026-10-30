import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/businesses_page.dart';
import '../domain/entities/discover_entry.dart';
import '../domain/entities/discover_filters.dart';
import '../domain/entities/discover_offer.dart';
import '../domain/entities/discover_page.dart';
import 'models/business_model.dart';

/// Lit les offres de Découvrir par l'Edge Function existante.
class DiscoverApiService {
  DiscoverApiService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<DiscoverPage> page({
    String? categorySlug,
    int page = 1,
    DiscoverFilters filters = const DiscoverFilters(),
  }) async {
    final responses = await Future.wait([
      _section('businesses', page, categorySlug, filters.businessParameters),
      _section('discover', page, categorySlug, filters.offerParameters),
    ]);
    final businesses = _businesses(responses[0]);
    final offers = _offers(responses[1]);
    final items = <DiscoverEntry>[];
    final count = businesses.items.length > offers.items.length
        ? businesses.items.length
        : offers.items.length;
    for (var index = 0; index < count; index++) {
      if (index < businesses.items.length) {
        items.add(DiscoverEntry.business(businesses.items[index]));
      }
      if (index < offers.items.length) {
        items.add(offers.items[index]);
      }
    }
    return DiscoverPage(
      items: items,
      hasMore: businesses.hasMore || offers.hasMore,
    );
  }

  Future<Map<String, dynamic>> _section(
    String section,
    int page,
    String? category,
    Map<String, String> filters,
  ) async {
    final response = await _supabase.functions.invoke(
      'get-home',
      method: HttpMethod.get,
      queryParameters: {
        'section': section,
        'page': '$page',
        if (category != null && category != 'all') 'category': category,
        ...filters,
      },
    );
    final json = Map<String, dynamic>.from(response.data as Map);
    if (json['error'] != null) throw Exception(json['error'].toString());
    return json;
  }

  BusinessesPage _businesses(Map<String, dynamic> json) {
    final raw = json['businesses'];
    if (raw is! Map) return const BusinessesPage(items: [], hasMore: false);
    final result = Map<String, dynamic>.from(raw);
    return BusinessesPage(
      items: ((result['data'] as List?) ?? const [])
          .map((row) => BusinessModel.fromJson(Map<String, dynamic>.from(row as Map)).toEntity())
          .toList(growable: false),
      hasMore: result['hasMore'] == true,
    );
  }

  DiscoverPage _offers(Map<String, dynamic> json) {
    final raw = json['discoverOffers'];
    if (raw is! Map) return const DiscoverPage();
    final result = Map<String, dynamic>.from(raw);
    final rows = (result['data'] as List?) ?? const [];
    return DiscoverPage(
      items: rows
          .map((row) => DiscoverOffer.fromJson(Map<String, dynamic>.from(row as Map)))
          .map(DiscoverEntry.offer)
          .toList(growable: false),
      hasMore: result['hasMore'] == true,
    );
  }
}
