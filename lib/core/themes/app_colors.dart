import 'package:flutter/material.dart';

/// Palette officielle de l'application — à respecter strictement.
/// Toute nouvelle couleur doit être une de ces valeurs (ou une variante
/// d'opacité de l'une d'elles), jamais une teinte inventée.
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

  // === Neutres ===
  static const Color transparent = Colors.transparent;

  // === États ===
  static const Color success = Color(0xFF16C47F);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = Color(0xFFF04452);
}
