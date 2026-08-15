import '../entities/feed_item.dart';

/// Contrat du repository. L'implémentation actuelle est mockée
/// (voir data/mock_feed_repository.dart) ; à remplacer par une
/// implémentation Supabase quand la table sera prête, sans rien
/// changer dans le BLoC ni dans l'UI.
abstract class FeedRepository {
  Future<List<FeedItem>> getFeedItems();
  Future<void> markAsRead(String itemId);
}
