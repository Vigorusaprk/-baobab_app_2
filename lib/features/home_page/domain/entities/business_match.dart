import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';

/// Résultat enrichi pour l'affichage en liste.
///
/// [averagePrice] ne vient PAS de l'entité `Business` (qui n'a pas ce champ)
/// mais de la vue Supabase `business_with_avg_price`, calculée par jointure
/// sur `menu_items`/`rooms`. Porté séparément ici plutôt que d'être ajouté
/// à `Business`, pour ne pas modifier une entité partagée par tout le reste
/// de l'app.
class BusinessMatch {
  final Business business;
  final double? averagePrice;
  final bool matchesBudget;

  const BusinessMatch({
    required this.business,
    required this.averagePrice,
    required this.matchesBudget,
  });
}
