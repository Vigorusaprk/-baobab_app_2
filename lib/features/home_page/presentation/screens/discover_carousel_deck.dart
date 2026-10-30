import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/discover_entry.dart';
import 'package:flutter/material.dart';
import 'discover_card_stage.dart';
import 'discover_view_tracker.dart';

/// Rend la carte active, ses voisines et sa mesure de visibilité.
class DiscoverCarouselDeck extends StatelessWidget {
  const DiscoverCarouselDeck({
    super.key,
    required this.items,
    required this.index,
    required this.savedIds,
    required this.sponsoredIds,
    required this.onSave,
    required this.onSkip,
    required this.onOpen,
    required this.onSelect,
    required this.onSwipe,
    required this.onMove,
  });

  final List<DiscoverEntry> items;
  final int index;
  final Set<String> savedIds;
  final Set<String> sponsoredIds;
  final ValueChanged<String> onSave;
  final ValueChanged<String> onSkip;
  final Future<void> Function(DiscoverEntry) onOpen;
  final ValueChanged<DiscoverEntry> onSelect;
  final ValueChanged<DragEndDetails> onSwipe;
  final ValueChanged<int> onMove;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: Semantics(
          label: 'Découverte ${index + 1} sur ${items.length}',
          onIncrease: () => onMove(index + 1),
          onDecrease: () => onMove(index - 1),
          child: GestureDetector(
            onHorizontalDragEnd: onSwipe,
            child: DiscoverCardStage(
              previous: index > 0 ? items[index - 1] : null,
              active: items[index],
              next: index + 1 < items.length ? items[index + 1] : null,
              sponsoredIds: sponsoredIds,
              savedIds: savedIds,
              onSave: onSave,
              onSkip: onSkip,
              onOpen: onOpen,
              onSelect: onSelect,
            ),
          ),
        ),
      ),
      DiscoverViewTracker(
        trackingId: items[index].id,
        offerId: items[index].offerId,
        businessId: items[index].businessId,
        visible: true,
      ),
      AppDimens.spacerSmall,
    ],
  );
}
