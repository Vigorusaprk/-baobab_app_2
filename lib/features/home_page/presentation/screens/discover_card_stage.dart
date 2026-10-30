import 'package:baobabe_0_2/features/home_page/domain/entities/discover_entry.dart';
import 'package:flutter/material.dart';
import 'discover_entry_card.dart';

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

  final DiscoverEntry? previous;
  final DiscoverEntry active;
  final DiscoverEntry? next;
  final Set<String> sponsoredIds;
  final Set<String> savedIds;
  final ValueChanged<String> onSave;
  final ValueChanged<String> onSkip;
  final Future<void> Function(DiscoverEntry) onOpen;
  final ValueChanged<DiscoverEntry> onSelect;

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

  Widget _card(DiscoverEntry entry, {
    required double left,
    required double width,
    required double top,
    required bool active,
  }) => AnimatedPositioned(
    key: ValueKey('deck-${entry.id}'),
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
          onTap: active ? null : () => onSelect(entry),
          child: ExcludeSemantics(
            excluding: !active,
            child: IgnorePointer(
              ignoring: !active,
          child: DiscoverEntryCard(
            key: ValueKey(entry.id),
            entry: entry,
            sponsored: sponsoredIds.contains(entry.businessId),
            saved: entry.offer != null && savedIds.contains(entry.offer!.offer.id),
            onSave: onSave,
            onSkip: onSkip,
            onOpen: onOpen,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
