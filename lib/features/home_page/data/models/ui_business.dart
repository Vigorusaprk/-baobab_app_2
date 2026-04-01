import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';


class UIBusiness {
  final Business business;

  UIBusiness(this.business);

  Color get categoryColor {
    switch (business.type) {
      case BusinessType.restaurant:
        return AppColors.Restaurant;
      case BusinessType.fastFood:
        return AppColors.FastFood;
      case BusinessType.shopping:
        return AppColors.Shopping;
      case BusinessType.mall:
        return AppColors.Mall;
      case BusinessType.hotel:
        return AppColors.Hotel;
      case BusinessType.carRental:
        return AppColors.CarRental;
      case BusinessType.travelAgency:
        return AppColors.TravelAgency;
      case BusinessType.spa:
        return AppColors.Spa;
      case BusinessType.cinema:
        return AppColors.Cinema; // ou votre couleur
      case BusinessType.tourism:
        return AppColors.Tourisme; // à définir dans AppColors
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
      case BusinessType.travelAgency:
        return Icons.card_travel;
      case BusinessType.spa:
        return Icons.spa;
      case BusinessType.cinema:
        return Icons.movie;
      case BusinessType.tourism:
        return Icons.tour; // ou Icons.landscape, Icons.explore
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