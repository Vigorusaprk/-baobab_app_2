import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

/// Construit une rangée d'étoiles (pleine / demi / vide) représentant une
/// note. Extrait de review.dart pour garder ce fichier concis ; comportement
/// identique.
List<Widget> buildReviewStars(double rating, double size) {
  final stars = <Widget>[];
  for (int i = 0; i < 5; i++) {
    if (i < rating.floor()) {
      stars.add(Icon(Icons.star, size: size, color: AppColors.rating));
    } else if (i < rating) {
      stars.add(Icon(Icons.star_half, size: size, color: AppColors.rating));
    } else {
      stars.add(Icon(Icons.star_border, size: size, color: AppColors.rating));
    }
  }
  return stars;
}
