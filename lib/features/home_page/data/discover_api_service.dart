import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/discover_offer.dart';
import '../domain/entities/discover_page.dart';

/// Lit les offres de Découvrir par l'Edge Function existante.
class DiscoverApiService {
  DiscoverApiService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<DiscoverPage> page({String? categorySlug, int page = 1}) async {
    final response = await _supabase.functions.invoke(
      'get-home',
      method: HttpMethod.get,
      queryParameters: {
        'section': 'discover',
        'page': '$page',
        if (categorySlug != null && categorySlug != 'all')
          'category': categorySlug,
      },
    );
    final json = Map<String, dynamic>.from(response.data as Map);
    if (json['error'] != null) throw Exception(json['error'].toString());
    final raw = json['discoverOffers'];
    if (raw is! Map) return const DiscoverPage();
    final result = Map<String, dynamic>.from(raw);
    final rows = (result['data'] as List?) ?? const [];
    return DiscoverPage(
      items: rows
          .map((row) => DiscoverOffer.fromJson(Map<String, dynamic>.from(row as Map)))
          .toList(growable: false),
      hasMore: result['hasMore'] == true,
    );
  }
}
