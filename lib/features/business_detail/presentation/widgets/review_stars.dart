import 'package:flutter/material.dart';

/// Construit une rangée d'étoiles (pleine / demi / vide) représentant une
/// note. Extrait de review.dart pour garder ce fichier concis ; comportement
/// identique.
List<Widget> buildReviewStars(double rating, double size) {
  final stars = <Widget>[];
  for (int i = 0; i < 5; i++) {
    if (i < rating.floor()) {
      stars.add(Icon(Icons.star, size: size, color: Colors.amber[700]));
    } else if (i < rating) {
      stars.add(Icon(Icons.star_half, size: size, color: Colors.amber[700]));
    } else {
      stars.add(Icon(Icons.star_border, size: size, color: Colors.amber[700]));
    }
  }
  return stars;
}
