import 'package:flutter/material.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';
import 'package:baobabe_0_2/features/booking_page/presentation/utils/reservation_format_utils.dart';
import 'reservation_detail_row.dart';

/// Type-specific detail blocks for spa, cinema and tourism reservations.

class SpaReservationDetails extends StatelessWidget {
  const SpaReservationDetails(this.reservation, {super.key});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReservationDetailRow(
          Icons.spa,
          reservation.treatmentType ?? 'Soin non spécifié',
        ),
        ReservationDetailRow(
          Icons.person,
          reservation.customerName.isNotEmpty
              ? reservation.customerName
              : 'Non renseigné',
        ),
        ReservationDetailRow(
          Icons.phone,
          reservation.phoneNumber.isNotEmpty
              ? reservation.phoneNumber
              : 'Non renseigné',
        ),
        ReservationDetailRow(
          Icons.calendar_today,
          ReservationFormatUtils.safeFormatDate(reservation.appointmentDate),
        ),
        ReservationDetailRow(
          Icons.access_time,
          reservation.appointmentDate != null
              ? '${reservation.appointmentDate!.hour.toString().padLeft(2, '0')}:${reservation.appointmentDate!.minute.toString().padLeft(2, '0')}'
              : 'Non spécifiée',
        ),
        if (reservation.therapistName != null)
          ReservationDetailRow(
            Icons.person_pin,
            'Thérapeute: ${reservation.therapistName}',
          ),
        if (reservation.selectedTreatments != null &&
            reservation.selectedTreatments!.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Soins réservés :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...reservation.selectedTreatments!.map(
            (treatment) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(treatment['name'] ?? 'Soin inconnu'),
                  Text('${treatment['price']} €'),
                ],
              ),
            ),
          ),
        ],
        if (reservation.notes != null && reservation.notes!.isNotEmpty)
          ReservationDetailRow(Icons.note, reservation.notes!),
      ],
    );
  }
}

class CinemaReservationDetails extends StatelessWidget {
  const CinemaReservationDetails(this.reservation, {super.key});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReservationDetailRow(
          Icons.movie,
          reservation.movieTitle ?? 'Film non spécifié',
        ),
        ReservationDetailRow(
          Icons.person,
          reservation.customerName.isNotEmpty
              ? reservation.customerName
              : 'Non renseigné',
        ),
        ReservationDetailRow(
          Icons.phone,
          reservation.phoneNumber.isNotEmpty
              ? reservation.phoneNumber
              : 'Non renseigné',
        ),
        ReservationDetailRow(
          Icons.calendar_today,
          ReservationFormatUtils.safeFormatDate(reservation.showtime),
        ),
        ReservationDetailRow(
          Icons.access_time,
          reservation.showtime != null
              ? '${reservation.showtime!.hour.toString().padLeft(2, '0')}:${reservation.showtime!.minute.toString().padLeft(2, '0')}'
              : 'Non spécifiée',
        ),
        ReservationDetailRow(
          Icons.confirmation_number,
          '${reservation.ticketType} x${reservation.numberOfTickets}',
        ),
        if (reservation.seatNumbers != null &&
            reservation.seatNumbers!.isNotEmpty)
          ReservationDetailRow(
            Icons.airline_seat_recline_normal,
            'Places : ${reservation.seatNumbers}',
          ),
        if (reservation.notes != null && reservation.notes!.isNotEmpty)
          ReservationDetailRow(Icons.note, reservation.notes!),
      ],
    );
  }
}

class TourismReservationDetails extends StatelessWidget {
  const TourismReservationDetails(this.reservation, {super.key});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReservationDetailRow(
          Icons.tour,
          reservation.activitiName ?? 'Activité non spécifiée',
        ),
        ReservationDetailRow(
          Icons.person,
          reservation.customerName.isNotEmpty
              ? reservation.customerName
              : 'Non renseigné',
        ),
        ReservationDetailRow(
          Icons.phone,
          reservation.phoneNumber.isNotEmpty
              ? reservation.phoneNumber
              : 'Non renseigné',
        ),
        ReservationDetailRow(
          Icons.calendar_today,
          ReservationFormatUtils.safeFormatDate(reservation.day),
        ),
        ReservationDetailRow(
          Icons.people,
          '${reservation.numberOfPassengers ?? 1} participant(s)',
        ),
        if (reservation.selectedActivities != null &&
            reservation.selectedActivities!.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Activités sélectionnées :',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...reservation.selectedActivities!.map(
            (activity) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      activity,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (reservation.notes != null && reservation.notes!.isNotEmpty)
          ReservationDetailRow(Icons.note, reservation.notes!),
      ],
    );
  }
}
