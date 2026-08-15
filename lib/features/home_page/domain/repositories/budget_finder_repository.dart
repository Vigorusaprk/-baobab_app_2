import 'package:baobabe_0_2/features/home_page/domain/entities/budget_filter.dart';
import '../entities/business_match.dart';

/// Contrat du repository. L'implémentation mockée sert de base ;
/// à remplacer par une requête Supabase sur la vue
/// `business_with_avg_price` sans rien changer dans le BLoC ni l'UI.
abstract class BudgetFinderRepository {
  Future<List<BusinessMatch>> findMatches(BudgetFilter budget);
}