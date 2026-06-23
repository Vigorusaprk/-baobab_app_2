import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  // Convertit l'objet en Map JSON pour l'envoi vers l'API / PostgreSQL
  Map<String, dynamic> toJson() {
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

    return {
      'id': id,
      'business_id': businessId,
      'establishment_name': establishmentName,
      'type': reservationType,
      'customer_name': customerName,
      'phone_number': phoneNumber,
      'notes': notes,
      'total_amount': totalAmount,
      'reservation_date': reservationDate.toIso8601String(),
      'details': details,
    };
  }

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
        return AppColors.primary;
      case 'restaurant':
        return Colors.orange;
      case 'car_rental':
        return Colors.green;
      case 'travel':
        return Colors.purple;
      case 'spa':
        return Colors.teal;
      case 'cinema':
        return Colors.red;
      case 'toursime':
        return Colors.amber;
      default:
        return Colors.grey;
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
      date ?? checkInDate ?? rentalStartDate ?? appointmentDate ?? showtime ?? day ?? reservationDate;

  String get displayDateLabel {
    try {
      return DateFormat('dd/MM/yyyy').format(displayDate.toLocal());
    } catch (_) {
      return displayDate.toIso8601String();
    }
  }

  // Factory pour reconstruire l'objet depuis un JSON reçu de l'API
  factory Reservation.fromJson(Map<String, dynamic> json) {
    final details = json['details'] as Map<String, dynamic>? ?? {};
    final type = json['type']?.toString() ?? '';

    TimeOfDay? parsedTime;
    if (details['time'] != null) {
      final parts = details['time'].toString().split(':');
      if (parts.length == 2) {
        parsedTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    return Reservation(
      id: json['id']?.toString() ?? '',
      businessId: json['business_id']?.toString(),
      establishmentName: json['establishment_name']?.toString() ?? '',
      reservationType: type,
      customerName: json['customer_name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      notes: json['notes']?.toString(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      reservationDate: json['reservation_date'] != null
          ? DateTime.parse(json['reservation_date'].toString())
          : DateTime.now(),

      // Restaurant
      tableNumber: details['table_number']?.toString(),
      floor: details['floor']?.toString(),
      date: details['date'] != null ? DateTime.tryParse(details['date'].toString()) : null,
      time: parsedTime,
      numberOfPeople: details['number_of_people'] as int?,

      // Hôtel
      roomType: details['room_type']?.toString(),
      checkInDate: details['check_in_date'] != null ? DateTime.tryParse(details['check_in_date'].toString()) : null,
      checkOutDate: details['check_out_date'] != null ? DateTime.tryParse(details['check_out_date'].toString()) : null,
      numberOfRooms: details['number_of_rooms'] as int?,
      numberOfGuests: details['number_of_guests'] as int?,

      // Location
      vehicleType: details['vehicle_type']?.toString(),
      rentalStartDate: details['rental_start_date'] != null ? DateTime.tryParse(details['rental_start_date'].toString()) : null,
      rentalEndDate: details['rental_end_date'] != null ? DateTime.tryParse(details['rental_end_date'].toString()) : null,
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
      appointmentDate: details['appointment_date'] != null ? DateTime.tryParse(details['appointment_date'].toString()) : null,
      selectedTreatments: details['selected_treatments'] != null
          ? List<Map<String, dynamic>>.from(details['selected_treatments'])
          : null,

      // Cinéma
      movieTitle: details['movie_title']?.toString(),
      showtime: details['showtime'] != null ? DateTime.tryParse(details['showtime'].toString()) : null,
      ticketType: details['ticket_type']?.toString(),
      numberOfTickets: details['tickets_count'] as int?,
      seatNumbers: details['seat_numbers'] != null ? List<String>.from(details['seat_numbers']) : null,

      // Tourisme
      activitiName: details['activity_name']?.toString(),
      activiteType: details['activity_type']?.toString(),
      day: details['day'] != null ? DateTime.tryParse(details['day'].toString()) : null,
      selectedActivities: details['selected_activities'] != null ? List<String>.from(details['selected_activities']) : null,
    );
  }
}