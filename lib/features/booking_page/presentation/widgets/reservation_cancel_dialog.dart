import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';

/// Shows the confirmation dialog for cancelling (deleting) a reservation.
/// [onConfirm] is called (and the dialog popped) when the user confirms.
void showCancelReservationDialog(
  BuildContext context,
  Reservation reservation,
  VoidCallback onConfirm,
) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_20),
      ),
      title: Text(
        'Annuler la réservation',
        style: TextStyle(
          fontFamily: AppFonts.primaryFontFamily,
          fontWeight: AppFonts.bold,
          color: AppColors.textPrimary,
        ),
      ),
      content: Text(
        'Êtes-vous sûr de vouloir annuler la réservation chez ${reservation.establishmentName} ?',
        style: TextStyle(
          fontSize: 14,
          fontFamily: AppFonts.primaryFontFamily,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
          child: const Text('Conserver'),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(dialogContext);
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Annuler'),
        ),
      ],
    ),
  );
}
