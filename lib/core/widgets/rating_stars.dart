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
