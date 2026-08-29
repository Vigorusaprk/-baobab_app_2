import 'package:flutter/material.dart';

/// Palette officielle de l'application — à respecter strictement.
/// Toute nouvelle couleur doit être une de ces valeurs (ou une variante
/// d'opacité de l'une d'elles), jamais une teinte inventée.
///
/// ## Deux rôles par teinte sémantique
///
/// Une couleur d'état sert à deux choses qui n'ont pas les mêmes exigences :
/// **remplir une surface** et **porter du texte**. Les valeurs vives
/// ([success], [warning], [error]) ont été choisies pour la première ; sous
/// du blanc ou posées comme texte sur du blanc, elles descendaient jusqu'à
/// 1,83:1, là où la lisibilité en demande 4,5.
///
/// Chacune a donc une variante `...Content`, de même teinte mais plus
/// profonde, qui tient les deux emplois : lisible **en texte sur clair** et
/// **sous du texte blanc**. Une pastille se compose ainsi d'une surface
/// `...Surface` et d'un texte `...Content` ; un badge plein se compose d'un
/// fond `...Content` et de blanc.
///
/// Les valeurs vives restent celles de la marque : elles n'ont pas bougé.
class AppColors {
  AppColors._();

  // === Palette officielle ===
  static const Color primary = Color(0xFF0F2E20); // Vert profond
  static const Color secondary = Color(0xFF2E7D54); // Vert clair
  static const Color secondaryLight = Color(0xFFA3C9A5); // Vert doux
  static const Color background = Color(0xFFF2F4F3); // Gris neutre
  static const Color textPrimary = Color(0xFF1A1F1C); // Gris foncé
  static const Color white = Color(0xFFFFFFFF); // Blanc

  // === Rôles dérivés de la palette officielle ===
  static const Color surface = white;
  static const Color textOnPrimary = white;
  static const Color textSecondary = Color(0xFF4A5168);

  /// Fond très clair teinté de vert, pour une pastille de la marque.
  static const Color primarySurface = Color(0xFFE8F7F0);

  // === Neutres ===
  static const Color transparent = Colors.transparent;

  // === États : remplissage ===
  //
  // Réservées aux aplats larges surmontés de texte **foncé**, et aux icônes
  // décoratives. Ne jamais poser de blanc dessus : voir les `...Content`.
  static const Color success = Color(0xFF16C47F);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = Color(0xFFF04452);

  // === États : contenu ===
  //
  // Même teinte, descendue jusqu'à satisfaire **les trois** emplois à la
  // fois — c'est cette triple contrainte qui a fixé la valeur exacte :
  //
  //   emploi                          exigence   success  warning  error
  //   texte sur blanc                 >= 4,5       4,90     4,98    5,47
  //   blanc par-dessus (badge plein)  >= 4,5       4,90     4,98    5,47
  //   texte sur sa propre surface     >= 4,5       4,54     4,53    4,50
  //
  // C'est la valeur à utiliser pour un libellé, une icône signifiante, ou le
  // fond plein d'un badge à texte blanc.
  static const Color successContent = Color(0xFF0E8154);
  static const Color warningContent = Color(0xFF9B6400);
  static const Color errorContent = Color(0xFFD21121);

  // === États : surface ===
  //
  // Fonds très clairs pour les pastilles de statut, à marier avec le
  // `...Content` de la même teinte. Explicites plutôt qu'obtenus par
  // opacité : un empilement de transparences rend le contraste dépendant de
  // ce qu'il y a derrière, donc invérifiable.
  static const Color successSurface = Color(0xFFE3FCF2);
  static const Color warningSurface = Color(0xFFFDF3E3);
  static const Color errorSurface = Color(0xFFFDE3E5);

  // === Note ===
  //
  // L'or des étoiles. Une seule valeur : elle était jusqu'ici déclinée en
  // quatre nuances d'ambre selon le fichier, sur le signal même qui porte
  // la confiance dans le produit.
  //
  // [rating] reste volontairement vif : l'étoile est toujours accompagnée du
  // chiffre, elle ne porte donc jamais l'information seule. Dès qu'un texte
  // exprime la note, il utilise [ratingContent].
  static const Color rating = Color(0xFFFFC107);
  static const Color ratingContent = Color(0xFF8F6B00);
  static const Color ratingSurface = Color(0xFFFFF6DA);
}
