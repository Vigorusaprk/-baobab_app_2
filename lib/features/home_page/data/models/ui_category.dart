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
      default:
        return Icons.business;
    }
  }

  Color get color {
    switch (category.name) {
      case 'all':
        return Colors.blue;
      case 'restaurant':
        return Colors.orange;
      case 'fastFood':
        return Colors.red;
      case 'shopping':
        return Colors.purple;
      case 'mall':
        return Colors.indigo;
      case 'hotel':
        return Colors.teal;
      case 'carRental':
        return Colors.blueGrey;
      case 'travelAgency':
        return Colors.indigoAccent;
      case 'spa':
        return Colors.purple;
      case 'cinema':
        return Colors.lightBlue;
      default:
        return Colors.grey;
    }
  }

  static List<UICategory> get allCategories {
    return Category.allCategories.map((category) => UICategory(category)).toList();
  }
}