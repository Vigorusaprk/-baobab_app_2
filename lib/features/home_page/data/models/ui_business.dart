import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';

class UIBusiness {
  final Business business;

  UIBusiness(this.business);

  Color get categoryColor {
    switch (business.type) {
      case BusinessType.restaurant:
        return AppColors.restaurant;
      case BusinessType.fastFood:
        return AppColors.fastFood;
      case BusinessType.shopping:
        return AppColors.shopping;
      case BusinessType.mall:
        return AppColors.mall;
      case BusinessType.hotel:
        return AppColors.hotel;
      case BusinessType.carRental:
        return AppColors.carRental;
      case BusinessType.travelAgency:
        return AppColors.travelAgency;
      case BusinessType.spa:
        return AppColors.spa;
      case BusinessType.cinema:
        return AppColors.cinema;
      case BusinessType.tourism:
        return AppColors.tourism;
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
        return Icons.tour;
      default:
        return Icons.business;
    }
  }

  bool get isOpen => true;
}