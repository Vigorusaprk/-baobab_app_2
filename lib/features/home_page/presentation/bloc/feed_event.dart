import 'package:equatable/equatable.dart';
import '../../domain/entities/feed_item.dart';

/// Filtre appliqué au feed via les chips.
enum FeedFilter { all, notifications, promotions }

abstract class FeedEvent extends Equatable {
  const FeedEvent();
  @override
  List<Object?> get props => [];
}

/// Charge (ou recharge) les éléments du feed.
class LoadFeedItems extends FeedEvent {
  const LoadFeedItems();
}

/// Change le filtre actif (chip sélectionnée).
class FeedFilterChanged extends FeedEvent {
  final FeedFilter filter;
  const FeedFilterChanged(this.filter);
  @override
  List<Object?> get props => [filter];
}

/// Marque un élément comme lu au tap.
class FeedItemTapped extends FeedEvent {
  final FeedItem item;
  const FeedItemTapped(this.item);
  @override
  List<Object?> get props => [item];
}
