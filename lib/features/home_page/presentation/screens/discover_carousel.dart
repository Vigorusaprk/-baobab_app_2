import 'package:baobabe_0_2/features/home_page/domain/entities/discover_entry.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';
import 'discover_card_stage.dart';
import 'discover_view_tracker.dart';

/// Fait défiler trois cartes en profondeur par glissement horizontal.
class DiscoverCarousel extends StatefulWidget {
  const DiscoverCarousel({super.key, required this.items, required this.savedIds, required this.sponsoredBusinessIds, required this.onLoadMore, required this.onSave, required this.onSkip, required this.onOpenEntry});

  final List<DiscoverEntry> items;
  final Set<String> savedIds;
  final Set<String> sponsoredBusinessIds;
  final VoidCallback onLoadMore;
  final ValueChanged<String> onSave;
  final ValueChanged<String> onSkip;
  final Future<void> Function(DiscoverEntry) onOpenEntry;

  @override
  State<DiscoverCarousel> createState() => _DiscoverCarouselState();
}

class _DiscoverCarouselState extends State<DiscoverCarousel> {
  int _index = 0;

  @override
  void didUpdateWidget(covariant DiscoverCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index >= widget.items.length && widget.items.isNotEmpty) {
      _index = widget.items.length - 1;
    }
  }

  void _showOffer(int index) {
    if (index < 0 || index >= widget.items.length || index == _index) return;
    setState(() => _index = index);
    if (index >= widget.items.length - 2) widget.onLoadMore();
  }

  void _selectEntry(DiscoverEntry entry) {
    final index = widget.items.indexWhere((item) => item.id == entry.id);
    _showOffer(index);
  }

  void _handleSwipe(DragEndDetails details) {
    final speed = details.primaryVelocity ?? 0;
    if (speed < -200) _showOffer(_index + 1);
    if (speed > 200) _showOffer(_index - 1);
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    Expanded(child: Semantics(
      label: 'Découverte ${_index + 1} sur ${widget.items.length}',
      onIncrease: () => _showOffer(_index + 1),
      onDecrease: () => _showOffer(_index - 1),
      child: GestureDetector(
        onHorizontalDragEnd: _handleSwipe,
        child: DiscoverCardStage(
          previous: _index > 0 ? widget.items[_index - 1] : null,
          active: widget.items[_index],
          next: _index + 1 < widget.items.length ? widget.items[_index + 1] : null,
          sponsoredIds: widget.sponsoredBusinessIds,
          savedIds: widget.savedIds,
          onSave: widget.onSave,
          onSkip: widget.onSkip,
          onOpen: widget.onOpenEntry,
          onSelect: _selectEntry,
        ),
      ),
    )),
    DiscoverViewTracker(
      trackingId: widget.items[_index].id,
      offerId: widget.items[_index].offerId,
      businessId: widget.items[_index].businessId,
      visible: true,
    ),
    AppDimens.spacerSmall,
  ]);
}
