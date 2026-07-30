import 'package:flutter/material.dart';

class SpaReservationData {
  List<String> selectedTreatments = [];
  DateTime? appointmentDate;
  TimeOfDay? appointmentTime;
  String? selectedTherapist;
  String? fullName;
  String? phoneNumber;
  String? notes;

  double calculateTotal(List<dynamic> treatments) {
    double total = 0.0;
    for (final name in selectedTreatments) {
      Map<String, dynamic>? treatment;
      for (final t in treatments) {
        if (t is Map && t['name'] == name) {
          treatment = Map<String, dynamic>.from(t);
          break;
        }
      }
      if (treatment != null) {
        total += (treatment['price'] as num?)?.toDouble() ?? 0.0;
      }
    }
    return total;
  }

  List<Map<String, dynamic>> getSelectedTreatmentsWithPrices(
    List<dynamic> allTreatments,
  ) {
    List<Map<String, dynamic>> result = [];
    for (final name in selectedTreatments) {
      Map<String, dynamic>? treatment;
      for (final t in allTreatments) {
        if (t is Map && t['name'] == name) {
          treatment = Map<String, dynamic>.from(t);
          break;
        }
      }
      if (treatment != null) {
        result.add({
          'name': name,
          'price': treatment['price'],
          'duration': treatment['duration'],
        });
      }
    }
    return result;
  }
}
