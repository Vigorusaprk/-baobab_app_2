import 'package:flutter/material.dart';
import 'reservation_filter_chip.dart';

/// Horizontal scrollable row of reservation type filter chips.
class ReservationFilterChipsRow extends StatelessWidget {
  const ReservationFilterChipsRow({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  static const List<String> filterLabels = [
    'Tous',
    'Hôtels',
    'Restaurants',
    'Locations',
    'Voyages',
    'Spas',
    'Cinémas',
    'Tourisme',
  ];

  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            for (var i = 0; i < filterLabels.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              ReservationFilterChip(
                label: filterLabels[i],
                isSelected: selectedFilter == filterLabels[i],
                onTap: () => onFilterSelected(filterLabels[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
