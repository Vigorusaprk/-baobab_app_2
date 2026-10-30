import 'package:baobabe_0_2/features/home_page/domain/entities/discover_entry.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/discover_feed_composer.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/home_feed.dart';
import 'package:flutter/material.dart';
import 'discover_carousel_deck.dart';

/// Fait défiler trois cartes en profondeur par glissement horizontal.
class DiscoverCarousel extends StatefulWidget {
  const DiscoverCarousel({
    super.key,
    required this.items,
    required this.savedIds,
    required this.skippedIds,
    required this.campaigns,
    required this.onLoadMore,
    required this.onSave,
    required this.onSkip,
    required this.onOpenEntry,
  });

  final List<DiscoverEntry> items;
  final Set<String> savedIds;
  final Set<String> skippedIds;
  final List<FeaturedBusiness> campaigns;
  final VoidCallback onLoadMore;
  final ValueChanged<String> onSave;
  final ValueChanged<String> onSkip;
  final Future<void> Function(DiscoverEntry) onOpenEntry;

  @override
  State<DiscoverCarousel> createState() => _DiscoverCarouselState();
}

class _DiscoverCarouselState extends State<DiscoverCarousel> {
  final _composer = DiscoverFeedComposer();
  int _index = 0;
  List<DiscoverEntry> _displayItems = [];

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  @override
  void didUpdateWidget(covariant DiscoverCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final activeId = _displayItems.isEmpty ? null : _displayItems[_index].id;
    _refreshItems();
    final newIndex = _displayItems.indexWhere((item) => item.id == activeId);
    _index = newIndex >= 0
        ? newIndex
        : _index.clamp(0, _displayItems.length - 1).toInt();
  }

  void _refreshItems() {
    _displayItems = _composer.compose(
      widget.items,
      widget.campaigns,
      skippedIds: widget.skippedIds,
    );
  }

  void _showOffer(int index) {
    if (index < 0 || index >= _displayItems.length || index == _index) return;
    setState(() => _index = index);
    if (index >= _displayItems.length - 2) widget.onLoadMore();
  }

  void _selectEntry(DiscoverEntry entry) {
    final index = _displayItems.indexWhere((item) => item.id == entry.id);
    _showOffer(index);
  }

  void _handleSwipe(DragEndDetails details) {
    final speed = details.primaryVelocity ?? 0;
    if (speed < -200) _showOffer(_index + 1);
    if (speed > 200) _showOffer(_index - 1);
  }

  @override
  Widget build(BuildContext context) => DiscoverCarouselDeck(
    items: _displayItems,
    index: _index,
    savedIds: widget.savedIds,
    sponsoredIds: widget.campaigns.map((item) => item.business.id).toSet(),
    onSave: widget.onSave,
    onSkip: widget.onSkip,
    onOpen: widget.onOpenEntry,
    onSelect: _selectEntry,
    onSwipe: _handleSwipe,
    onMove: _showOffer,
  );
}
