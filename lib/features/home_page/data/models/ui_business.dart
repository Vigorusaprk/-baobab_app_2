import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:flutter/material.dart';

class UIBusiness {
  final Business business;

  UIBusiness(this.business);

  /// La couleur d'identité de la catégorie, lue dans le thème.
  ///
  /// Prend un contexte plutôt que d'être un getter : la palette
  /// catégorielle vit dans [OtherTheme], pour qu'un thème sombre puisse
  /// l'assourdir d'un bloc.
  Color categoryColor(BuildContext context) {
    final palette = OtherTheme.of(context).categories;
    switch (business.type) {
      case BusinessType.restaurant:
        return palette.restaurant;
      case BusinessType.fastFood:
        return palette.fastFood;
      case BusinessType.shopping:
        return palette.shopping;
      case BusinessType.mall:
        return palette.mall;
      case BusinessType.hotel:
        return palette.hotel;
      case BusinessType.carRental:
        return palette.carRental;
      case BusinessType.travelAgency:
        return palette.travelAgency;
      case BusinessType.spa:
        return palette.spa;
      case BusinessType.cinema:
        return palette.cinema;
      case BusinessType.tourism:
        return palette.tourism;
      default:
        return palette.fallback;
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
