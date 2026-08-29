import 'package:flutter/material.dart';

/// Donne à l'application une colonne lisible sur les écrans larges.
///
/// Baobabe est une application de téléphone livrée aussi dans un navigateur.
/// Étirée sur 1280 px, elle devient illisible : une ligne de commerçant
/// traverse tout l'écran, une description se lit sur trente mots de large.
/// Ce n'est pas un tableau de bord — l'adapter au bureau, ce n'est pas
/// inventer des colonnes, c'est lui donner sa largeur naturelle et laisser
/// le reste de la fenêtre tranquille.
///
/// Posé une seule fois, dans le `builder` de `MaterialApp` : toutes les
/// routes en héritent, y compris l'espace commerçant et les pages pleines.
///
/// **Le `MediaQuery` est réécrit** pour la sous-arborescence : tout ce qui
/// mesure la largeur — hauteur des carrousels, points de rupture, tailles
/// dérivées — voit celle de la colonne, pas celle de la fenêtre. Sans cela,
/// l'application se croirait sur un écran large tout en n'en occupant qu'une
/// bande.
class AdaptiveViewport extends StatelessWidget {
  final Widget child;

  const AdaptiveViewport({super.key, required this.child});

  /// Au-delà, le contenu cesse de gagner en lisibilité. Trois cartes d'offre
  /// et demie tiennent dans le rail, ce qui laisse voir qu'il défile.
  static const double maxWidth = 560;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (media.size.width <= maxWidth) return child;

    final scheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: scheme.surface,
      child: Center(
        child: SizedBox(
          width: maxWidth,
          height: double.infinity,
          child: DecoratedBox(
            // Un filet de chaque côté : sans lui, la colonne ressemble à une
            // mise en page cassée plutôt qu'à un cadre voulu.
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: scheme.outlineVariant),
              ),
            ),
            child: MediaQuery(
              data: media.copyWith(size: Size(maxWidth, media.size.height)),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
