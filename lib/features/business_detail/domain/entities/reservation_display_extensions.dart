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

  Color get typeColor {
    switch (reservationType) {
      case 'hotel':
        return BusinessCategoryColors.hotel;
      case 'restaurant':
        return BusinessCategoryColors.restaurant;
      case 'car_rental':
        return BusinessCategoryColors.carRental;
      case 'travel':
        return BusinessCategoryColors.travelAgency;
      case 'spa':
        return BusinessCategoryColors.spa;
      case 'cinema':
        return BusinessCategoryColors.cinema;
      case 'toursime':
        return BusinessCategoryColors.tourism;
      default:
        return AppColors.textSecondary;
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
