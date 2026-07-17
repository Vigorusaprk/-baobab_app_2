import 'package:flutter/material.dart';

/// ===============================================================
/// BAOBAB DESIGN SYSTEM
/// ---------------------------------------------------------------
/// Palette officielle de l'application Baobab
///
/// Concept visuel :
///
/// • Innovation
/// • Voyage
/// • Luxe moderne
/// • Culture africaine
/// • Interface lumineuse
///
/// Le thème abandonne volontairement les codes "vert nature"
/// afin de créer une identité forte et mémorable.
/// ===============================================================

class AppColors {
  AppColors._();

  // ===============================================================
  // PRIMARY (Identité de Baobab)
  // Indigo moderne
  // ===============================================================

  static const Color primary = Color(0xFF0F2E20);
  static const Color primaryLight = Color(0xFF0F2E20);
  static const Color primaryDark = Color(0xFF0F2E20);

  // Variantes

  static const Color primary50 = Color(0xFFF1EFFF);
  static const Color primary100 = Color(0xFFDED9FF);
  static const Color primary200 = Color(0xFFC8C1FF);
  static const Color primary300 = Color(0xFFAEA5FF);
  static const Color primary400 = Color(0xFF897DFF);
  static const Color primary500 = primary;
  static const Color primary600 = Color(0xFF3D31E8);
  static const Color primary700 = Color(0xFF3026C8);
  static const Color primary800 = Color(0xFF251D9D);
  static const Color primary900 = Color(0xFF1C1676);

  // ===============================================================
  // SECONDARY
  // Orange coucher de soleil
  // ===============================================================

  static const Color secondary = Color(0xFFFF8A3D);
  static const Color secondaryLight = Color(0xFFFFB47A);
  static const Color secondaryDark = Color(0xFFD96A20);

  static const Color secondary50 = Color(0xFFFFF4EB);
  static const Color secondary100 = Color(0xFFFFE4CC);
  static const Color secondary200 = Color(0xFFFFD1A8);
  static const Color secondary300 = Color(0xFFFFBB80);
  static const Color secondary400 = Color(0xFFFFA35A);
  static const Color secondary500 = secondary;
  static const Color secondary600 = Color(0xFFE67022);
  static const Color secondary700 = Color(0xFFC85B11);
  static const Color secondary800 = Color(0xFFA54808);
  static const Color secondary900 = Color(0xFF813603);

  // ===============================================================
  // ACCENT
  // Cyan moderne
  // ===============================================================

  static const Color accent = Color(0xFF2EC9FF);

  static const Color accent50 = Color(0xFFE8FBFF);
  static const Color accent100 = Color(0xFFC7F3FF);
  static const Color accent200 = Color(0xFF9BEAFF);
  static const Color accent300 = Color(0xFF6CDFFF);
  static const Color accent400 = Color(0xFF46D5FF);
  static const Color accent500 = accent;
  static const Color accent600 = Color(0xFF17B5EA);
  static const Color accent700 = Color(0xFF0699C8);
  static const Color accent800 = Color(0xFF027CA2);
  static const Color accent900 = Color(0xFF005C77);

  // ===============================================================
  // COULEURS DE FOND
  // ===============================================================

  /// Fond général de l'application
  static const Color scaffoldBackground = Color(0xFFF8F8FC);

  /// Fond des pages secondaires
  static const Color canvasBackground = Color(0xFFF2F3F8);

  /// Surface principale (Cards)
  static const Color surface = Colors.white;

  /// Surface légèrement contrastée
  static const Color surfaceVariant = Color(0xFFF7F7FA);

  /// Dialogues
  static const Color dialogBackground = Colors.white;

  /// Bottom Sheet
  static const Color bottomSheet = Colors.white;

  // ===============================================================
  // TEXTE
  // ===============================================================
  static const Color textColor = Color(0xFF1A1F1C);
  
