import 'package:flutter/material.dart';

/// Les rôles de couleur que [ColorScheme] n'a pas de case pour accueillir.
///
/// Material n'offre que `primary`, `secondary`, `tertiary` et `error`. Baobabe
/// a besoin de deux familles de plus — **succès** et **attention** — ainsi que
/// de l'or des notes et de la palette catégorielle. Les mettre ici plutôt que
/// dans des constantes globales a une conséquence précise : un thème sombre se
/// fabrique en construisant un second [OtherTheme], sans toucher à un seul
/// écran.
///
/// Chaque famille suit la grammaire de Material :
///
/// | rôle | emploi |
/// |---|---|
/// | `xxx` | l'aplat plein, surmonté de `onXxx` |
/// | `onXxx` | ce qui se pose **sur** l'aplat |
/// | `xxxContainer` | le fond de pastille, très clair |
/// | `onXxxContainer` | le texte **sur** cette pastille |
///
/// Toutes les paires sont vérifiées à ≥ 4,5:1. Les valeurs viennent d'un
/// calcul, pas d'un choix à l'œil : voir `AppColors`.
@immutable
class OtherTheme extends ThemeExtension<OtherTheme> {
  /// Succès — une commande honorée, un avis envoyé.
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  /// Attention — ce qui attend une réponse, ou ce qui ne se règle pas dans
  /// l'application (une offre à retrouver en boutique).
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  /// L'or des notes. [rating] reste vif : l'étoile est toujours accompagnée
  /// du chiffre, elle ne porte jamais l'information seule. Dès qu'un texte
  /// exprime la note, c'est [onRatingContainer].
  final Color rating;
  final Color ratingContainer;
  final Color onRatingContainer;

  /// Les couleurs d'identité des catégories de commerce. Ce ne sont pas des
  /// rôles d'interface mais des marqueurs de contenu — elles vivent quand
  /// même ici, pour qu'un thème sombre puisse les assourdir d'un bloc.
  final CategoryPalette categories;

  const OtherTheme({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.rating,
    required this.ratingContainer,
    required this.onRatingContainer,
    required this.categories,
  });

  /// Raccourci de lecture : `OtherTheme.of(context).warning`.
  ///
  /// Lève si l'extension n'est pas enregistrée — c'est voulu. Une couleur
  /// silencieusement remplacée par du gris est un défaut qu'on ne voit qu'en
  /// production.
  static OtherTheme of(BuildContext context) =>
      Theme.of(context).extension<OtherTheme>()!;

  @override
  OtherTheme copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? rating,
    Color? ratingContainer,
    Color? onRatingContainer,
    CategoryPalette? categories,
  }) {
    return OtherTheme(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      rating: rating ?? this.rating,
      ratingContainer: ratingContainer ?? this.ratingContainer,
      onRatingContainer: onRatingContainer ?? this.onRatingContainer,
      categories: categories ?? this.categories,
    );
  }

  @override
  OtherTheme lerp(covariant ThemeExtension<OtherTheme>? other, double t) {
    if (other is! OtherTheme) return this;
    return OtherTheme(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
      rating: Color.lerp(rating, other.rating, t)!,
      ratingContainer: Color.lerp(ratingContainer, other.ratingContainer, t)!,
      onRatingContainer: Color.lerp(
        onRatingContainer,
        other.onRatingContainer,
        t,
      )!,
      categories: categories.lerp(other.categories, t),
    );
  }
}

/// Les couleurs qui distinguent les types de commerce entre eux.
@immutable
class CategoryPalette {
  final Color restaurant;
  final Color fastFood;
  final Color shopping;
  final Color mall;
  final Color hotel;
  final Color carRental;
  final Color travelAgency;
  final Color spa;
  final Color cinema;
  final Color tourism;

  /// Quand la catégorie est inconnue, ou que le serveur n'a pas envoyé de
  /// couleur exploitable.
  final Color fallback;

  const CategoryPalette({
    required this.restaurant,
    required this.fastFood,
    required this.shopping,
    required this.mall,
    required this.hotel,
    required this.carRental,
    required this.travelAgency,
    required this.spa,
    required this.cinema,
    required this.tourism,
    required this.fallback,
  });

  CategoryPalette lerp(CategoryPalette other, double t) {
    return CategoryPalette(
      restaurant: Color.lerp(restaurant, other.restaurant, t)!,
      fastFood: Color.lerp(fastFood, other.fastFood, t)!,
      shopping: Color.lerp(shopping, other.shopping, t)!,
      mall: Color.lerp(mall, other.mall, t)!,
      hotel: Color.lerp(hotel, other.hotel, t)!,
      carRental: Color.lerp(carRental, other.carRental, t)!,
      travelAgency: Color.lerp(travelAgency, other.travelAgency, t)!,
      spa: Color.lerp(spa, other.spa, t)!,
      cinema: Color.lerp(cinema, other.cinema, t)!,
      tourism: Color.lerp(tourism, other.tourism, t)!,
      fallback: Color.lerp(fallback, other.fallback, t)!,
    );
  }
}
