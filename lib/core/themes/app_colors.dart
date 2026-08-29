import 'package:flutter/material.dart';

/// Les **valeurs primitives** de la palette. Rien d'autre.
///
/// ⚠️ Ce fichier n'est lu que par `app_theme.dart`. Un écran qui écrit
/// `AppColors.primary` court-circuite le thème et rend un mode sombre
/// impossible : il lit alors une constante, pas un rôle. Depuis un widget,
/// on passe **toujours** par `Theme.of(context).colorScheme` ou
/// `OtherTheme.of(context)`.
///
/// `test/theme_centralisation_test.dart` échoue si cette règle est enfreinte.
///
/// Une primitive n'a pas de sens en soi : c'est le thème qui lui donne un
/// rôle. Ne pas en ajouter ici sans lui en attribuer un là-bas.
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

  // === Identité des catégories ===
  //
  // Ce ne sont pas des rôles d'interface mais des marqueurs de contenu : elles
  // distinguent un restaurant d'un hôtel. Elles passent quand même par le
  // thème (`OtherTheme.categories`), pour qu'un mode sombre puisse les
  // assourdir d'un bloc plutôt qu'écran par écran.
  static const Color categoryRestaurant = Color(0xFFFF6B57);
  static const Color categoryFastFood = Color(0xFFFF9800);
  static const Color categoryShopping = Color(0xFF00B8D9);
  static const Color categoryMall = Color(0xFF8B5CF6);
  static const Color categoryHotel = Color(0xFF536DFE);
  static const Color categoryCarRental = Color(0xFF3BB273);
  static const Color categoryTravelAgency = Color(0xFF00C2A8);
  static const Color categorySpa = Color(0xFF2DD4BF);
  static const Color categoryCinema = Color(0xFFE64980);
  static const Color categoryTourism = Color(0xFF7950F2);
}
