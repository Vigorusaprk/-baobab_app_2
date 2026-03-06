import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';


class UIBusiness {
  final Business business;

  UIBusiness(this.business);

  Color get categoryColor {
    switch (business.type) {
      case BusinessType.restaurant:
        return Colors.orange;
      case BusinessType.fastFood:
        return Colors.red;
      case BusinessType.shopping:
        return Colors.blue;
      case BusinessType.mall:
        return Colors.purple;
      case BusinessType.hotel:
        return Colors.teal;
      case BusinessType.carRental:
        return Colors.indigo;
      case BusinessType.detente:
        return Colors.green;
      case BusinessType.travelAgency:
        return Colors.indigoAccent;
      case BusinessType.spa:
        return Colors.purple; // ou une couleur de votre choix
      case BusinessType.cinema:
        return Colors.lightBlue; // ou votre couleur
      default:
        return Colors.grey;
    }
  }

  IconData get categoryIcon {
    switch (business.type) {
      case BusinessType.restaurant:
        return Icons.restaurant;
      case BusinessType.fastFood:
        return Icons.fastfood;
      case BusinessType.shopping:
        return Icons.shopping_bag;
      case BusinessType.mall:
        return Icons.store_mall_directory;
      case BusinessType.hotel:
        return Icons.hotel;
      case BusinessType.carRental:
        return Icons.directions_car;
      case BusinessType.detente:
        return Icons.spa;
      case BusinessType.travelAgency:
        return Icons.card_travel;
      case BusinessType.spa:
        return Icons.spa;
      case BusinessType.cinema:
        return Icons.movie;
      default:
        return Icons.business;
    }
  }

  bool get isOpen {
    // Logique d'horaires d'ouverture déplacée ici (logique UI)
    // ...
    return true;
  }
}