  static const Color textPrimary = Color(0xFF1C2235);

  static const Color textSecondary = Color(0xFF4A5168);

  static const Color textBody = Color(0xFF626B83);

  static const Color textMuted = Color(0xFF8C93AA);

  static const Color textHint = Color(0xFFA4AABE);

  static const Color textDisabled = Color(0xFFB5BAC8);

  static const Color textOnPrimary = Colors.white;

  static const Color textOnSecondary = Colors.white;

  // ===============================================================
  // FORMULAIRES
  // ===============================================================

  /// Fond des TextField
  static const Color inputBackground = Color(0xFFF4F5FA);

  /// Bordure normale
  static const Color inputBorder = Color(0xFFDADDEA);

  /// Hover
  static const Color inputHover = Color(0xFFECEEF8);

  /// Focus
  static const Color inputFocused = primary;

  /// Désactivé
  static const Color inputDisabled = Color(0xFFF7F8FB);

  /// Erreur
  static const Color inputError = Color(0xFFFCE8EA);

  /// Bordure erreur
  static const Color inputErrorBorder = Color(0xFFE94B5A);

  /// Bordure succès
  static const Color inputSuccessBorder = Color(0xFF15B86C);

  // ===============================================================
  // DIVIDERS
  // ===============================================================

  static const Color divider = Color(0xFFE5E8F1);

  static const Color border = Color(0xFFE2E5EF);

  // ===============================================================
  // COULEURS D'ÉTAT
  // ===============================================================

  static const Color success = Color(0xFF16C47F);

  static const Color warning = Color(0xFFFFB020);

  static const Color error = Color(0xFFF04452);

  static const Color info = Color(0xFF3A86FF);

  // ===============================================================
  // CARTES PAR CATÉGORIE
  // ===============================================================

  static const Color restaurantCard = Color(0xFFFFF6F2);

  static const Color shoppingCard = Color(0xFFF5FAFF);

  static const Color hotelCard = Color(0xFFF5F4FF);

  static const Color spaCard = Color(0xFFF8FFF8);

  static const Color travelCard = Color(0xFFF2FFFF);

  static const Color cinemaCard = Color(0xFFFFF4F8);

  static const Color mallCard = Color(0xFFFAF5FF);

  static const Color carRentalCard = Color(0xFFF6F8FF);

  // ===============================================================
  // COULEURS DES TYPES DE BUSINESS
  // ===============================================================

  static const Color restaurant = Color(0xFFFF6B57);

  static const Color fastFood = Color(0xFFFF9800);

  static const Color shopping = Color(0xFF00B8D9);

  static const Color mall = Color(0xFF8B5CF6);

  static const Color hotel = Color(0xFF536DFE);

  static const Color carRental = Color(0xFF3BB273);

  static const Color travelAgency = Color(0xFF00C2A8);

  static const Color spa = Color(0xFF2DD4BF);

  static const Color cinema = Color(0xFFE64980);

  static const Color tourism = Color(0xFF7950F2);

  // ===============================================================
  // COULEURS DES AVATARS
  // ===============================================================

  static const List<Color> avatarColors = [
    Color(0xFFFF6B57),
    Color(0xFF845EF7),
    Color(0xFF3A86FF),
    Color(0xFFFFD166),
    Color(0xFF2DD4BF),
    Color(0xFFE64980),
    Color(0xFF7C5CFC),
    Color(0xFF00C2FF),
    Color(0xFF9CCC65),
    Color(0xFFFF9F1C),
  ];

  // ===============================================================
  // OMBRES
  // Utilisées pour les cartes et les boutons
  // ===============================================================

  static const Color shadow = Color(0x14000000);

  // ===============================================================
  // BASIQUES
  // ===============================================================

  static const Color white = Colors.white;

  static const Color black = Colors.black;

  static const Color transparent = Colors.transparent;

    static const Color grey = Color(0xFF9E9E9E);
}
