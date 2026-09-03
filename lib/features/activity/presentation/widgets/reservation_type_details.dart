import 'package:baobabe_0_2/features/booking_page/presentation/widgets/reservation_type_details_a.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';
import 'package:flutter/material.dart';

/// Choisit le bloc de détail qui correspond au type de réservation.
///
/// La sélection vivait au milieu de l'ancienne carte, sous la forme d'une
/// chaîne de `else if`. Elle est isolée ici pour que le reçu — et n'importe
/// quel écran à venir — n'ait qu'un widget à poser.
///
/// Les blocs eux-mêmes sont ceux d'avant, inchangés : ils portent la seule
/// information qui distingue une nuit d'hôtel d'une place de cinéma, et la
/// refonte n'avait aucune raison de la perdre.
class ReservationTypeDetails extends StatelessWidget {
  const ReservationTypeDetails({super.key, required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    return switch (reservation.type) {
      'hotel' => HotelReservationDetails(reservation),
      'restaurant' => RestaurantReservationDetails(reservation),
      'car_rental' => CarRentalReservationDetails(reservation),
      'travel' => TravelReservationDetails(reservation),
      'spa' => SpaReservationDetails(reservation),
      'cinema' => CinemaReservationDetails(reservation),
      // « toursime » : la faute est dans les données, pas ici. La corriger
      // côté serveur casserait les réservations déjà enregistrées.
      'toursime' || 'tourisme' => TourismReservationDetails(reservation),
      _ => const SizedBox.shrink(),
    };
  }
}
