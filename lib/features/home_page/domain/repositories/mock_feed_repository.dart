

import 'package:baobabe_0_2/features/home_page/domain/entities/feed_item.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/feed_repository.dart';

/// Implémentation temporaire en dur, le temps de brancher Supabase.
/// À remplacer par `SupabaseFeedRepository` plus tard : même contrat,
/// aucun changement ailleurs dans l'app.
class MockFeedRepository implements FeedRepository {
  final List<FeedItem> _items = [
    FeedItem(
      id: '1',
      type: FeedItemType.notification,
      title: 'Réservation confirmée',
      message: 'Votre réservation chez Spa Lumière est confirmée pour 15h.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
    ),
    FeedItem(
      id: '2',
      type: FeedItemType.promotion,
      title: '-20% chez Chez Fatou',
      message: 'Profitez de -20% sur tous les plats ce week-end.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      imageUrl: null,
      actionLabel: 'Voir le business',
      actionRoute: '/business/chez-fatou',
    ),
    FeedItem(
      id: '3',
      type: FeedItemType.notification,
      title: 'Nouvel avis',
      message: 'Quelqu\'un a répondu à votre avis sur Le Baobab Café.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  @override
  Future<List<FeedItem>> getFeedItems() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final sorted = [..._items]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  @override
  Future<void> markAsRead(String itemId) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(isRead: true);
    }
  }
}
