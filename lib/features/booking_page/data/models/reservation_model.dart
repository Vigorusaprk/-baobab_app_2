import 'package:baobabe_0_2/core/themes/business_category_colors.dart';
import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';

class Reservation {
  final String id;
  final String businessId;
  final String userId;
  final String type;
  final DateTime reservationDate;
  final double totalAmount;
  final Map<String, dynamic> details;
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.type,
    required this.reservationDate,
    required this.totalAmount,
    required this.details,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  // Correction : factory renommée fromJson pour correspondre à votre service
  factory Reservation.fromJson(Map<String, dynamic> map) {
    return Reservation(
      id: (map['id'] ?? '').toString(),
      businessId: map['business_id'] ?? '',
      userId: map['user_id'] ?? '',
      type: map['type'] ?? '',
      reservationDate: map['reservation_date'] != null
          ? DateTime.parse(map['reservation_date'])
          : DateTime.now(),
      totalAmount: (map['total_amount'] ?? 0.0).toDouble(),
      details: Map<String, dynamic>.from(map['details'] ?? {}),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  /// Méthode pour Supabase
  /// Si [isNew] est true, l'ID est ignoré pour laisser la BDD s'auto-incrémenter.
  Map<String, dynamic> toJson({bool isNew = false}) {
    final Map<String, dynamic> data = {
      'business_id': businessId,
      'user_id': userId,
      'type': type,
      'reservation_date': reservationDate.toIso8601String(),
      'total_amount': totalAmount,
      'details': {...details, 'establishment_name': establishmentName},
      'created_at': createdAt.toIso8601String(),
    };

    if (!isNew && id.isNotEmpty) {
      data['id'] = id;
    }

    return data;
  }

  // ========== Getters spécifiques (extraits de `details`) ==========

  String get establishmentName =>
      details['establishment_name'] ??
      details['establishmentName'] ??
      'Établissement inconnu';

  String get customerName =>
      details['customer_name'] ?? details['customerName'] ?? 'Non renseigné';

  String get phoneNumber =>
      details['phone'] ?? details['phone_number'] ?? 'Non renseigné';

  String? get tableNumber =>
      details['table_number']?.toString() ?? details['tableNumber']?.toString();

  DateTime? get date =>
      details['date'] != null ? DateTime.tryParse(details['date']) : null;

  TimeOfDay? get time =>
      details['time'] != null ? _parseTime(details['time']) : null;

  int? get numberOfPeople =>
      details['guests'] ?? details['number_of_people'] ?? details['people'];

  String? get roomType => details['room_type'] ?? details['roomType'];

  DateTime? get checkInDate => details['check_in'] != null
      ? DateTime.tryParse(details['check_in'])
      : null;

  DateTime? get checkOutDate => details['check_out'] != null
      ? DateTime.tryParse(details['check_out'])
      : null;

  int? get numberOfRooms => details['rooms'] ?? details['number_of_rooms'];

  int? get numberOfGuests => details['guests'] ?? details['number_of_guests'];

  String? get vehicleType => details['vehicle_type'] ?? details['vehicleType'];

  DateTime? get rentalStartDate => details['rental_start_date'] != null
      ? DateTime.tryParse(details['rental_start_date'])
      : null;

  DateTime? get rentalEndDate => details['rental_end_date'] != null
      ? DateTime.tryParse(details['rental_end_date'])
      : null;

  int? get rentalDays => details['rental_days'] ?? details['rentalDays'];

  bool get withDriver =>
      details['with_driver'] ?? details['withDriver'] ?? false;

  bool get includeInsurance =>
      details['include_insurance'] ?? details['includeInsurance'] ?? false;

  bool get needDelivery =>
      details['need_delivery'] ?? details['needDelivery'] ?? false;

  String? get destination => details['destination'];

  String? get departureTime =>
      details['departure_time'] ?? details['departureTime'];

  int? get numberOfPassengers =>
      details['number_of_passengers'] ??
      details['numberOfPassengers'] ??
      details['passengers'];

  String? get treatmentType =>
      details['treatment_type'] ??
      details['treatmentType'] ??
      details['selected_treatments']?.first?['name'];

  DateTime? get appointmentDate => details['appointment_date'] != null
      ? DateTime.tryParse(details['appointment_date'])
      : null;

  String? get therapistName =>
      details['therapist_name'] ?? details['therapistName'];

  List<Map<String, dynamic>>? get selectedTreatments =>
      (details['selected_treatments'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList();

  String? get movieTitle => details['movie_title'] ?? details['movieTitle'];

  DateTime? get showtime => details['showtime'] != null
      ? DateTime.tryParse(details['showtime'])
      : null;

  String? get ticketType =>
      details['ticket_type'] ?? details['ticketType'] ?? 'Standard';

  int? get numberOfTickets =>
      details['tickets_count'] ?? details['ticketsCount'] ?? 1;

  String? get seatNumbers => details['seat_numbers'] ?? details['seatNumbers'];

  String? get activitiName =>
      details['activity_name'] ?? details['activityName'];

  DateTime? get day =>
      details['day'] != null ? DateTime.tryParse(details['day']) : null;

  List<Map<String, dynamic>>? get selectedActivities =>
      (details['selected_activities'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList();

  String? get notes => details['notes'];

  // ========== Getters pour l'affichage ==========

  String get typeDisplayName {
    switch (type) {
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
        return type;
    }
  }

  Color get typeColor {
    switch (type) {
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
    switch (type) {
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

  DateTime get displayDate {
    return date ??
        checkInDate ??
        rentalStartDate ??
        appointmentDate ??
        showtime ??
        day ??
        reservationDate;
  }

  // ========== Helper ==========

  static TimeOfDay? _parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
