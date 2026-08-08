import 'package:flutter/material.dart';

class AppDimens {
  // *** Spacing générique — 3 tailles seulement, aucune exception *** //
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
  static const double bottomSheet = 30.0;
  static const double elevationDefault = 2.0;
  static const double borderWidthThin = 1.0;

  static const double appPaddingValue = 24.0;

  // *** Cards *** //
  static const double cardBorderRadius = 20.0;
  static const cardBorderRadiusAll = BorderRadius.all(Radius.circular(cardBorderRadius));

  // *** PADDING *** //

  //** ALL **//
  static const double allPadding12Number = 12.0;
  static const allPadding8 = EdgeInsets.all(8);
  static const allPadding12 = EdgeInsets.all(allPadding12Number);

  //** SYMMETRIC **//
  static const appPadding = EdgeInsets.symmetric(horizontal: appPaddingValue);

  // *** Button *** //
  static const double borderButton = 20.0;
  static const double borderRadiusAuthIconButton = 16.0;
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
  static const Widget spacerSmallWidth = SizedBox(width: 8.0);
  static const Widget spacerAppPaddingLarge = SizedBox(width: appPaddingValue);
}
