import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/businesses_page.dart';

/// Contenu complet de la page d'accueil pour une catégorie donnée, tel que
/// renvoyé par l'Edge Function `get-home` en un seul appel.
///
/// Les trois listes sont déjà filtrées, triées et tronquées côté serveur :
/// l'UI se contente de les afficher. Quand l'utilisateur change de
/// catégorie, c'est ce bloc entier qui est re-demandé, ce qui garantit que
/// toutes les sections de la page restent cohérentes entre elles.
class HomeFeed {
  /// Établissements créés récemment (section "Nouveautés").
  final List<Business> newBusinesses;

  /// Meilleures notes de la catégorie (section "Populaires").
  final List<Business> popularBusinesses;

  /// Première page de la liste paginée (section "Découvrir").
  final BusinessesPage discover;

  const HomeFeed({
    required this.newBusinesses,
    required this.popularBusinesses,
    required this.discover,
  });
}
