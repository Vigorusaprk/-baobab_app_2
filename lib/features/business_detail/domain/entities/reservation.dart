import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/business_category_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part 'reservation_json_mapper.dart';
part 'reservation_display_extensions.dart';

class Reservation {
  final String id;
  final String? businessId;
  final String establishmentName;
  final String reservationType;
  final String customerName;
  final String phoneNumber;
  final String? notes;
  final double totalAmount;
  final DateTime reservationDate;
  final String? userId;
  final DateTime? createdAt;

  // Restaurant
  final String? tableNumber;
  final String? floor;
  final DateTime? date;
  final TimeOfDay? time;
  final int? numberOfPeople;

  // Hôtel
  final String? roomType;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int? numberOfRooms;
  final int? numberOfGuests;

  // Location
  final String? vehicleType;
  final DateTime? rentalStartDate;
  final DateTime? rentalEndDate;
  final int? rentalDays;
  final bool? withDriver;
  final bool? includeInsurance;
  final bool? needDelivery;

  // Voyage / Travel
  final String? destination;
  final int? numberOfPassengers;
  final String? departureTime;

  // Spa
  final String? treatmentType;
  final int? durationMinutes;
  final String? therapistName;
  final DateTime? appointmentDate;
  final List<Map<String, dynamic>>? selectedTreatments;

  // Cinéma
  final String? movieTitle;
  final DateTime? showtime;
  final String? ticketType;
  final int? numberOfTickets;
  final List<String>? seatNumbers;

  // Tourisme
  final String? activitiName;
  final String? activiteType;
  final DateTime? day;
  final List<String>? selectedActivities;

  // Constructeur principal
  Reservation({
    required this.id,
    this.businessId,
    required this.establishmentName,
    required this.reservationType,
    required this.customerName,
    required this.phoneNumber,
    this.notes,
    required this.totalAmount,
    required this.reservationDate,
    this.userId,
    this.createdAt,

    // Restaurant
    this.tableNumber,
    this.floor,
    this.date,
    this.time,
    this.numberOfPeople,

    // Hôtel
    this.roomType,
    this.checkInDate,
    this.checkOutDate,
    this.numberOfRooms,
    this.numberOfGuests,

    // Location
    this.vehicleType,
    this.rentalStartDate,
    this.rentalEndDate,
    this.rentalDays,
    this.withDriver,
    this.includeInsurance,
    this.needDelivery,

    // Voyage
    this.destination,
    this.numberOfPassengers,
    this.departureTime,

    // Spa
    this.treatmentType,
    this.durationMinutes,
    this.therapistName,
    this.appointmentDate,
    this.selectedTreatments,

    // Cinéma
    this.movieTitle,
    this.showtime,
    this.ticketType,
    this.numberOfTickets,
    this.seatNumbers,

    // Tourisme
    this.activitiName,
    this.activiteType,
    this.day,
    this.selectedActivities,
  });

  // Factory pour reconstruire l'objet depuis un JSON reçu de l'API
  factory Reservation.fromJson(Map<String, dynamic> json) {
    final details = json['details'] as Map<String, dynamic>? ?? {};
    final type = json['type']?.toString() ?? '';

    // Récupération de la date de réservation principale
    final DateTime mainResDate = json['reservation_date'] != null
        ? DateTime.parse(json['reservation_date'].toString())
        : DateTime.now();

    TimeOfDay? parsedTime;
    if (details['time'] != null) {
      final parts = details['time'].toString().split(':');
      if (parts.length == 2) {
        parsedTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    } else {
      // Fallback sur l'heure de la date principale
      parsedTime = TimeOfDay(
        hour: mainResDate.hour,
        minute: mainResDate.minute,
      );
    }

    var establishmentName =
        (json['establishment_name']?.toString() ?? '').isNotEmpty
        ? json['establishment_name'].toString()
        : (json['business'] is Map
              ? json['business']['name']?.toString() ?? ''
              : '');

    if (establishmentName.isEmpty) {
      establishmentName =
          details['establishment_name']?.toString() ??
          details['establishmentName']?.toString() ??
          '';
    }

    return Reservation(
      id: json['id']?.toString() ?? '',
      businessId: json['business_id']?.toString(),
      establishmentName: establishmentName,
      reservationType: type,
      customerName:
          json['customer_name']?.toString() ??
          details['customer_name']?.toString() ??
          details['fullName']?.toString() ??
          '',
      phoneNumber:
          json['phone_number']?.toString() ??
          json['phone']?.toString() ??
          details['phone']?.toString() ??
          details['phone_number']?.toString() ??
          '',
      notes: json['notes']?.toString() ?? details['notes']?.toString(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      userId: json['user_id']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      reservationDate: mainResDate,

      // Restaurant
      tableNumber:
          details['table_number']?.toString() ??
          details['selectedTable']?.toString(),
      floor: details['floor']?.toString(),
      date: details['date'] != null
          ? DateTime.tryParse(details['date'].toString())
          : mainResDate,
      time: parsedTime,
      numberOfPeople:
          details['number_of_people'] as int? ??
          details['guests'] as int? ??
          details['numberOfPeople'] as int?,

      // Hôtel
      roomType: details['room_type']?.toString(),
      checkInDate: details['check_in_date'] != null
          ? DateTime.tryParse(details['check_in_date'].toString())
          : null,
      checkOutDate: details['check_out_date'] != null
          ? DateTime.tryParse(details['check_out_date'].toString())
          : null,
      numberOfRooms: details['number_of_rooms'] as int?,
      numberOfGuests: details['number_of_guests'] as int?,

      // Location
      vehicleType: details['vehicle_type']?.toString(),
      rentalStartDate: details['rental_start_date'] != null
          ? DateTime.tryParse(details['rental_start_date'].toString())
          : null,
      rentalEndDate: details['rental_end_date'] != null
          ? DateTime.tryParse(details['rental_end_date'].toString())
          : null,
      rentalDays: details['rental_days'] as int?,
      withDriver: details['with_driver'] as bool?,
      includeInsurance: details['include_insurance'] as bool?,
      needDelivery: details['need_delivery'] as bool?,

      // Voyage
      destination: details['destination']?.toString(),
      numberOfPassengers: details['number_of_passengers'] as int?,
      departureTime: details['departure_time']?.toString(),

      // Spa
      treatmentType: details['treatment_type']?.toString(),
      durationMinutes: details['duration_minutes'] as int?,
      therapistName: details['therapist_name']?.toString(),
      appointmentDate: details['appointment_date'] != null
          ? DateTime.tryParse(details['appointment_date'].toString())
          : null,
      selectedTreatments: details['selected_treatments'] != null
          ? List<Map<String, dynamic>>.from(details['selected_treatments'])
          : null,

      // Cinéma
      movieTitle: details['movie_title']?.toString(),
      showtime: details['showtime'] != null
          ? DateTime.tryParse(details['showtime'].toString())
          : null,
      ticketType: details['ticket_type']?.toString(),
      numberOfTickets: details['tickets_count'] as int?,
      seatNumbers: details['seat_numbers'] != null
          ? List<String>.from(details['seat_numbers'])
          : null,

      // Tourisme
      activitiName: details['activity_name']?.toString(),
      activiteType: details['activity_type']?.toString(),
      day: details['day'] != null
          ? DateTime.tryParse(details['day'].toString())
          : null,
      selectedActivities: details['selected_activities'] != null
          ? List<String>.from(details['selected_activities'])
          : null,
    );
  }
}
