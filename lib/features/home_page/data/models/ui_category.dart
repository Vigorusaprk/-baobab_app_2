import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/category_entity.dart';
import 'package:flutter/material.dart';


class UICategory {
  final Category category;

  UICategory(this.category);

  IconData get icon {
    switch (category.name) {
      case 'all':
        return Icons.explore;
      case 'restaurant':
        return Icons.restaurant;
      case 'fastFood':
        return Icons.fastfood;
      case 'shopping':
        return Icons.shopping_bag;
      case 'mall':
        return Icons.store_mall_directory;
      case 'hotel':
        return Icons.hotel;
      case 'carRental':
        return Icons.directions_car;
      case 'travelAgency':
        return Icons.card_travel;
      case 'spa':
        return Icons.spa;
      case 'cinema':
        return Icons.movie;
      case 'tourisme':
        return Icons.tour_rounded;
      default:
        return Icons.business;
    }
  }

  Color get color {
    switch (category.name) {
      case 'all':
        return Colors.blue;
      case 'restaurant':
        return AppColors.Restaurant;
      case 'fastFood':
        return AppColors.FastFood;
      case 'shopping':
        return AppColors.Shopping;
      case 'mall':
        return AppColors.Mall;
      case 'hotel':
        return AppColors.Hotel;
      case 'carRental':
        return AppColors.CarRental;
      case 'travelAgency':
        return AppColors.TravelAgency;
      case 'spa':
        return AppColors.Spa;
      case 'cinema':
        return AppColors.Cinema;
      case 'tourisme':
        return AppColors.Tourisme;
      default:
        return Colors.grey;
    }
  }

  static List<UICategory> get allCategories {
    return Category.allCategories.map((category) => UICategory(category)).toList();
  }
}