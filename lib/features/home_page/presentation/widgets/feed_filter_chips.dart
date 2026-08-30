import 'package:flutter/material.dart';
import '../bloc/feed_event.dart';

/// Rangée de chips "Tout / Notifications / Promotions".
/// Pure présentation : reçoit le filtre actif et remonte la sélection
/// via [onFilterSelected], le BLoC reste seul responsable de l'état.
class FeedFilterChips extends StatelessWidget {
  final FeedFilter activeFilter;
  final ValueChanged<FeedFilter> onFilterSelected;

  const FeedFilterChips({
    super.key,
    required this.activeFilter,
    required this.onFilterSelected,
  });

  static const _labels = {
    FeedFilter.all: 'Tout',
    FeedFilter.notifications: 'Notifications',
    FeedFilter.promotions: 'Promotions',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _labels.entries.map((entry) {
          final isSelected = entry.key == activeFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (_) => onFilterSelected(entry.key),
            ),
          );
        }).toList(),
      ),
    );
  }
}
