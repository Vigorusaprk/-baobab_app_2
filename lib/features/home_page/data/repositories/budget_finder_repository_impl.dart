import 'package:baobabe_0_2/features/home_page/data/models/business_model.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/budget_filter.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_match.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/budget_finder_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Recherche par budget sur les vraies offres publiées.
///
/// Remplace l'implémentation de démonstration, qui renvoyait trois
/// commerces inventés avec des prix codés en dur : la fonctionnalité était
/// accessible depuis la barre de recherche et donnait donc des résultats
/// entièrement faux.
///
/// Le prix retenu est le **prix d'entrée** du commerçant — sa moins chère
/// offre payante — et non une moyenne. C'est ce qui répond à la question
/// posée par l'utilisateur : « avec ce budget, où puis-je aller ? ». Une
/// moyenne écarterait un commerçant tout à fait accessible à cause d'une
/// seule offre haut de gamme.
class BudgetFinderRepositoryImpl implements BudgetFinderRepository {
  final SupabaseClient _supabase;

  BudgetFinderRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<List<BusinessMatch>> findMatches(BudgetFilter budget) async {
    final min = budget.minAmount ?? budget.tier?.minAmount ?? 0;
    final max = budget.maxAmount ?? budget.tier?.maxAmount;

    try {
      final response = await _supabase.functions.invoke(
        'get-businesses-budget',
        method: HttpMethod.get,
        queryParameters: {
          'min': '$min',
          if (max != null && max.isFinite) 'max': '$max',
        },
      );

      final json = response.data as Map<String, dynamic>;
      final rows = (json['data'] as List?) ?? const [];

      return rows.map((raw) {
        final row = Map<String, dynamic>.from(raw as Map);
        final business = BusinessModel.fromJson(
          Map<String, dynamic>.from(row['business'] as Map),
        ).toEntity();
        final price = (row['entryPrice'] as num?)?.toDouble();

        return BusinessMatch(
          business: business,
          averagePrice: price,
          // Le serveur a déjà appliqué la fourchette ; sans filtre actif,
          // tout commerçant dont on connaît le prix correspond.
          matchesBudget: budget.isActive
              ? (row['matchesBudget'] == true)
              : price != null,
        );
      }).toList();
    } catch (e) {
      throw Exception('Recherche par budget indisponible : $e');
    }
  }
}
