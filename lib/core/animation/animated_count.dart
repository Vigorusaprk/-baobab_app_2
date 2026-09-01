import 'package:baobabe_0_2/core/animation/app_motion.dart';
import 'package:flutter/material.dart';

/// Un nombre qui change **en passant par les valeurs intermédiaires** au lieu
/// de sauter.
///
/// L'application affiche plusieurs compteurs qui bougent sous les yeux : le
/// nombre d'activités en cours sur l'accueil, le nombre de filtres posés sur
/// Explorer, la quantité dans la barre d'achat. Chacun changeait d'un coup —
/// on voyait le nouveau chiffre sans avoir vu qu'il avait bougé.
///
/// Le défilement des valeurs dit ce que le saut cache : que c'est le **même**
/// compteur, et dans quel sens il va.
///
/// ```dart
/// AnimatedCount(value: state.filters.facetCount)
/// ```
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    super.key,
    required this.value,
    this.style,
    this.duration,
    this.prefix = '',
    this.suffix = '',
  });

  final int value;
  final TextStyle? style;

  /// Par défaut [AppMotion.calm] : un compteur qui défile trop vite ne se lit
  /// pas, on ne voit qu'un scintillement.
  final Duration? duration;

  final String prefix;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      // `begin` reste nul **volontairement** : `TweenAnimationBuilder` part
      // alors de la valeur courante. Le renseigner ferait repartir chaque
      // changement de la nouvelle valeur vers elle-même — soit aucune
      // animation, ce qui vidait ce widget de son objet.
      tween: Tween<double>(end: value.toDouble()),
      duration: AppMotion.duration(context, duration ?? AppMotion.calm),
      curve: AppMotion.standard,
      builder: (context, animated, _) =>
          Text('$prefix${animated.round()}$suffix', style: style),
    );
  }
}

/// Une valeur qui apparaît, change ou disparaît en fondu — pour du texte que
/// l'interpolation chiffrée ne concerne pas : un prix formaté, un libellé
/// d'état, une note.
///
/// ```dart
/// SwappingText('${offer.price.toStringAsFixed(0)} \$')
/// ```
class SwappingText extends StatelessWidget {
  const SwappingText(
    this.text, {
    super.key,
    this.style,
    this.duration,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final Duration? duration;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.duration(context, duration ?? AppMotion.base),
      switchInCurve: AppMotion.enter,
      switchOutCurve: AppMotion.exit,
      // Les deux textes se croisent au même endroit : sans cette pile alignée,
      // un libellé plus long pousserait ses voisins pendant la transition.
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.centerLeft,
        children: [...previous, ?current],
      ),
      child: Text(
        text,
        // La clé porte le texte : c'est elle qui dit à Flutter qu'il s'agit
        // d'une valeur différente et non du même widget rebâti.
        key: ValueKey(text),
        style: style,
        textAlign: textAlign,
      ),
    );
  }
}
