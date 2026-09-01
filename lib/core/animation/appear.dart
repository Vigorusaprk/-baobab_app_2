import 'package:baobabe_0_2/core/animation/app_motion.dart';
import 'package:flutter/material.dart';

/// L'entrée en scène d'un élément de liste : il se révèle un peu après son
/// voisin du dessus.
///
/// Une grille d'offres surgissait d'un bloc, toutes les cartes au même
/// instant. Le décalage donne une direction à la lecture — l'œil suit
/// l'arrivée du haut vers le bas au lieu de tout recevoir d'un coup.
///
/// **L'élément ne bouge pas.** Il montait de quelques pixels, et le résultat
/// était désagréable : à cet endroit précis se tenait déjà un squelette, de
/// la même taille et à la même place. Faire glisser la carte par-dessus
/// donnait un déplacement que rien ne justifiait. Une carte qui remplace son
/// squelette ne doit pas arriver — elle doit devenir nette. D'où [rise] à
/// zéro par défaut ; on ne le lève que là où rien ne précède l'élément.
///
/// **L'animation ne joue qu'une fois**, à la première apparition. Un élément
/// qui rejouerait son entrée à chaque reconstruction clignoterait au moindre
/// changement d'état, et pendant le défilement d'une liste recyclée il
/// clignoterait sans arrêt.
///
/// ```dart
/// itemBuilder: (context, index) => Appear(
///   index: index,
///   child: OfferCard(offer: offers[index], onTap: ...),
/// )
/// ```
///
/// Le décalage est plafonné à [AppMotion.maxStaggered] : sans cela, le
/// trentième élément attendrait plus d'une seconde et l'effet deviendrait une
/// attente.
class Appear extends StatefulWidget {
  const Appear({
    super.key,
    required this.child,
    this.index = 0,
    this.rise = 0,
    this.duration,
  });

  final Widget child;

  /// Rang de l'élément dans sa liste. Sert au décalage.
  final int index;

  /// De combien l'élément monte en apparaissant. Zéro par défaut : voir
  /// l'explication en tête de classe.
  final double rise;

  /// Par défaut [AppMotion.base].
  final Duration? duration;

  @override
  State<Appear> createState() => _AppearState();
}

class _AppearState extends State<Appear> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration ?? AppMotion.base,
  );

  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.enter,
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    if (AppMotion.reduced(context)) {
      // Mouvement réduit : l'élément est simplement là.
      _controller.value = 1;
      return;
    }

    final delay = AppMotion.delayFor(context, widget.index);
    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(delay, () {
        // L'écran a pu être quitté pendant l'attente.
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sans montée, pas de `Transform` du tout : une transformation identité
    // coûte une couche à chaque trame pour ne rien déplacer.
    if (widget.rise == 0) {
      return FadeTransition(opacity: _curve, child: widget.child);
    }

    return FadeTransition(
      opacity: _curve,
      child: AnimatedBuilder(
        animation: _curve,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, widget.rise * (1 - _curve.value)),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
