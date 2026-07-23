import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';

class ReservationFormatUtils {
  static String getStatusText(DateTime? date) {
    if (date == null) return 'À venir';
    final now = DateTime.now();
    final diff = date.difference(now);
    if (diff.isNegative) return 'Passée';
    if (diff.inDays == 0) return 'Aujourd\'hui';
    if (diff.inDays == 1) return 'Demain';
    return 'À venir';
  }

  static Color getStatusColor(DateTime? date) {
    if (date == null) return AppColors.warning;
    final now = DateTime.now();
    final diff = date.difference(now);
    if (diff.isNegative) return Colors.grey;
    if (diff.inDays == 0) return AppColors.success;
    if (diff.inDays <= 3) return AppColors.warning;
    return AppColors.primary;
  }

  static String getReservationSubtitle(Reservation reservation) {
    if (reservation.date != null) {
      final months = [
        'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
        'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
      ];
      return '${reservation.date!.day} ${months[reservation.date!.month - 1]} ${reservation.date!.year}';
    }
    if (reservation.checkInDate != null) {
      return 'Arrivée: ${reservation.checkInDate!.day}/${reservation.checkInDate!.month}/${reservation.checkInDate!.year}';
    }
    if (reservation.rentalStartDate != null) {
      return 'Début: ${reservation.rentalStartDate!.day}/${reservation.rentalStartDate!.month}/${reservation.rentalStartDate!.year}';
    }
    return 'Date non spécifiée';
  }
}
