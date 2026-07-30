import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';

/// Single filter chip used in the favorites/reservations filter row.
class ReservationFilterChip extends StatelessWidget {
  const ReservationFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.medium,
          vertical: AppDimens.small,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.white
              : AppColors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppDimens.radius20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: AppFonts.medium,
            fontFamily: AppFonts.primaryFontFamily,
            color: isSelected ? AppColors.white : AppColors.white,
          ),
        ),
      ),
    );
  }
}
