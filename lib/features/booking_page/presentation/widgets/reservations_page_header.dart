import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';

/// Title row (icon + "Mes Réservations" + total count badge) shown at the
/// top of the favorites/reservations page.
class ReservationsPageHeader extends StatelessWidget {
  const ReservationsPageHeader({super.key, required this.reservationCount});

  final int reservationCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 55, 20, 20),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/calendar-date-svgrepo-com (1).svg',
            height: 35,
            colorFilter: ColorFilter.mode(
              AppColors.accent700,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: AppDimens.PADDING_12),
          Text(
            'Mes Réservations',
            style: TextStyle(
              fontFamily: AppFonts.primaryFontFamily,
              fontSize: 24,
              fontWeight: AppFonts.bold,
              color: AppColors.accent700,
            ),
          ),
          const Spacer(),
          if (reservationCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.PADDING_12,
                vertical: AppDimens.PADDING_6,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent700,
              ),
              child: Text(
                '$reservationCount',
                style: TextStyle(
                  color: AppColors.accent50,
                  fontWeight: AppFonts.semiBold,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
