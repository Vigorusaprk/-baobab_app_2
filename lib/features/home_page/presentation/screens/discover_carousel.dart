import 'package:baobabe_0_2/features/home_page/domain/entities/discover_offer.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';
import 'discover_card_stage.dart';
import 'offer_view_tracker.dart';

/// Fait défiler trois cartes en profondeur par glissement horizontal.
class DiscoverCarousel extends StatefulWidget {
  const DiscoverCarousel({super.key, required this.offers, required this.savedIds, required this.sponsoredBusinessIds, required this.onLoadMore, required this.onSave, required this.onSkip, required this.onOpenOffer});

  final List<DiscoverOffer> offers;
  final Set<String> savedIds;
  final Set<String> sponsoredBusinessIds;
  final VoidCallback onLoadMore;
  final ValueChanged<String> onSave;
  final ValueChanged<String> onSkip;
  final Future<void> Function(DiscoverOffer) onOpenOffer;

  @override
  State<DiscoverCarousel> createState() => _DiscoverCarouselState();
}

class _DiscoverCarouselState extends State<DiscoverCarousel> {
  int _index = 0;

  @override
  void didUpdateWidget(covariant DiscoverCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index >= widget.offers.length && widget.offers.isNotEmpty) {
      _index = widget.offers.length - 1;
    }
  }

  void _showOffer(int index) {
    if (index < 0 || index >= widget.offers.length || index == _index) return;
    setState(() => _index = index);
    if (index >= widget.offers.length - 2) widget.onLoadMore();
  }

  void _selectOffer(DiscoverOffer offer) {
    final index = widget.offers.indexWhere((item) => item.offer.id == offer.offer.id);
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
      label: 'Offre ${_index + 1} sur ${widget.offers.length}',
      onIncrease: () => _showOffer(_index + 1),
      onDecrease: () => _showOffer(_index - 1),
      child: GestureDetector(
        onHorizontalDragEnd: _handleSwipe,
        child: DiscoverCardStage(
          previous: _index > 0 ? widget.offers[_index - 1] : null,
          active: widget.offers[_index],
          next: _index + 1 < widget.offers.length ? widget.offers[_index + 1] : null,
          sponsoredIds: widget.sponsoredBusinessIds,
          savedIds: widget.savedIds,
          onSave: widget.onSave,
          onSkip: widget.onSkip,
          onOpen: widget.onOpenOffer,
          onSelect: _selectOffer,
        ),
      ),
    )),
    OfferViewTracker(
      offerId: widget.offers[_index].offer.id,
      businessId: widget.offers[_index].offer.businessId,
      visible: true,
    ),
    AppDimens.spacerSmall,
  ]);
}
