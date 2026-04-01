import 'package:flutter/material.dart';

class Reservation {
  final String id;
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

  // Voyage
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
  final String? seatNumbers;

  // Tourisme
  final String? activitiName;
  final String? activiteType;
  final DateTime? day;
  final List<Map<String, dynamic>>? selectedActivities;

  Reservation({
    required this.id,
    required this.establishmentName,
    required this.reservationType,
    required this.customerName,
    required this.phoneNumber,
    this.notes,
    required this.totalAmount,
    required this.reservationDate,
    this.tableNumber,
    this.floor,
    this.date,
    this.time,
    this.numberOfPeople,
    this.roomType,
    this.checkInDate,
    this.checkOutDate,
    this.numberOfRooms,
    this.numberOfGuests,
    this.vehicleType,
    this.rentalStartDate,
    this.rentalEndDate,
    this.rentalDays,
    this.withDriver,
    this.includeInsurance,
    this.needDelivery,
    this.destination,
    this.numberOfPassengers,
    this.departureTime,
    this.treatmentType,
    this.durationMinutes,
    this.therapistName,
    this.appointmentDate,
    this.selectedTreatments,
    this.movieTitle,
    this.showtime,
    this.ticketType,
    this.numberOfTickets,
    this.seatNumbers,
    this.activitiName,
    this.activiteType,
    this.day,
    this.selectedActivities,
  });

  DateTime get displayDate {
    if (reservationType == 'hotel') {
      return checkInDate ?? reservationDate;
    } else if (reservationType == 'car_rental') {
      return rentalStartDate ?? reservationDate;
    } else if (reservationType == 'spa') {
      return appointmentDate ?? reservationDate;
    } else if (reservationType == 'cinema') {
      return showtime ?? reservationDate;
    } else if (reservationType == 'toursime') {
      return day ?? reservationDate;
    } else {
      return date ?? reservationDate;
    }
  }

  String get typeDisplayName {
    switch (reservationType) {
      case 'hotel':
        return 'Hôtel';
      case 'car_rental':
        return 'Location de véhicule';
      case 'travel':
        return 'Voyage en bus';
      case 'spa':
        return 'Spa & Bien-être';
      case 'cinema':
        return 'Cinéma';
      case 'toursime':
        return 'Tourisme';
      default:
        return 'Restaurant';
    }
  }

  IconData get typeIcon {
    switch (reservationType) {
      case 'hotel':
        return Icons.hotel;
      case 'car_rental':
        return Icons.directions_car;
      case 'travel':
        return Icons.directions_bus;
      case 'spa':
        return Icons.spa;
      case 'cinema':
        return Icons.movie;
      case 'toursime':
        return Icons.tour;
      default:
        return Icons.restaurant;
    }
  }

  Color get typeColor {
    switch (reservationType) {
      case 'hotel':
        return const Color(0xFF009688);
      case 'car_rental':
        return const Color(0xFF3F51B5);
      case 'travel':
        return const Color(0xFF9C27B0);
      case 'spa':
        return const Color(0xFFE91E63);
      case 'cinema':
        return const Color(0xFF673AB7);
      case 'toursime':
        return const Color(0xFF795548);
      default:
        return Colors.orange;
    }
  }

  // ✅ Version corrigée avec gestion robuste des conversions
  factory Reservation.fromMap(Map<String, dynamic> map) {
    // Fonctions de conversion
    double? _toDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    int? _toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    bool? _toBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      if (value is int) return value == 1;
      return null;
    }

    TimeOfDay? _parseTime(String? timeString) {
      if (timeString == null) return null;
      final parts = timeString.split(':');
      if (parts.length != 2) return null;
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    DateTime? _parseDate(String? dateString) {
      if (dateString == null) return null;
      return DateTime.parse(dateString);
    }

    return Reservation(
      id: map['id']?.toString() ?? '',
      establishmentName: map['establishment_name'] ?? '',
      reservationType: map['type'] ?? '',
      customerName: map['customer_name'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      notes: map['notes'],
      totalAmount: _toDouble(map['total_amount']) ?? 0.0,
      reservationDate: _parseDate(map['reservation_date']) ?? DateTime.now(),
      tableNumber: map['table_number'],
      floor: map['floor'],
      date: _parseDate(map['date']),
      time: _parseTime(map['time']),
      numberOfPeople: _toInt(map['number_of_people']),
      roomType: map['room_type'],
      checkInDate: _parseDate(map['check_in_date']),
      checkOutDate: _parseDate(map['check_out_date']),
      numberOfRooms: _toInt(map['number_of_rooms']),
      numberOfGuests: _toInt(map['number_of_guests']),
      vehicleType: map['vehicle_type'],
      rentalStartDate: _parseDate(map['rental_start_date']),
      rentalEndDate: _parseDate(map['rental_end_date']),
      rentalDays: _toInt(map['rental_days']),
      withDriver: _toBool(map['with_driver']),
      includeInsurance: _toBool(map['include_insurance']),
      needDelivery: _toBool(map['need_delivery']),
      destination: map['destination'],
      numberOfPassengers: _toInt(map['number_of_passengers']),
      departureTime: map['departure_time'],
      treatmentType: map['treatment_type'],
      durationMinutes: _toInt(map['duration_minutes']),
      therapistName: map['therapist_name'],
      appointmentDate: _parseDate(map['appointment_date']),
      selectedTreatments: map['selected_treatments'] != null
          ? List<Map<String, dynamic>>.from(map['selected_treatments'])
          : null,
      movieTitle: map['movie_title'],
      showtime: _parseDate(map['showtime']),
      ticketType: map['ticket_type'],
      numberOfTickets: _toInt(map['number_of_tickets']),
      seatNumbers: map['seat_numbers'],
      activitiName: map['activity_name'],
      activiteType: map['activity_type'],
      day: _parseDate(map['day']),
      selectedActivities: map['selected_activities'] != null
          ? List<Map<String, dynamic>>.from(map['selected_activities'])
          : null,
    );
  }
}