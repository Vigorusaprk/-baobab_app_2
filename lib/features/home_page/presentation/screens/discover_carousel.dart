import 'package:baobabe_0_2/features/home_page/domain/entities/discover_offer.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';
import 'offer_card.dart';
import 'offer_view_tracker.dart';

/// Parcourt les offres par geste horizontal et fond la carte entre deux choix.
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

  void _handleSwipe(DragEndDetails details) {
    final speed = details.primaryVelocity ?? 0;
    if (speed < -200) _showOffer(_index + 1);
    if (speed > 200) _showOffer(_index - 1);
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    Expanded(child: _buildCurrentOffer()),
    AppDimens.spacerSmall,
  ]);

  Widget _buildCurrentOffer() {
    final item = widget.offers[_index];
    final id = item.offer.id;
    final sponsored = widget.sponsoredBusinessIds.contains(item.offer.businessId);
    return Semantics(
      label: 'Offre ${_index + 1} sur ${widget.offers.length}',
      onIncrease: () => _showOffer(_index + 1),
      onDecrease: () => _showOffer(_index - 1),
      child: GestureDetector(
        onHorizontalDragEnd: _handleSwipe,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.small),
          child: Column(children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                reverseDuration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: OfferCard(
                  key: ValueKey(id),
                  offer: item,
                  sponsored: sponsored,
                  saved: widget.savedIds.contains(id),
                  onSave: () => widget.onSave(id),
                  onSkip: () => widget.onSkip(id),
                  onOpen: () => widget.onOpenOffer(item),
                ),
              ),
            ),
            OfferViewTracker(
              offerId: id,
              businessId: item.offer.businessId,
              visible: true,
            ),
          ]),
        ),
      ),
    );
  }
}
