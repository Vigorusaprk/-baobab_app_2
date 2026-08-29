import 'dart:convert';
import 'package:baobabe_0_2/core/database/local_cache.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_model.dart';
import 'package:baobabe_0_2/features/home_page/data/data_sources/remote_datasource/business_remote_datasource.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/data/models/business_model.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/home_feed.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Toute la lecture/écriture passe par des Edge Functions (voir
/// supabase/functions dans le projet Supabase) plutôt que par des appels
/// `.from('table')` directs : ça laisse la place à de la pagination, de
/// l'agrégation multi-tables en un aller-retour, et une logique métier
/// centralisée côté serveur plutôt que dupliquée dans chaque client.
class BusinessRemoteDataSourceImpl implements BusinessRemoteDataSource {
  final SupabaseClient _supabase;
  final LocalCache _db = LocalCache.instance;
  final Connectivity _connectivity = Connectivity();

  BusinessRemoteDataSourceImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  Future<bool> get _isOnline async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult.any(
      (element) => element != ConnectivityResult.none,
    );
  }

  @override
  Future<List<BusinessModel>> getBusinesses() async {
    if (!await _isOnline) {
      final cached = await _db.getCache('all_businesses');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded
            .map((json) => BusinessModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    try {
      // `section=discover` : on veut ici une liste à plat, pas le bundle
      // complet de la page d'accueil (voir getHomeFeed).
      final response = await _supabase.functions.invoke(
        'get-home',
        method: HttpMethod.get,
        queryParameters: {'section': 'businesses', 'pageSize': '50'},
      );
      final data = _businessItems(response.data as Map<String, dynamic>);
      final businesses = data
          .map((json) => BusinessModel.fromJson(json as Map<String, dynamic>))
          .toList();

      await _db.saveCache(
        'all_businesses',
        jsonEncode(businesses.map((e) => e.toJson()).toList()),
      );
      return businesses;
    } catch (e) {
      final cached = await _db.getCache('all_businesses');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded
            .map((json) => BusinessModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception(
        'Erreur Edge Function (get-home) lors du chargement des businesses : $e',
      );
    }
  }

  /// Extrait la liste d'une réponse `get-home` en mode `section=businesses`,
  /// dont la charge utile est `{ businesses: { data: [...], hasMore } }`.
  List<dynamic> _businessItems(Map<String, dynamic> json) {
    final page = json['businesses'] as Map<String, dynamic>?;
    return (page?['data'] as List?) ?? const [];
  }

  @override
  Future<BusinessModel> getBusinessDetail(String businessId) async {
    if (!await _isOnline) {
      final cached = await _db.getCache('business_detail_$businessId');
      if (cached != null) {
        return BusinessModel.fromJson(jsonDecode(cached));
      }
      throw Exception("Hors ligne : ce commerce n'a pas encore été consulté.");
    }

    try {
      final response = await _supabase.functions.invoke(
        'get-business-detail',
        method: HttpMethod.get,
        queryParameters: {'id': businessId},
      );
      final json =
          (response.data as Map<String, dynamic>)['business']
              as Map<String, dynamic>;
      final business = BusinessModel.fromJson(json);

      await _db.saveCache(
        'business_detail_$businessId',
        jsonEncode(business.toJson()),
      );
      return business;
    } catch (e) {
      final cached = await _db.getCache('business_detail_$businessId');
      if (cached != null) {
        return BusinessModel.fromJson(jsonDecode(cached));
      }
      throw Exception(
        'Erreur Edge Function (business-detail) lors du chargement du détail business : $e',
      );
    }
  }

  @override
  Future<List<BusinessModel>> getBusinessesByCategory(String category) async {
    if (!await _isOnline) {
      final cached = await _db.getCache('businesses_cat_$category');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded
            .map((json) => BusinessModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    try {
      final response = await _supabase.functions.invoke(
        'get-home',
        method: HttpMethod.get,
        queryParameters: {
          'section': 'businesses',
          'category': category,
          'pageSize': '50',
        },
      );
      final data = _businessItems(response.data as Map<String, dynamic>);
      final businesses = data
          .map((json) => BusinessModel.fromJson(json as Map<String, dynamic>))
          .toList();

      await _db.saveCache(
        'businesses_cat_$category',
        jsonEncode(businesses.map((e) => e.toJson()).toList()),
      );
      return businesses;
    } catch (e) {
      final cached = await _db.getCache('businesses_cat_$category');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded
            .map((json) => BusinessModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception(
        'Erreur Edge Function (get-home) lors de la recherche par catégorie : $e',
      );
    }
  }

  @override
  Future<HomeFeed> getHomeFeed({String? category}) async {
    final cacheKey = 'home_feed_${category ?? 'all'}';

    if (!await _isOnline) {
      final cached = await _db.getCache(cacheKey);
      if (cached != null) return _decodeHomeFeed(jsonDecode(cached));
      return const HomeFeed();
    }

    try {
      final response = await _supabase.functions.invoke(
        'get-home',
        method: HttpMethod.get,
        queryParameters: {
          if (category != null && category.isNotEmpty) 'category': category,
        },
      );
      final json = response.data as Map<String, dynamic>;
      final feed = _decodeHomeFeed(json);
      await _db.saveCache(cacheKey, jsonEncode(json));
      return feed;
    } catch (e) {
      final cached = await _db.getCache(cacheKey);
      if (cached != null) return _decodeHomeFeed(jsonDecode(cached));
      throw Exception(
        "Erreur Edge Function (get-home) lors du chargement de la page d'accueil : $e",
      );
    }
  }

  @override
  Future<OffersPage> getOffersPage({
    required String section,
    required int page,
    String? category,
  }) async {
    // Pas de secours hors-ligne : la première page a déjà son cache, les
    // suivantes sont un enrichissement progressif.
    final response = await _supabase.functions.invoke(
      'get-home',
      method: HttpMethod.get,
      queryParameters: {
        'section': section,
        'page': '$page',
        if (category != null && category.isNotEmpty) 'category': category,
      },
    );
    final json = response.data as Map<String, dynamic>;
    final key = section == 'new' ? 'newOffers' : 'discoverOffers';
    return _decodeOffersPage(json[key]);
  }

  /// Convertit la charge utile `get-home` (réseau ou cache — même forme).
  HomeFeed _decodeHomeFeed(Map<String, dynamic> json) {
    return HomeFeed(
      newOffers: _decodeOffersPage(json['newOffers']),
      popularBusinesses: ((json['popularBusinesses'] as List?) ?? const [])
          .map(
            (e) => BusinessModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .map((m) => m.toEntity())
          .toList(),
      discoverOffers: _decodeOffersPage(json['discoverOffers']),
    );
  }

  OffersPage _decodeOffersPage(Object? raw) {
    if (raw is! Map) return const OffersPage();
    final map = Map<String, dynamic>.from(raw);
    return OffersPage(
      items: ((map['data'] as List?) ?? const [])
          .map((e) => Offer.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      hasMore: map['hasMore'] == true,
    );
  }

  @override
  Future<({List<BusinessModel> items, bool hasMore})> getBusinessesPage({
    required int page,
    String? category,
  }) async {
    // Pas de secours hors-ligne ici : la 1ère page (getHomeFeed) a déjà son
    // cache, "charger plus" est un enrichissement progressif, pas le
    // contenu principal de l'écran.
    //
    // `section=businesses` : cette pagination alimente l'écran « Voir tout »,
    // qui liste des commerçants — pas les offres de l'accueil.
    final response = await _supabase.functions.invoke(
      'get-home',
      method: HttpMethod.get,
      queryParameters: {
        'section': 'businesses',
        'page': '$page',
        if (category != null && category.isNotEmpty) 'category': category,
      },
    );
    final json = response.data as Map<String, dynamic>;
    final page_ = json['businesses'] as Map<String, dynamic>?;
    final items = _businessItems(json)
        .map((item) => BusinessModel.fromJson(item as Map<String, dynamic>))
        .toList();
    return (items: items, hasMore: page_?['hasMore'] as bool? ?? false);
  }

  @override
  Future<List<MenuItem>> getMenuByBusiness(String businessId) async {
    if (!await _isOnline) {
      final cached = await _db.getCache('menu_$businessId');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded
            .map((json) => MenuItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    try {
      final response = await _supabase.functions.invoke(
        'get-business-detail',
        method: HttpMethod.get,
        queryParameters: {'id': businessId},
      );
      final data = (response.data as Map<String, dynamic>)['menuItems'] as List;
      final menu = data
          .map((json) => MenuItem.fromJson(json as Map<String, dynamic>))
          .toList();

      await _db.saveCache(
        'menu_$businessId',
        jsonEncode(menu.map((e) => e.toJson()).toList()),
      );
      return menu;
    } catch (e) {
      final cached = await _db.getCache('menu_$businessId');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded
            .map((json) => MenuItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception(
        'Erreur Edge Function (business-detail) lors de la récupération du menu : $e',
      );
    }
  }

  @override
  Future<void> createReservation(Reservation reservation) async {
    try {
      await _supabase.functions.invoke(
        'create-reservation',
        method: HttpMethod.post,
        body: {
          'businessId': reservation.businessId,
          'type': reservation.type,
          'reservationDate': reservation.reservationDate.toIso8601String(),
          'totalAmount': reservation.totalAmount,
          'details': reservation.details,
          'establishmentName': reservation.establishmentName,
        },
      );
    } catch (e) {
      throw Exception(
        'Erreur Edge Function (create-reservation) lors de la création de la réservation : $e',
      );
    }
  }
}
