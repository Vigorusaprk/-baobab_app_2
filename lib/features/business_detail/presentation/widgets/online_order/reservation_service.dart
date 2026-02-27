import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Modèle de données unifié pour les réservations
class Reservation {
  final String id;
  final String establishmentName;
  final String reservationType; // 'restaurant', 'hotel', OU 'car_rental'

  // Champs communs
  final String customerName;
  final String phoneNumber;
  final String? notes;
  final double totalAmount;
  final DateTime reservationDate;

  // Champs spécifiques restaurant
  final String? tableNumber;
  final String? floor;
  final DateTime? date;
  final TimeOfDay? time;
  final int? numberOfPeople;

  // Champs spécifiques hôtel
  final String? roomType;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int? numberOfRooms;
  final int? numberOfGuests;

  // NOUVEAUX CHAMPS: Location de véhicules
  final String? vehicleType;
  final DateTime? rentalStartDate;
  final DateTime? rentalEndDate;
  final int? rentalDays;
  final bool? withDriver;
  final bool? includeInsurance;
  final bool? needDelivery;

  Reservation({
    required this.id,
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

    // NOUVEAU: Location de véhicules
    this.vehicleType,
    this.rentalStartDate,
    this.rentalEndDate,
    this.rentalDays,
    this.withDriver,
    this.includeInsurance,
    this.needDelivery,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'establishmentName': establishmentName,
      'reservationType': reservationType,
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'notes': notes,
      'totalAmount': totalAmount,
      'reservationDate': reservationDate.toIso8601String(),

      // Restaurant
      'tableNumber': tableNumber,
      'floor': floor,
      'date': date?.toIso8601String(),
      'time': time != null ? '${time!.hour}:${time!.minute}' : null,
      'numberOfPeople': numberOfPeople,

      // Hôtel
      'roomType': roomType,
      'checkInDate': checkInDate?.toIso8601String(),
      'checkOutDate': checkOutDate?.toIso8601String(),
      'numberOfRooms': numberOfRooms,
      'numberOfGuests': numberOfGuests,

      // NOUVEAU: Location de véhicules
      'vehicleType': vehicleType,
      'rentalStartDate': rentalStartDate?.toIso8601String(),
      'rentalEndDate': rentalEndDate?.toIso8601String(),
      'rentalDays': rentalDays,
      'withDriver': withDriver,
      'includeInsurance': includeInsurance,
      'needDelivery': needDelivery,
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    TimeOfDay? parseTime(String? timeString) {
      if (timeString == null) return null;
      final parts = timeString.split(':');
      if (parts.length != 2) return null;
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return Reservation(
      id: map['id'],
      establishmentName: map['establishmentName'],
      reservationType: map['reservationType'],
      customerName: map['customerName'],
      phoneNumber: map['phoneNumber'],
      notes: map['notes'],
      totalAmount: map['totalAmount'],
      reservationDate: DateTime.parse(map['reservationDate']),

      // Restaurant
      tableNumber: map['tableNumber'],
      floor: map['floor'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      time: parseTime(map['time']),
      numberOfPeople: map['numberOfPeople'],

      // Hôtel
      roomType: map['roomType'],
      checkInDate: map['checkInDate'] != null ? DateTime.parse(map['checkInDate']) : null,
      checkOutDate: map['checkOutDate'] != null ? DateTime.parse(map['checkOutDate']) : null,
      numberOfRooms: map['numberOfRooms'],
      numberOfGuests: map['numberOfGuests'],

      // NOUVEAU: Location de véhicules
      vehicleType: map['vehicleType'],
      rentalStartDate: map['rentalStartDate'] != null ? DateTime.parse(map['rentalStartDate']) : null,
      rentalEndDate: map['rentalEndDate'] != null ? DateTime.parse(map['rentalEndDate']) : null,
      rentalDays: map['rentalDays'],
      withDriver: map['withDriver'],
      includeInsurance: map['includeInsurance'],
      needDelivery: map['needDelivery'],
    );
  }

  // Mise à jour des getters
  DateTime get displayDate {
    if (reservationType == 'hotel') {
      return checkInDate ?? reservationDate;
    } else if (reservationType == 'car_rental') {
      return rentalStartDate ?? reservationDate;
    } else {
      return date ?? reservationDate;
    }
  }

  String get typeDisplayName {
    switch (reservationType) {
      case 'hotel': return 'Hôtel';
      case 'car_rental': return 'Location de véhicule';
      default: return 'Restaurant';
    }
  }

  IconData get typeIcon {
    switch (reservationType) {
      case 'hotel': return Icons.hotel;
      case 'car_rental': return Icons.directions_car;
      default: return Icons.restaurant;
    }
  }

  Color get typeColor {
    switch (reservationType) {
      case 'hotel': return Colors.purple;
      case 'car_rental': return Colors.teal;
      default: return Colors.orange;
    }
  }
}

// Service de stockage des réservations unifié
class ReservationService {
  static const String _reservationsKey = 'user_reservations';

  static Future<void> saveReservation(Reservation reservation) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> reservations = prefs.getStringList(_reservationsKey) ?? [];

    reservations.add(json.encode(reservation.toMap()));
    await prefs.setStringList(_reservationsKey, reservations);
  }

  static Future<List<Reservation>> getReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> reservationsData = prefs.getStringList(_reservationsKey) ?? [];

    return reservationsData.map((data) {
      final map = json.decode(data);
      return Reservation.fromMap(Map<String, dynamic>.from(map));
    }).toList();
  }

  static Future<void> deleteReservation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> reservations = prefs.getStringList(_reservationsKey) ?? [];

    reservations.removeWhere((data) {
      final map = json.decode(data);
      return map['id'] == id;
    });

    await prefs.setStringList(_reservationsKey, reservations);
  }

  // Méthode pour récupérer uniquement les réservations d'hôtel
  static Future<List<Reservation>> getHotelReservations() async {
    final allReservations = await getReservations();
    return allReservations.where((r) => r.reservationType == 'hotel').toList();
  }

  // Méthode pour récupérer uniquement les réservations de restaurant
  static Future<List<Reservation>> getRestaurantReservations() async {
    final allReservations = await getReservations();
    return allReservations.where((r) => r.reservationType == 'restaurant').toList();
  }

  // Dans la classe ReservationService, ajouter :
  static Future<List<Reservation>> getCarRentalReservations() async {
    final allReservations = await getReservations();
    return allReservations.where((r) => r.reservationType == 'car_rental').toList();
  }
}