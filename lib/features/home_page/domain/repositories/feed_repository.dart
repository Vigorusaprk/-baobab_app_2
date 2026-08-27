import '../entities/feed_item.dart';

/// Contrat du fil d'activité. Implémenté par `ActivityFeedRepository`, qui
/// le construit à partir des commandes et réservations réelles de
/// l'utilisateur.
abstract class FeedRepository {
  Future<List<FeedItem>> getFeedItems();
  Future<void> markAsRead(String itemId);
}
