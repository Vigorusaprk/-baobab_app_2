import 'package:baobabe_0_2/features/home_page/domain/entities/budget_filter.dart';
import '../entities/business_match.dart';

/// Contrat de la recherche par budget. Implémenté par
/// `BudgetFinderRepositoryImpl`, qui interroge les prix réels des offres.
abstract class BudgetFinderRepository {
  Future<List<BusinessMatch>> findMatches(BudgetFilter budget);
}
