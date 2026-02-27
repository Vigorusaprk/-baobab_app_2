// reservation_model.dart
import 'package:flutter/material.dart';

class Reservation {
  final String id;
  final String restaurantName;
  final String tableNumber;
  final String floor;
  final DateTime date;
  final TimeOfDay time;
  final int numberOfPeople;
  final String customerName;
  final String phoneNumber;
  final String? notes;
  final double totalAmount;
  final DateTime reservationDate;

  Reservation({
    required this.id,
    required this.restaurantName,
    required this.tableNumber,
    required this.floor,
    required this.date,
    required this.time,
    required this.numberOfPeople,
    required this.customerName,
    required this.phoneNumber,
    this.notes,
    required this.totalAmount,
    required this.reservationDate,
  });

  // Méthode pour convertir en Map (pour le stockage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantName': restaurantName,
      'tableNumber': tableNumber,
      'floor': floor,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'numberOfPeople': numberOfPeople,
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'notes': notes,
      'totalAmount': totalAmount,
      'reservationDate': reservationDate.toIso8601String(),
    };
  }

  // Méthode pour créer depuis un Map
  factory Reservation.fromMap(Map<String, dynamic> map) {
    final timeParts = map['time'].split(':');
    return Reservation(
      id: map['id'],
      restaurantName: map['restaurantName'],
      tableNumber: map['tableNumber'],
      floor: map['floor'],
      date: DateTime.parse(map['date']),
      time: TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1])),
      numberOfPeople: map['numberOfPeople'],
      customerName: map['customerName'],
      phoneNumber: map['phoneNumber'],
      notes: map['notes'],
      totalAmount: map['totalAmount'],
      reservationDate: DateTime.parse(map['reservationDate']),
    );
  }
}