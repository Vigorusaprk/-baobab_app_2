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
    if (reservationType == 'hotel') return checkInDate ?? reservationDate;
    if (reservationType == 'car_rental') return rentalStartDate ?? reservationDate;
    if (reservationType == 'spa') return appointmentDate ?? reservationDate;
    if (reservationType == 'cinema') return showtime ?? reservationDate;
    if (reservationType == 'toursime') return day ?? reservationDate;
    return date ?? reservationDate;
  }

  String get typeDisplayName {
    switch (reservationType) {
      case 'hotel': return 'Hôtel';
      case 'car_rental': return 'Location de véhicule';
      case 'travel': return 'Voyage en bus';
      case 'spa': return 'Spa & Bien-être';
      case 'cinema': return 'Cinéma';
      case 'toursime': return 'Tourisme';
      default: return 'Restaurant';
    }
  }

  IconData get typeIcon {
    switch (reservationType) {
      case 'hotel': return Icons.hotel;
      case 'car_rental': return Icons.directions_car;
      case 'travel': return Icons.directions_bus;
      case 'spa': return Icons.spa;
      case 'cinema': return Icons.movie;
      case 'toursime': return Icons.tour;
      default: return Icons.restaurant;
    }
  }

  Color get typeColor {
    switch (reservationType) {
      case 'hotel': return const Color(0xFF009688);
      case 'car_rental': return const Color(0xFF3F51B5);
      case 'travel': return const Color(0xFF9C27B0);
      case 'spa': return const Color(0xFFE91E63);
      case 'cinema': return const Color(0xFF673AB7);
      case 'toursime': return const Color(0xFF795548);
      default: return Colors.orange;
    }
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    final details = map['details'] as Map<String, dynamic>? ?? {};

    DateTime? _parseDate(String? str) => str != null ? DateTime.tryParse(str) : null;
    TimeOfDay? _parseTime(String? str) {
      if (str == null) return null;
      final parts = str.split(':');
      if (parts.length != 2) return null;
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    int? _toInt(dynamic v) => v != null ? int.tryParse(v.toString()) : null;
    double? _toDouble(dynamic v) => v != null ? double.tryParse(v.toString()) : null;
    bool? _toBool(dynamic v) => v != null ? v.toString().toLowerCase() == 'true' : null;

    return Reservation(
      id: map['id']?.toString() ?? '',
      establishmentName: map['establishment_name'] ?? '',
      reservationType: map['type'] ?? '',
      customerName: details['customer_name'] ?? map['customer_name'] ?? '',
      phoneNumber: details['phone'] ?? map['phone_number'] ?? '',
      notes: details['notes'] ?? map['notes'],
      totalAmount: _toDouble(map['total_amount']) ?? 0.0,
      reservationDate: _parseDate(map['reservation_date']) ?? DateTime.now(),
      tableNumber: details['table_number'],
      floor: details['floor'],
      date: _parseDate(details['date']),
      time: _parseTime(details['time']),
      numberOfPeople: _toInt(details['guests']),
      roomType: details['room_type'],
      checkInDate: _parseDate(details['check_in_date']),
      checkOutDate: _parseDate(details['check_out_date']),
      numberOfRooms: _toInt(details['number_of_rooms']),
      numberOfGuests: _toInt(details['number_of_guests']),
      vehicleType: details['vehicle_type'],
      rentalStartDate: _parseDate(details['rental_start_date']),
      rentalEndDate: _parseDate(details['rental_end_date']),
      rentalDays: _toInt(details['rental_days']),
      withDriver: _toBool(details['with_driver']),
      includeInsurance: _toBool(details['include_insurance']),
      needDelivery: _toBool(details['need_delivery']),
      destination: details['destination'],
      numberOfPassengers: _toInt(details['number_of_passengers']),
      departureTime: details['departure_time'],
      treatmentType: details['treatment_type'],
      durationMinutes: _toInt(details['duration_minutes']),
      therapistName: details['therapist_name'],
      appointmentDate: _parseDate(details['appointment_date']),
      selectedTreatments: details['selected_treatments'] != null ? List<Map<String, dynamic>>.from(details['selected_treatments']) : null,
      movieTitle: details['movie_title'],
      showtime: _parseDate(details['showtime']),
      ticketType: details['ticket_type'],
      numberOfTickets: _toInt(details['tickets_count']),
      seatNumbers: details['seat_numbers'],
      activitiName: details['activity_name'],
      activiteType: details['activity_type'],
      day: _parseDate(details['day']),
      selectedActivities: details['selected_activities'] != null ? List<Map<String, dynamic>>.from(details['selected_activities']) : null,
    );
  }
}