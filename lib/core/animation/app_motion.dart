import 'package:flutter/material.dart';

/// Le vocabulaire du mouvement, comme `app_theme.dart` est celui de la
/// couleur.
///
/// L'application comptait **huit durées différentes** (50, 120, 150, 180, 200,
/// 220, 300, 350 ms) et trois courbes, chacune choisie sur le moment. Rien ne
/// les reliait, et deux transitions voisines n'avaient donc aucune raison de
/// se ressembler. Trois durées suffisent :
///
/// - [quick] — une réaction au doigt. Elle doit paraître instantanée : au-delà
///   de ~150 ms, l'appui semble mou.
/// - [base] — le mouvement courant, celui qu'on remarque à peine : un contenu
///   qui remplace un autre, une carte qui entre.
/// - [calm] — ce qui traverse l'écran ou change beaucoup de choses à la fois.
///
/// **Le mouvement se demande au contexte**, jamais en dur : quand le système
/// est réglé sur « réduire les animations », les durées tombent à zéro. Ce
/// réglage existe pour les personnes que le mouvement gêne — vertiges,
/// troubles vestibulaires — et une animation « juste jolie » ne vaut pas leur
/// inconfort.
class AppMotion {
  const AppMotion._();

  static const Duration quick = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration calm = Duration(milliseconds: 320);

  /// Ce qui arrive : départ franc, arrivée douce. C'est l'inverse pour ce qui
  /// part, qu'on ne regarde plus.
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;

  /// Un aller-retour, ou une valeur qui se déplace d'un point à un autre.
  static const Curve standard = Curves.easeInOutCubic;

  /// Le retard ajouté à chaque élément d'une liste qui entre en scène.
  ///
  /// Volontairement court : au-delà, les derniers éléments arrivent après que
  /// l'œil est déjà descendu les chercher.
  static const Duration stagger = Duration(milliseconds: 45);

  /// Nombre d'éléments au-delà duquel on cesse de décaler l'entrée.
  ///
  /// Sans plafond, le trentième élément d'une liste attendrait une seconde et
  /// demie — l'effet se transformerait en attente.
  static const int maxStaggered = 8;

  /// Le système demande-t-il de réduire les animations ?
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [duration], ou zéro si l'utilisateur a demandé moins de mouvement.
  static Duration duration(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;

  /// Le décalage d'entrée du [index]-ième élément, plafonné et annulé quand le
  /// mouvement est réduit.
  static Duration delayFor(BuildContext context, int index) {
    if (reduced(context)) return Duration.zero;
    final steps = index < 0 ? 0 : (index > maxStaggered ? maxStaggered : index);
    return stagger * steps;
  }
}
