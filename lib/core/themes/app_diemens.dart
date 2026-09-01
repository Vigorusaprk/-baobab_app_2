import 'package:flutter/material.dart';

class AppDimens {
  /// Height for a horizontally-scrolling section (carousel, chip row...),
  /// computed as a fraction of the screen height instead of a single
  /// hardcoded pixel value — so cards stay proportionate across small
  /// phones and tablets rather than looking cramped or oversized.
  /// `min`/`max` guard against extreme screen sizes (very short landscape,
  /// large tablets).
  static double horizontalScrollHeight(
    BuildContext context,
    double heightFactor, {
    double? min,
    double? max,
  }) {
    final height = MediaQuery.of(context).size.height * heightFactor;
    if (min != null && height < min) return min;
    if (max != null && height > max) return max;
    return height;
  }

  // *** Spacing générique — 3 tailles seulement, aucune exception *** //
  /// Le plus petit carré qu'un doigt vise sans effort. Material demande
  /// 48 dp ; en dessous, la cible se rate.
  static const double touchTarget = 48.0;

  static const double tiny = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;

  // *** Radius générique *** //
  static const double radius8 = 8.0;
  static const double radius10 = 10.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius20 = 20.0;
  static const double radius30 = 30.0;
  static const double radius50 = 50.0;
  static const double borderRadiusFull = 100.0;

  // *** Autres tokens spécifiques (ne pas fusionner) *** //
  /// Rayon des coins hauts d'une feuille modale.
  static const double bottomSheet = 30.0;

  /// La poignée de glissement d'une feuille : la barre grise du haut.
  static const double bottomSheetHandleWidth = 52.0;
  static const double bottomSheetHandleHeight = 5.0;
  static const double elevationDefault = 2.0;
  static const double borderWidthThin = 1.0;

  static const double appPaddingValue = 16.0;

  // *** Cards *** //
  static const double smallCardBorderRadius = 12.0;
  static const double cardBorderRadius = 20.0;
  static const cardBorderRadiusAll = BorderRadius.all(
    Radius.circular(cardBorderRadius),
  );

  // *** PADDING *** //

  //** ALL **//
  static const double allPadding12Number = 12.0;
  static const allPadding8 = EdgeInsets.all(8);
  static const allPadding12 = EdgeInsets.all(allPadding12Number);
  static EdgeInsets carouselPadding(int index, int length) => EdgeInsets.only(
    left: index == 0 ? AppDimens.appPaddingValue : 8.0,
    right: index == length - 1 ? AppDimens.appPaddingValue : 8.0,
    top: 8.0,
    bottom: 8.0,
  );

  //** SYMMETRIC **//
  static const appPadding = EdgeInsets.symmetric(horizontal: appPaddingValue);

  // *** Button *** //
  static const double borderButton = 20.0;
  static const double borderRadiusSmallButton = 16.0;
  static const buttonPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 12,
  );

  // *** Input field *** //
  static const double inputBorderRadius = 20.0;
  static const inputPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  // *** Spacer *** //
  // ** Height ** //
  static const Widget spacerMini = SizedBox(height: 4.0);
  static const Widget spacerSmall = SizedBox(height: 8.0);
  static const Widget spacerMedium = SizedBox(height: 16.0);
  static const Widget spacerLarge = SizedBox(height: 24.0);

  // ** Width ** //
  static const Widget spacerMiniWidth = SizedBox(width: 4.0);
  static const Widget spacerSmallWidth = SizedBox(width: 8.0);
  static const Widget spacerMediumWidth = SizedBox(width: 16.0);
  static const Widget spacerLargeWidth = SizedBox(width: 24.0);

  static const Widget spacerAppPaddingLarge = SizedBox(width: appPaddingValue);
}
