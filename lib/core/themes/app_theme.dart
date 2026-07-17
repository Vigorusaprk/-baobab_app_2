import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_diemens.dart';

class AppTheme {
  static ThemeData get silvaTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.scaffoldBackground,
    canvasColor: AppColors.canvasBackground,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      onPrimary: AppColors.textOnPrimary,
      onSecondary: AppColors.textOnSecondary,
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
      backgroundColor: AppColors.scaffoldBackground,
      foregroundColor: AppColors.textOnPrimary,
      elevation: AppDimens.ELEVATION_2,
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
      fillColor: AppColors.inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.inputBorderRadius),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: const TextStyle(
        color: AppColors.grey,
        fontFamily: AppFonts.primaryFontFamily,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        textStyle: AppFonts.button,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderButton),
        ),
        elevation: AppDimens.ELEVATION_2,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppFonts.button,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderButton),
        ),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
    ),

    dividerTheme: const DividerThemeData(
      thickness: AppDimens.THICKNESS_1,
      color: Colors.grey,
    ),
  );
}
