import 'package:baobabe_0_2/core/themes/business_category_colors.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';

class UIBusiness {
  final Business business;

  UIBusiness(this.business);

  Color get categoryColor {
    switch (business.type) {
      case BusinessType.restaurant:
        return BusinessCategoryColors.restaurant;
      case BusinessType.fastFood:
        return BusinessCategoryColors.fastFood;
      case BusinessType.shopping:
        return BusinessCategoryColors.shopping;
      case BusinessType.mall:
        return BusinessCategoryColors.mall;
      case BusinessType.hotel:
        return BusinessCategoryColors.hotel;
      case BusinessType.carRental:
        return BusinessCategoryColors.carRental;
      case BusinessType.travelAgency:
        return BusinessCategoryColors.travelAgency;
      case BusinessType.spa:
        return BusinessCategoryColors.spa;
      case BusinessType.cinema:
        return BusinessCategoryColors.cinema;
      case BusinessType.tourism:
        return BusinessCategoryColors.tourism;
      default:
        return AppColors.textSecondary;
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
        return Icons.tour;
      default:
        return Icons.business;
    }
  }

  bool get isOpen => true;

  /// Un business est considéré comme "Nouveau" s'il a été créé
  /// il y a moins de 30 jours (1 mois).
  bool get isNew {
    final now = DateTime.now();
    final diff = now.difference(business.createdAt);
    return diff.inDays < 30;
  }
}
