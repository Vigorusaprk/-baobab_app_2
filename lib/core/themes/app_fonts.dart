import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class AppFonts {
  // Font Family
  static const String primaryFontFamily = 'Poppins';

  // Font Weights
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // Text Styles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 28,
    fontWeight: bold,
    color: AppColors.primary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 18,
    fontWeight: medium,
    color: AppColors.primary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 18,
    fontWeight: bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: regular,
    color: AppColors.textPrimary,
  );

  // `secondaryLight` était la couleur par défaut de ce style, à 1,83:1 sur
  // blanc. Comme il est câblé dans le thème, tout `textTheme.bodySmall` sans
  // surcharge héritait d'un texte illisible — le défaut d'un token ne doit
  // jamais être la valeur qu'il faut corriger à chaque appel.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: bold,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: semiBold,
    color: AppColors.textOnPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: regular,
    color: AppColors.textSecondary,
  );

  static const TextStyle inputHintTextStyle = TextStyle(
    color: AppColors.textSecondary,
    fontFamily: AppFonts.primaryFontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 14,
  );

  static const TextStyle inputTextStyle = TextStyle(
    color: AppColors.textPrimary,
    fontFamily: AppFonts.primaryFontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 14,
  );

  // Responsive font sizes
  static double responsiveFontSize(BuildContext context, double baseSize) {
    final double width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return baseSize;
    } else if (width < 900) {
      return baseSize * 1.2;
    } else {
      return baseSize * 1.4;
    }
  }
}
