import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:flutter/material.dart';

/// La rangée de cinq étoiles par laquelle on note.
///
/// Deux feuilles la demandaient — noter une offre livrée, écrire un avis sur
/// un commerce — et chacune l'avait écrite pour elle, avec sa propre taille
/// d'étoile et son propre libellé d'accessibilité.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    required this.onChanged,
    this.size = 34,
  });

  final int rating;
  final ValueChanged<int> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final value = index + 1;
        return IconButton(
          tooltip: '$value étoile${value > 1 ? 's' : ''}',
          onPressed: () => onChanged(value),
          icon: Icon(
            value <= rating ? Icons.star_rounded : Icons.star_border_rounded,
            color: OtherTheme.of(context).rating,
            size: size,
          ),
        );
      }),
    );
  }
}

/// Les étoiles d'une note qu'on **lit**, et qu'on ne pose pas.
///
/// Deux fonctionnalités en avaient chacune une version : `buildReviewStars`
/// rendait une liste de widgets à insérer dans une `Row` — donc un appelant
/// qui oubliait la `Row` cassait sa mise en page — et la fiche d'offre en
/// avait une autre, entière, sans demie. Celle-ci gère la demie et se pose
/// comme un widget.
class ReadOnlyStars extends StatelessWidget {
  const ReadOnlyStars({super.key, required this.rating, this.size = 14});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = OtherTheme.of(context).rating;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            i < rating.floor()
                ? Icons.star_rounded
                : i < rating
                ? Icons.star_half_rounded
                : Icons.star_border_rounded,
            size: size,
            color: color,
          ),
      ],
    );
  }
}
