import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/business_category_colors.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/category_entity.dart';
import 'package:flutter/material.dart';

class UICategory {
  final Category category;
  UICategory(this.category);

  IconData get icon {
    switch (category.type) {
      // Correction ici
      case BusinessType.restaurant:
        return Icons.restaurant;
      case BusinessType.fastFood:
        return Icons.fastfood;
      case BusinessType.shopping:
        return Icons.shopping_bag;
      case BusinessType.hotel:
        return Icons.hotel;
      case BusinessType.mall:
        return Icons.store_mall_directory;
      case BusinessType.carRental:
        return Icons.directions_car;
      case BusinessType.travelAgency:
        return Icons.card_travel;
      case BusinessType.spa:
        return Icons.spa;
      case BusinessType.cinema:
        return Icons.movie;
      case BusinessType.tourism:
        return Icons.tour_rounded;
      default:
        return Icons.explore;
    }
  }

  Color get color {
    switch (category.type) {
      // Correction ici
      case BusinessType.restaurant:
        return BusinessCategoryColors.restaurant;
      case BusinessType.fastFood:
        return BusinessCategoryColors.fastFood;
      case BusinessType.hotel:
        return BusinessCategoryColors.hotel;
      case BusinessType.shopping:
        return BusinessCategoryColors.shopping;
      case BusinessType.mall:
        return BusinessCategoryColors.mall;
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
        return AppColors.secondary;
    }
  }

  static final List<UICategory> allCategories = Category.allCategories
      .map((c) => UICategory(c))
      .toList();
}
