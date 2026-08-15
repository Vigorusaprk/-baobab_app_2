/// Type d'élément affiché dans le feed.
enum FeedItemType { notification, promotion }

/// Élément unifié du feed (notification OU publicité).
/// On garde une seule entité pour pouvoir mélanger les deux dans
/// une même liste triée par date, tout en filtrant via [type].
class FeedItem {
  final String id;
  final FeedItemType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  /// Image d'illustration (surtout utile pour les promos).
  final String? imageUrl;

  /// Libellé du bouton d'action (ex: "Voir l'offre", "Voir le business").
  final String? actionLabel;

  /// Route go_router à ouvrir au tap sur l'action.
  final String? actionRoute;

  const FeedItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.imageUrl,
    this.actionLabel,
    this.actionRoute,
  });

  FeedItem copyWith({bool? isRead}) {
    return FeedItem(
      id: id,
      type: type,
      title: title,
      message: message,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl,
      actionLabel: actionLabel,
      actionRoute: actionRoute,
    );
  }
}
