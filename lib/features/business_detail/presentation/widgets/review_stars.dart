import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:flutter/material.dart';

/// Construit une rangée d'étoiles (pleine / demi / vide) représentant une
/// note. Extrait de review.dart pour garder ce fichier concis ; comportement
/// identique.
List<Widget> buildReviewStars(
  BuildContext context,
  double rating,
  double size,
) {
  final stars = <Widget>[];
  for (int i = 0; i < 5; i++) {
    if (i < rating.floor()) {
      stars.add(
        Icon(Icons.star, size: size, color: OtherTheme.of(context).rating),
      );
    } else if (i < rating) {
      stars.add(
        Icon(Icons.star_half, size: size, color: OtherTheme.of(context).rating),
      );
    } else {
      stars.add(
        Icon(
          Icons.star_border,
          size: size,
          color: OtherTheme.of(context).rating,
        ),
      );
    }
  }
  return stars;
}
