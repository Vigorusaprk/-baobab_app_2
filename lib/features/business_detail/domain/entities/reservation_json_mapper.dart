part of 'reservation.dart';

// Sérialisation JSON pour l'entité Reservation (extraite de reservation.dart
// pour respecter la limite de taille de fichier ; même comportement).
extension ReservationJsonMapper on Reservation {
  // Convertit l'objet en Map JSON pour l'envoi vers l'API / PostgreSQL
  Map<String, dynamic> toJson({bool isNew = false}) {
    Map<String, dynamic> details = {};

    switch (reservationType) {
      case 'restaurant':
        details['table_number'] = tableNumber;
        details['floor'] = floor;
        details['date'] = date?.toIso8601String();
        details['time'] = time != null ? '${time!.hour}:${time!.minute}' : null;
        details['number_of_people'] = numberOfPeople;
        break;

      case 'hotel':
        details['room_type'] = roomType;
        details['check_in_date'] = checkInDate?.toIso8601String();
        details['check_out_date'] = checkOutDate?.toIso8601String();
        details['number_of_rooms'] = numberOfRooms;
        details['number_of_guests'] = numberOfGuests;
        break;

      case 'location':
        details['vehicle_type'] = vehicleType;
        details['rental_start_date'] = rentalStartDate?.toIso8601String();
        details['rental_end_date'] = rentalEndDate?.toIso8601String();
        details['rental_days'] = rentalDays;
        details['with_driver'] = withDriver;
        details['include_insurance'] = includeInsurance;
        details['need_delivery'] = needDelivery;
        break;

      case 'spa':
        details['treatment_type'] = treatmentType;
        details['duration_minutes'] = durationMinutes;
        details['therapist_name'] = therapistName;
        details['appointment_date'] = appointmentDate?.toIso8601String();
        details['selected_treatments'] = selectedTreatments;
        break;

      case 'cinema':
        details['movie_title'] = movieTitle;
        details['showtime'] = showtime?.toIso8601String();
        details['ticket_type'] = ticketType;
        details['tickets_count'] = numberOfTickets;
        details['seat_numbers'] = seatNumbers;
        break;

      case 'travel':
        details['destination'] = destination;
        details['number_of_passengers'] = numberOfPassengers;
        details['departure_time'] = departureTime;
        break;

      case 'toursime':
        details['activity_name'] = activitiName;
        details['activity_type'] = activiteType;
        details['day'] = day?.toIso8601String();
        details['selected_activities'] = selectedActivities;
        break;
    }

    final payload = <String, dynamic>{
      'business_id': businessId,
      'type': reservationType,
      'total_amount': totalAmount,
      'reservation_date': reservationDate.toIso8601String(),
      'details': {
        ...details,
        'establishment_name': establishmentName,
        'customer_name': customerName,
        'phone_number': phoneNumber,
        'notes': notes,
      },
    };

    // Copie locale : la promotion de type ne s'applique pas à un membre.
    final owner = userId;
    if (owner != null && owner.isNotEmpty) {
      payload['user_id'] = owner;
    }

    if (!isNew && id.isNotEmpty) {
      payload['id'] = id;
    }

    final created = createdAt;
    if (!isNew && created != null) {
      payload['created_at'] = created.toIso8601String();
    }

    return payload;
  }
}
