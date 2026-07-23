import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';

class HotelReservationDetails extends StatelessWidget {
  final Reservation reservation;
  const HotelReservationDetails(this.reservation, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row('Chambre', reservation.roomType ?? 'Non spécifiée', Icons.king_bed),
        _row('Arrivée', _fmt(reservation.checkInDate), Icons.calendar_today),
        _row('Départ', _fmt(reservation.checkOutDate), Icons.calendar_today),
        _row('Personnes', '${reservation.numberOfGuests ?? 1}', Icons.people),
      ],
    );
  }
  Widget _row(String label, String value, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 8),
      Expanded(flex: 2, child: Text(label, style: const TextStyle(color: Colors.grey))),
      Expanded(flex: 3, child: Text(value, textAlign: TextAlign.end)),
    ]),
  );
  String _fmt(DateTime? d) => d != null ? '${d.day}/${d.month}/${d.year}' : 'Non spécifiée';
}

class RestaurantReservationDetails extends StatelessWidget {
  final Reservation reservation;
  const RestaurantReservationDetails(this.reservation, {super.key});

  @override
  Widget build(BuildContext context) {
    final time = reservation.time;
    final timeStr = time != null
        ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
        : 'Non spécifiée';
    return Column(
      children: [
        _row('Table', reservation.tableNumber ?? 'Non spécifiée', Icons.table_restaurant),
        _row('Date', reservation.date != null ? '${reservation.date!.day}/${reservation.date!.month}/${reservation.date!.year}' : 'Non spécifiée', Icons.calendar_today),
        _row('Heure', timeStr, Icons.access_time),
        _row('Personnes', '${reservation.numberOfPeople ?? 0}', Icons.people),
      ],
    );
  }
  Widget _row(String label, String value, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 8),
      Expanded(flex: 2, child: Text(label, style: const TextStyle(color: Colors.grey))),
      Expanded(flex: 3, child: Text(value, textAlign: TextAlign.end)),
    ]),
  );
}

class CarRentalReservationDetails extends StatelessWidget {
  final Reservation reservation;
  const CarRentalReservationDetails(this.reservation, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row('Véhicule', reservation.vehicleType ?? 'Non spécifié', Icons.directions_car),
        _row('Début', _fmt(reservation.rentalStartDate), Icons.calendar_today),
        _row('Fin', _fmt(reservation.rentalEndDate), Icons.calendar_today),
      ],
    );
  }
  Widget _row(String label, String value, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 8),
      Expanded(flex: 2, child: Text(label, style: const TextStyle(color: Colors.grey))),
      Expanded(flex: 3, child: Text(value, textAlign: TextAlign.end)),
    ]),
  );
  String _fmt(DateTime? d) => d != null ? '${d.day}/${d.month}/${d.year}' : 'Non spécifiée';
}

class TravelReservationDetails extends StatelessWidget {
  final Reservation reservation;
  const TravelReservationDetails(this.reservation, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row('Destination', reservation.destination ?? 'Non spécifiée', Icons.location_on),
        _row('Passagers', '${reservation.numberOfPassengers ?? 1}', Icons.people),
      ],
    );
  }
  Widget _row(String label, String value, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 8),
      Expanded(flex: 2, child: Text(label, style: const TextStyle(color: Colors.grey))),
      Expanded(flex: 3, child: Text(value, textAlign: TextAlign.end)),
    ]),
  );
}

class SpaReservationDetails extends StatelessWidget {
  final Reservation reservation;
  const SpaReservationDetails(this.reservation, {super.key});

  @override
  Widget build(BuildContext context) {
    final date = reservation.appointmentDate;
    return Column(
      children: [
        _row('Soin', reservation.treatmentType ?? 'Non spécifié', Icons.spa),
        _row('Date', date != null ? '${date.day}/${date.month}/${date.year}' : 'Non spécifiée', Icons.calendar_today),
        _row('Thérapeute', reservation.therapistName ?? 'Non spécifié', Icons.person_pin),
      ],
    );
  }
  Widget _row(String label, String value, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 8),
      Expanded(flex: 2, child: Text(label, style: const TextStyle(color: Colors.grey))),
      Expanded(flex: 3, child: Text(value, textAlign: TextAlign.end)),
    ]),
  );
}

class CinemaReservationDetails extends StatelessWidget {
  final Reservation reservation;
  const CinemaReservationDetails(this.reservation, {super.key});

  @override
  Widget build(BuildContext context) {
    final date = reservation.showtime;
    return Column(
      children: [
        _row('Film', reservation.movieTitle ?? 'Non spécifié', Icons.movie),
        _row('Séance', date != null ? '${date.day}/${date.month}/${date.year}' : 'Non spécifiée', Icons.calendar_today),
        _row('Places', '${reservation.numberOfTickets ?? 0}', Icons.confirmation_number),
      ],
    );
  }
  Widget _row(String label, String value, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 8),
      Expanded(flex: 2, child: Text(label, style: const TextStyle(color: Colors.grey))),
      Expanded(flex: 3, child: Text(value, textAlign: TextAlign.end)),
    ]),
  );
}

class TourismReservationDetails extends StatelessWidget {
  final Reservation reservation;
  const TourismReservationDetails(this.reservation, {super.key});

  @override
  Widget build(BuildContext context) {
    final date = reservation.day;
    return Column(
      children: [
        _row('Activité', reservation.activitiName ?? 'Non spécifiée', Icons.tour),
        _row('Date', date != null ? '${date.day}/${date.month}/${date.year}' : 'Non spécifiée', Icons.calendar_today),
        _row('Participants', '${reservation.numberOfPassengers ?? 1}', Icons.people),
      ],
    );
  }
  Widget _row(String label, String value, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 8),
      Expanded(flex: 2, child: Text(label, style: const TextStyle(color: Colors.grey))),
      Expanded(flex: 3, child: Text(value, textAlign: TextAlign.end)),
    ]),
  );
}
