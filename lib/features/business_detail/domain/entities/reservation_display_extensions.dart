part of 'reservation.dart';

// Getters d'affichage pour l'entité Reservation (extraits de reservation.dart
// pour respecter la limite de taille de fichier ; même comportement).
extension ReservationDisplayExtensions on Reservation {
  // Compatibility getters used across the app
  String get type => reservationType;

  String get typeDisplayName {
    switch (reservationType) {
      case 'hotel':
        return 'Hôtel';
      case 'restaurant':
        return 'Restaurant';
      case 'car_rental':
        return 'Location de voiture';
      case 'travel':
        return 'Voyage';
      case 'spa':
        return 'Spa';
      case 'cinema':
        return 'Cinéma';
      case 'toursime':
        return 'Tourisme';
      default:
        return reservationType.isNotEmpty ? reservationType : 'Réservation';
    }
  }

  /// Voir [UIBusiness.categoryColor] : même palette, même raison.
  Color typeColor(BuildContext context) {
    final palette = OtherTheme.of(context).categories;
    switch (reservationType) {
      case 'hotel':
        return palette.hotel;
      case 'restaurant':
        return palette.restaurant;
      case 'car_rental':
        return palette.carRental;
      case 'travel':
        return palette.travelAgency;
      case 'spa':
        return palette.spa;
      case 'cinema':
        return palette.cinema;
      case 'toursime':
        return palette.tourism;
      default:
        return palette.fallback;
    }
  }

  IconData get typeIcon {
    switch (reservationType) {
      case 'hotel':
        return Icons.hotel;
      case 'restaurant':
        return Icons.restaurant;
      case 'car_rental':
        return Icons.directions_car;
      case 'travel':
        return Icons.flight_takeoff;
      case 'spa':
        return Icons.spa;
      case 'cinema':
        return Icons.movie;
      case 'toursime':
        return Icons.tour;
      default:
        return Icons.event;
    }
  }

  DateTime get displayDate =>
      date ??
      checkInDate ??
      rentalStartDate ??
      appointmentDate ??
      showtime ??
      day ??
      reservationDate;

  String get displayDateLabel {
    try {
      return DateFormat('dd/MM/yyyy').format(displayDate.toLocal());
    } catch (_) {
      return displayDate.toIso8601String();
    }
  }
}
