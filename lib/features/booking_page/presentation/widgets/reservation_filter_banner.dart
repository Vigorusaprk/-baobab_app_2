import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';

/// Small banner shown above the list when a filter other than "Tous" is
/// active, with a shortcut to clear it.
class ReservationFilterBanner extends StatelessWidget {
  const ReservationFilterBanner({
    super.key,
    required this.selectedFilter,
    required this.resultCount,
    required this.onShowAll,
  });

  final String selectedFilter;
  final int resultCount;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.filter_alt, size: 16, color: AppColors.secondaryLight),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            'Filtré par : $selectedFilter ($resultCount réservation${resultCount > 1 ? 's' : ''})',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondaryLight,
              fontFamily: AppFonts.primaryFontFamily,
            ),
          ),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: onShowAll,
          child: Text(
            'Tout afficher',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondaryLight,
              fontFamily: AppFonts.primaryFontFamily,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
