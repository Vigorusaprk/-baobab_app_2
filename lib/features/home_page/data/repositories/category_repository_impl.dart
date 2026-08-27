import 'package:baobabe_0_2/core/database/local_cache.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/category_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/category_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Récupère les catégories depuis l'Edge Function `get-categories` et les
/// conserve en cache local.
///
/// Elles ne sont plus codées en dur dans l'application : en ajouter une en
/// base la rend visible sans publier de version. Le cache permet d'afficher
/// la bande de catégories immédiatement au lancement, avant même la
/// réponse du serveur, et de rester utilisable hors ligne.
class CategoryRepositoryImpl implements CategoryRepository {
  static const String _cacheKey = 'categories_v1';

  final SupabaseClient _supabase;
  final LocalCache _cache;

  CategoryRepositoryImpl({SupabaseClient? supabase, LocalCache? cache})
    : _supabase = supabase ?? Supabase.instance.client,
      _cache = cache ?? LocalCache.instance;

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await _supabase.functions.invoke(
        'get-categories',
        method: HttpMethod.get,
      );
      final json = response.data as Map<String, dynamic>;
      final data = (json['data'] as List?) ?? const [];
      final categories = data
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();

      if (categories.isNotEmpty) {
        await _cache.saveJson(
          _cacheKey,
          categories.map((c) => c.toJson()).toList(),
        );
        return categories;
      }
    } catch (_) {
      // Réseau indisponible ou réponse illisible : on se rabat sur le cache
      // puis sur la liste de repli. Une bande de catégories vide bloquerait
      // toute la navigation, ce qui serait pire que des libellés un peu
      // datés.
    }

    final cached = await _readCache();
    if (cached.isNotEmpty) return cached;
    return Category.fallback;
  }

  Future<List<Category>> _readCache() async {
    final raw = await _cache.readJson(_cacheKey);
    if (raw is! List) return const [];
    try {
      return raw
          .map((e) => Category.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<Category> getCategoryByType(BusinessType type) async {
    final categories = await getCategories();
    return categories.firstWhere(
      (c) => c.slug == type.name,
      orElse: () => Category.all,
    );
  }
}
