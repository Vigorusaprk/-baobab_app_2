import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';

class ReservationFormatUtils {
  /// Ce que la pastille annonce.
  ///
  /// Tant que le commerçant n'a pas répondu, c'est sa décision qui compte —
  /// dire « Demain » d'une réservation qu'il peut encore refuser laisserait
  /// croire qu'elle est acquise. Une fois confirmée, l'échéance redevient
  /// l'information utile.
  static String getStatusText(Reservation reservation) {
    switch (reservation.status) {
      case 'pending':
        return 'À confirmer';
      case 'cancelled':
        return 'Refusée';
      case 'completed':
        return 'Honorée';
    }
    return _dateText(reservation.displayDate);
  }

  /// La pastille est un aplat surmonté de blanc : la couleur doit donc être
  /// une valeur `...Content`, assez profonde pour porter du texte blanc.
  static Color getStatusColor(Reservation reservation) {
    switch (reservation.status) {
      case 'pending':
        return AppColors.warningContent;
      case 'cancelled':
        return AppColors.errorContent;
      case 'completed':
        return AppColors.secondary;
    }
    return _dateColor(reservation.displayDate);
  }

  static String _dateText(DateTime? date) {
    if (date == null) return 'À venir';
    final diff = date.difference(DateTime.now());
    if (diff.isNegative) return 'Passée';
    if (diff.inDays == 0) return "Aujourd'hui";
    if (diff.inDays == 1) return 'Demain';
    return 'À venir';
  }

  static Color _dateColor(DateTime? date) {
    if (date == null) return AppColors.warningContent;
    final diff = date.difference(DateTime.now());
    if (diff.isNegative) return AppColors.textSecondary;
    if (diff.inDays == 0) return AppColors.successContent;
    if (diff.inDays <= 3) return AppColors.warningContent;
    return AppColors.primary;
  }

  static String getReservationSubtitle(Reservation reservation) {
    if (reservation.date != null) {
      final months = [
        'Jan',
        'Fév',
        'Mar',
        'Avr',
        'Mai',
        'Juin',
        'Juil',
        'Aoû',
        'Sep',
        'Oct',
        'Nov',
        'Déc',
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
