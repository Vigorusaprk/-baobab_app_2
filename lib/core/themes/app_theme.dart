import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_diemens.dart';

class AppTheme {
  static ThemeData get silvaTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      onPrimary: AppColors.textOnPrimary,
      onSecondary: AppColors.white,
      onSurface: AppColors.textPrimary,
      brightness: Brightness.light,
    ),

    textTheme: const TextTheme(
      headlineLarge: AppFonts.headlineLarge,
      titleMedium: AppFonts.titleMedium,
      bodyLarge: AppFonts.bodyLarge,
      bodyMedium: AppFonts.bodyMedium,
      bodySmall: AppFonts.bodySmall,
      labelLarge: AppFonts.button,
    ),

    cardColor: AppColors.surface,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textOnPrimary,
      elevation: AppDimens.elevationDefault,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textOnPrimary,
        fontFamily: AppFonts.primaryFontFamily,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.inputBorderRadius),
        borderSide: BorderSide.none,
      ),
      contentPadding: AppDimens.inputPadding,
      hintStyle: AppFonts.inputHintTextStyle,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        textStyle: AppFonts.button,
        padding: AppDimens.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderButton),
        ),
        elevation: AppDimens.elevationDefault,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppFonts.button,
        padding: AppDimens.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderButton),
        ),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
    ),

    dividerTheme: const DividerThemeData(
      thickness: AppDimens.borderWidthThin,
      color: AppColors.textSecondary,
    ),
  );
}
