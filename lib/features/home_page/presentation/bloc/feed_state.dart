import 'package:equatable/equatable.dart';
import '../../domain/entities/feed_item.dart';
import 'feed_event.dart';

abstract class FeedState extends Equatable {
  const FeedState();
  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {
  const FeedInitial();
}

class FeedLoading extends FeedState {
  const FeedLoading();
}

class FeedLoaded extends FeedState {
  final List<FeedItem> allItems;
  final FeedFilter activeFilter;

  const FeedLoaded({required this.allItems, required this.activeFilter});

  /// Liste déjà filtrée selon la chip active, prête à afficher.
  List<FeedItem> get visibleItems {
    switch (activeFilter) {
      case FeedFilter.notifications:
        return allItems
            .where((item) => item.type == FeedItemType.notification)
            .toList();
      case FeedFilter.promotions:
        return allItems
            .where((item) => item.type == FeedItemType.promotion)
            .toList();
      case FeedFilter.all:
        return allItems;
    }
  }

  FeedLoaded copyWith({List<FeedItem>? allItems, FeedFilter? activeFilter}) {
    return FeedLoaded(
      allItems: allItems ?? this.allItems,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  @override
  List<Object?> get props => [allItems, activeFilter];
}

class FeedError extends FeedState {
  final String message;
  const FeedError(this.message);
  @override
  List<Object?> get props => [message];
}
