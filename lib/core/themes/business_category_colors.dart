import 'package:flutter/material.dart';

/// Palette catégorielle utilisée pour distinguer visuellement les types
/// d'établissements (badges, icônes, accents). Ce n'est pas un token de
/// thème UI — séparée de [AppColors] pour ne pas polluer la palette
/// officielle de la marque.
class BusinessCategoryColors {
  BusinessCategoryColors._();

  static const Color restaurant = Color(0xFFFF6B57);
  static const Color fastFood = Color(0xFFFF9800);
  static const Color shopping = Color(0xFF00B8D9);
  static const Color mall = Color(0xFF8B5CF6);
  static const Color hotel = Color(0xFF536DFE);
  static const Color carRental = Color(0xFF3BB273);
  static const Color travelAgency = Color(0xFF00C2A8);
  static const Color spa = Color(0xFF2DD4BF);
  static const Color cinema = Color(0xFFE64980);
  static const Color tourism = Color(0xFF7950F2);
}
