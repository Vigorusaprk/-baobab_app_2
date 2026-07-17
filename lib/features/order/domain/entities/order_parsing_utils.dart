import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order_status.dart';

// Fonctions utilitaires partagées pour le parsing des commandes.

BusinessType? parseBusinessType(dynamic value) {
  if (value == null) return null;
  if (value is int) {
    if (value >= 0 && value < BusinessType.values.length) {
      return BusinessType.values[value];
    }
  }

  if (value is String) {
    final normalized = value.trim().toLowerCase();
    for (final type in BusinessType.values) {
      if (type.name.toLowerCase() == normalized) {
        return type;
      }
    }

    switch (normalized) {
      case 'car_rental':
      case 'car rental':
        return BusinessType.carRental;
      case 'travel_agency':
      case 'travel agency':
      case 'travel':
        return BusinessType.travelAgency;
      case 'fast_food':
      case 'fast food':
        return BusinessType.fastFood;
      case 'shopping':
        return BusinessType.shopping;
      case 'mall':
        return BusinessType.mall;
      case 'hotel':
        return BusinessType.hotel;
      case 'cinema':
        return BusinessType.cinema;
      case 'spa':
        return BusinessType.spa;
      case 'tourism':
      case 'toursime':
        return BusinessType.tourism;
      case 'restaurant':
        return BusinessType.restaurant;
      default:
        return BusinessType.other;
    }
  }

  return null;
}

OrderStatus parseOrderStatus(dynamic value) {
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    for (final status in OrderStatus.values) {
      if (status.name == normalized) {
        return status;
      }
    }
  }

  final index = toIntOrNull(value);
  if (index != null && index >= 0 && index < OrderStatus.values.length) {
    return OrderStatus.values[index];
  }

  return OrderStatus.pending;
}

double? toDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int? toIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
