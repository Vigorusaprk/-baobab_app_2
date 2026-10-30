import 'package:baobabe_0_2/features/home_page/domain/entities/discover_offer.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';
import 'discover_page_dots.dart';
import 'offer_card.dart';
import 'offer_view_tracker.dart';

/// Carrousel d'offres qui laisse apparaître le bord de la carte suivante.
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
  late final PageController _pages = PageController(viewportFraction: 0.88);
  int _index = 0;

  @override
  void didUpdateWidget(covariant DiscoverCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index >= widget.offers.length && widget.offers.isNotEmpty) {
      _index = widget.offers.length - 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pages.hasClients) _pages.jumpToPage(_index);
      });
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _pageChanged(int index) {
    setState(() => _index = index);
    if (index >= widget.offers.length - 2) widget.onLoadMore();
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    Expanded(child: PageView.builder(
      controller: _pages,
      itemCount: widget.offers.length,
      onPageChanged: _pageChanged,
      itemBuilder: (context, index) {
        final item = widget.offers[index];
        final id = item.offer.id;
        final sponsored = widget.sponsoredBusinessIds.contains(item.offer.businessId);
        return Padding(padding: const EdgeInsets.symmetric(horizontal: AppDimens.small), child: Column(children: [
          Expanded(child: OfferCard(offer: item, sponsored: sponsored, saved: widget.savedIds.contains(id), onSave: () => widget.onSave(id), onSkip: () => widget.onSkip(id), onOpen: () => widget.onOpenOffer(item))),
          OfferViewTracker(offerId: id, businessId: item.offer.businessId, visible: index == _index),
        ]));
      },
    )),
    DiscoverPageDots(count: widget.offers.length, selected: _index),
  ]);
}
