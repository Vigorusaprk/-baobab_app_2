import 'package:flutter/material.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';
import 'package:baobabe_0_2/features/booking_page/presentation/utils/reservation_format_utils.dart';
import 'reservation_detail_row.dart';

/// Type-specific detail blocks for hotel, restaurant, car rental and travel
/// reservations.

class HotelReservationDetails extends StatelessWidget {
  const HotelReservationDetails(this.reservation, {super.key});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReservationDetailRow(
            Icons.king_bed, reservation.roomType ?? 'Non spécifié'),
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
          'Du ${ReservationFormatUtils.safeFormatDate(reservation.checkInDate)} au ${ReservationFormatUtils.safeFormatDate(reservation.checkOutDate)}',
        ),
        ReservationDetailRow(
          Icons.people,
          '${reservation.numberOfGuests ?? 0} invité(s) • ${reservation.numberOfRooms ?? 0} chambre(s)',
        ),
        if (reservation.notes != null && reservation.notes!.isNotEmpty)
          ReservationDetailRow(Icons.note, reservation.notes!),
      ],
    );
  }
}

class RestaurantReservationDetails extends StatelessWidget {
  const RestaurantReservationDetails(this.reservation, {super.key});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
          '${ReservationFormatUtils.safeFormatDate(reservation.date)} à ${ReservationFormatUtils.safeFormatTime(reservation.time)}',
        ),
        ReservationDetailRow(
          Icons.people,
          '${reservation.numberOfPeople ?? 0} personne(s)',
        ),
        ReservationDetailRow(
          Icons.table_restaurant,
          'Table ${reservation.tableNumber ?? '?'}',
        ),
        if (reservation.notes != null && reservation.notes!.isNotEmpty)
          ReservationDetailRow(Icons.note, reservation.notes!),
      ],
    );
  }
}

class CarRentalReservationDetails extends StatelessWidget {
  const CarRentalReservationDetails(this.reservation, {super.key});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReservationDetailRow(
          Icons.directions_car,
          reservation.vehicleType ?? 'Non spécifié',
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
          'Du ${ReservationFormatUtils.safeFormatDate(reservation.rentalStartDate)} au ${ReservationFormatUtils.safeFormatDate(reservation.rentalEndDate)}',
        ),
        ReservationDetailRow(
            Icons.timer, '${reservation.rentalDays ?? 0} jour(s)'),
        if (reservation.withDriver == true)
          const ReservationDetailRow(Icons.person_pin, 'Avec chauffeur'),
        if (reservation.includeInsurance == false)
          const ReservationDetailRow(Icons.security, 'Assurance optionnelle'),
        if (reservation.needDelivery == true)
          const ReservationDetailRow(
              Icons.delivery_dining, 'Livraison incluse'),
        if (reservation.notes != null && reservation.notes!.isNotEmpty)
          ReservationDetailRow(Icons.note, reservation.notes!),
      ],
    );
  }
}

class TravelReservationDetails extends StatelessWidget {
  const TravelReservationDetails(this.reservation, {super.key});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReservationDetailRow(
          Icons.location_on,
          reservation.destination ?? 'Destination non spécifiée',
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
          'Départ : ${ReservationFormatUtils.safeFormatDate(reservation.displayDate)}',
        ),
        ReservationDetailRow(
          Icons.access_time,
          reservation.departureTime ?? 'Heure non spécifiée',
        ),
        ReservationDetailRow(
          Icons.people,
          '${reservation.numberOfPassengers ?? 1} passager(s)',
        ),
        if (reservation.notes != null && reservation.notes!.isNotEmpty)
          ReservationDetailRow(Icons.note, reservation.notes!),
      ],
    );
  }
}
