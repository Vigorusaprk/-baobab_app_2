import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:flutter/material.dart';
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
  static Color getStatusColor(BuildContext context, Reservation reservation) {
    switch (reservation.status) {
      case 'pending':
        return OtherTheme.of(context).onWarningContainer;
      case 'cancelled':
        return Theme.of(context).colorScheme.error;
      case 'completed':
        return Theme.of(context).colorScheme.secondary;
    }
    return _dateColor(context, reservation.displayDate);
  }

  static String _dateText(DateTime? date) {
    if (date == null) return 'À venir';
    final diff = date.difference(DateTime.now());
    if (diff.isNegative) return 'Passée';
    if (diff.inDays == 0) return "Aujourd'hui";
    if (diff.inDays == 1) return 'Demain';
    return 'À venir';
  }

  static Color _dateColor(BuildContext context, DateTime? date) {
    if (date == null) return OtherTheme.of(context).onWarningContainer;
    final diff = date.difference(DateTime.now());
    if (diff.isNegative) return Theme.of(context).colorScheme.onSurfaceVariant;
    if (diff.inDays == 0) return OtherTheme.of(context).onSuccessContainer;
    if (diff.inDays <= 3) return OtherTheme.of(context).onWarningContainer;
    return Theme.of(context).colorScheme.primary;
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
