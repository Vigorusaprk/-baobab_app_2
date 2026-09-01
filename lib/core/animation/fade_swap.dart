import 'package:baobabe_0_2/core/animation/app_motion.dart';
import 'package:flutter/material.dart';

/// Le passage d'un contenu à un autre au même endroit : squelette vers
/// contenu, contenu vers état vide, état vide vers erreur.
///
/// C'est **l'interaction la plus fréquente de l'application** et la seule qui
/// n'était pas animée : chaque écran remplaçait son squelette d'un seul coup,
/// à la trame près. Le contenu semblait sauter plutôt qu'arriver.
///
/// Le remplacement **croise** les deux états, sans les déplacer : l'ancien
/// s'efface pendant que le nouveau se révèle, au même endroit et à la même
/// place. Le nouveau contenu montait de quelques pixels ; comme il remplace
/// presque toujours un squelette de même forme, ce glissement se lisait comme
/// un décalage de la page. On veut l'inverse : l'impression que l'information
/// est simplement devenue nette. D'où [rise] à zéro par défaut.
///
/// Chaque état doit porter une **clé distincte**, sinon Flutter considère que
/// c'est le même widget et ne croise rien :
///
/// ```dart
/// FadeSwap(
///   child: state.isLoading
///       ? const _Skeleton(key: ValueKey('squelette'))
///       : _Content(key: const ValueKey('contenu'), items: state.items),
/// )
/// ```
class FadeSwap extends StatelessWidget {
  const FadeSwap({
    super.key,
    required this.child,
    this.duration,
    this.rise = 0,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;

  /// Par défaut [AppMotion.base].
  final Duration? duration;

  /// De combien le nouveau contenu monte en apparaissant. Zéro par défaut :
  /// voir l'explication en tête de classe. On ne le lève que pour un contenu
  /// qui n'a pas de squelette derrière lui.
  final double rise;

  /// Où les deux contenus s'alignent pendant le croisement. En haut par
  /// défaut : deux contenus de hauteurs différentes doivent partager leur
  /// bord supérieur, sinon tout le bloc paraît sauter.
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final d = AppMotion.duration(context, duration ?? AppMotion.base);

    return AnimatedSwitcher(
      duration: d,
      // Sortie plus rapide que l'entrée : sans cela les deux contenus se
      // superposent trop longtemps et le croisement se voit.
      reverseDuration: d * 0.6,
      switchInCurve: AppMotion.enter,
      switchOutCurve: AppMotion.exit,
      layoutBuilder: (current, previous) =>
          Stack(alignment: alignment, children: [...previous, ?current]),
      transitionBuilder: (child, animation) {
        final fade = FadeTransition(opacity: animation, child: child);
        if (rise == 0) return fade;
        return SlideTransition(
          position: Tween<Offset>(
            // Exprimé en fraction de la hauteur de l'enfant : un contenu haut
            // glisserait beaucoup trop si on donnait des pixels ici. On divise
            // donc par une hauteur de référence.
            begin: Offset(0, rise / 100),
            end: Offset.zero,
          ).animate(animation),
          child: fade,
        );
      },
      child: child,
    );
  }
}
