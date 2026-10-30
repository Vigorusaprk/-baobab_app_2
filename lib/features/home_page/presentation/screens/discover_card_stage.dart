import 'package:baobabe_0_2/features/home_page/domain/entities/discover_offer.dart';
import 'package:flutter/material.dart';
import 'offer_card.dart';

/// Place l'offre active entre ses voisines pour rendre le défilement lisible.
class DiscoverCardStage extends StatelessWidget {
  const DiscoverCardStage({
    super.key,
    required this.previous,
    required this.active,
    required this.next,
    required this.sponsoredIds,
    required this.savedIds,
    required this.onSave,
    required this.onSkip,
    required this.onOpen,
    required this.onSelect,
  });

  final DiscoverOffer? previous;
  final DiscoverOffer active;
  final DiscoverOffer? next;
  final Set<String> sponsoredIds;
  final Set<String> savedIds;
  final ValueChanged<String> onSave;
  final ValueChanged<String> onSkip;
  final Future<void> Function(DiscoverOffer) onOpen;
  final ValueChanged<DiscoverOffer> onSelect;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final width = bounds.maxWidth;
      final activeWidth = width * 0.82;
      final sideWidth = width * 0.70;
      final center = (width - activeWidth) / 2;
      final peek = width * 0.11;
      return Stack(clipBehavior: Clip.none, children: [
        if (previous != null)
          _card(previous!, left: center - sideWidth + peek,
              width: sideWidth, top: bounds.maxHeight * 0.06, active: false),
        if (next != null)
          _card(next!, left: center + activeWidth - peek,
              width: sideWidth, top: bounds.maxHeight * 0.06, active: false),
        _card(active, left: center, width: activeWidth, top: 0, active: true),
      ]);
    },
  );

  Widget _card(DiscoverOffer offer, {
    required double left,
    required double width,
    required double top,
    required bool active,
  }) => AnimatedPositioned(
    key: ValueKey('deck-${offer.offer.id}'),
    duration: const Duration(milliseconds: 420),
    curve: Curves.easeInOutCubic,
    left: left,
    top: top,
    bottom: top,
    width: width,
    child: AnimatedScale(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
      scale: active ? 1 : 0.88,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 350),
        opacity: active ? 1 : 0.62,
        child: GestureDetector(
          onTap: active ? null : () => onSelect(offer),
          child: ExcludeSemantics(
            excluding: !active,
            child: IgnorePointer(
              ignoring: !active,
              child: OfferCard(
                key: ValueKey(offer.offer.id),
                offer: offer,
                sponsored: sponsoredIds.contains(offer.offer.businessId),
                saved: savedIds.contains(offer.offer.id),
                onSave: () => onSave(offer.offer.id),
                onSkip: () => onSkip(offer.offer.id),
                onOpen: () => onOpen(offer),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
