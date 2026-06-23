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
    color: AppColors.secondaryLight,
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

  static const TextStyle bodySmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 15,
    fontWeight: bold,
    color: AppColors.secondaryLight,
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
    color: AppColors.grey,
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