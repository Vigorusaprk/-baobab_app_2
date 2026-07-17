import 'package:flutter/material.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';

/// Shared formatting helpers used across the favorites/reservations UI.
class ReservationFormatUtils {
  const ReservationFormatUtils._();

  static String formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';

  static String formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  static String safeFormatDate(DateTime? date) =>
      date != null ? formatDate(date) : 'Non spécifiée';

  static String safeFormatTime(TimeOfDay? time) =>
      time != null ? formatTime(time) : 'Non spécifiée';

  static String getReservationSubtitle(Reservation reservation) {
    if (reservation.type == 'hotel') {
      final ci = reservation.checkInDate;
      final co = reservation.checkOutDate;
      if (ci != null && co != null) {
        return '${formatDate(ci)} - ${formatDate(co)}';
      }
      return 'Dates non spécifiées';
    } else if (reservation.type == 'car_rental') {
      final sd = reservation.rentalStartDate;
      final ed = reservation.rentalEndDate;
      if (sd != null && ed != null) {
        return '${formatDate(sd)} - ${formatDate(ed)}';
      }
      return 'Dates non spécifiées';
    } else if (reservation.type == 'travel') {
      return '${reservation.destination ?? "Destination inconnue"} • ${safeFormatDate(reservation.displayDate)}';
    } else if (reservation.type == 'spa') {
      return '${reservation.treatmentType ?? "Soin"} • ${safeFormatDate(reservation.appointmentDate)}';
    } else if (reservation.type == 'cinema') {
      return '${reservation.movieTitle ?? "Film"} • ${safeFormatDate(reservation.showtime)}';
    } else if (reservation.type == 'toursime') {
      return '${reservation.activitiName ?? "Activité"} • ${safeFormatDate(reservation.day)}';
    } else {
      return '${safeFormatDate(reservation.date)} • ${safeFormatTime(reservation.time)}';
    }
  }

  static Color getStatusColor(DateTime reservationDate) {
    final now = DateTime.now();
    if (reservationDate.isBefore(now)) return Colors.grey;
    if (reservationDate.difference(now).inDays <= 1) return AppColors.warning;
    return AppColors.success;
  }

  static String getStatusText(DateTime reservationDate) {
    final now = DateTime.now();
    if (reservationDate.isBefore(now)) return 'Passée';
    if (reservationDate.difference(now).inDays <= 1) return 'Bientôt';
    return 'À venir';
  }
}
