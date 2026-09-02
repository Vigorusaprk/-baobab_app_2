import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_diemens.dart';
import 'other_theme.dart';

/// **La source unique de la couleur et de la typographie.**
///
/// Aucun écran ne nomme une couleur ni une police : tout passe par
/// `Theme.of(context)`. C'est ce qui rend un thème sombre possible sans
/// toucher un seul widget — il se fabriquerait ici, en composant un second
/// [ColorScheme] et un second [OtherTheme], puis en les passant à [_build].
///
/// Où trouver quoi :
///
/// | besoin | où le lire |
/// |---|---|
/// | vert de marque, fonds, texte, erreur | `Theme.of(context).colorScheme` |
/// | succès, attention, note, catégories | `OtherTheme.of(context)` |
/// | tailles et graisses de texte | `Theme.of(context).textTheme` |
/// | espacements, rayons | `AppDimens` (sans rapport avec le thème) |
///
/// [AppColors] et [AppFonts] ne sont plus que les **valeurs primitives** de
/// ce fichier. Les lire depuis un écran contourne le thème et rendrait le
/// mode sombre impossible ; `test/theme_centralisation_test.dart` échoue si
/// cela se reproduit.
class AppTheme {
  /// La teinte des barres systeme.
  ///
  /// L'application n'a qu'un theme clair : les icones du systeme doivent donc
  /// etre sombres, sur des barres transparentes. `contrastEnforced` a `false`
  /// retire le voile que le systeme poserait de lui-meme derriere la barre de
  /// navigation, et qui trancherait avec notre fond.
  static const SystemUiOverlayStyle systemOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarContrastEnforced: false,
  );

  AppTheme._();

  /// Le thème clair — le seul livré aujourd'hui.
  static ThemeData get silvaTheme => _build(_lightScheme, _lightOther);

  // ===========================================================================
  // Schémas
  // ===========================================================================

  /// Chaque rôle est posé à la main plutôt que dérivé d'une graine.
  /// `ColorScheme.fromSeed` aurait inventé les rôles non précisés (`outline`,
  /// `tertiary`, les `surfaceContainer`) à partir d'un algorithme : des
  /// valeurs que personne n'a choisies et que personne ne peut vérifier.
  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,

    // Le vert de marque.
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.primarySurface,
    onPrimaryContainer: AppColors.primary,

    // Le vert clair : actions secondaires, badges « à commander ».
    secondary: AppColors.secondary,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.primarySurface,
    onSecondaryContainer: AppColors.secondary,

    // Pas de troisième famille de marque : `tertiary` renvoie au vert clair
    // plutôt qu'à une teinte inventée qu'aucun écran n'assume.
    tertiary: AppColors.secondary,
    onTertiary: AppColors.white,
    tertiaryContainer: AppColors.primarySurface,
    onTertiaryContainer: AppColors.secondary,

    // L'erreur porte la valeur « contenu » : elle sert autant de texte sur
    // clair que d'aplat sous du blanc.
    error: AppColors.errorContent,
    onError: AppColors.white,
    errorContainer: AppColors.errorSurface,
    onErrorContainer: AppColors.errorContent,

    // La page est légèrement teintée ; les cartes sont blanches et se
    // détachent dessus.
    surface: AppColors.background,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    surfaceContainerLowest: AppColors.white,
    surfaceContainerLow: AppColors.white,
    surfaceContainer: AppColors.background,
    surfaceContainerHigh: AppColors.background,
    surfaceContainerHighest: AppColors.background,

    // Traits et séparateurs. `secondaryLight` ne vit plus que là : à 1,83:1
    // elle ne peut porter ni texte ni blanc.
    outline: AppColors.textSecondary,
    outlineVariant: AppColors.secondaryLight,

    shadow: AppColors.textPrimary,
    scrim: AppColors.textPrimary,

    // Les surfaces inversées — SnackBar, infobulles.
    inverseSurface: AppColors.primary,
    onInverseSurface: AppColors.white,
    inversePrimary: AppColors.secondaryLight,

    surfaceTint: AppColors.transparent,
  );

  static const OtherTheme _lightOther = OtherTheme(
    success: AppColors.success,
    onSuccess: AppColors.textPrimary,
    successContainer: AppColors.successSurface,
    onSuccessContainer: AppColors.successContent,

    warning: AppColors.warning,
    onWarning: AppColors.textPrimary,
    warningContainer: AppColors.warningSurface,
    onWarningContainer: AppColors.warningContent,

    rating: AppColors.rating,
    ratingContainer: AppColors.ratingSurface,
    onRatingContainer: AppColors.ratingContent,

    categories: CategoryPalette(
      restaurant: AppColors.categoryRestaurant,
      fastFood: AppColors.categoryFastFood,
      shopping: AppColors.categoryShopping,
      mall: AppColors.categoryMall,
      hotel: AppColors.categoryHotel,
      carRental: AppColors.categoryCarRental,
      travelAgency: AppColors.categoryTravelAgency,
      spa: AppColors.categorySpa,
      cinema: AppColors.categoryCinema,
      tourism: AppColors.categoryTourism,
      fallback: AppColors.textSecondary,
    ),
  );

  // ===========================================================================
  // Fabrique
  // ===========================================================================

  /// Assemble un thème complet à partir d'un schéma et de ses rôles étendus.
  ///
  /// Tout ce qui suit est exprimé en fonction de [scheme] : ajouter un thème
  /// sombre ne demande donc rien d'autre qu'un second couple
  /// (`ColorScheme`, `OtherTheme`) passé ici.
  static ThemeData _build(ColorScheme scheme, OtherTheme other) {
    final textTheme = _textTheme(scheme);

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      cardColor: scheme.surfaceContainerLowest,
      textTheme: textTheme,
      extensions: [other],

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: AppDimens.elevationDefault,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
        // Depuis la cible API 35, Android impose le bord a bord : la barre
        // d'etat est transparente et le contenu passe dessous. Sans cette
        // consigne, la teinte des icones systeme n'est pilotee par personne,
        // et l'heure peut se retrouver en blanc sur notre fond clair.
        systemOverlayStyle: AppTheme.systemOverlay,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.inputBorderRadius),
          borderSide: BorderSide.none,
        ),
        contentPadding: AppDimens.inputPadding,
        hintStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        labelStyle: textTheme.labelSmall,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: textTheme.labelLarge,
          padding: AppDimens.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.borderButton),
          ),
          elevation: AppDimens.elevationDefault,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.secondary,
          disabledForegroundColor: scheme.onSecondary,
          textStyle: textTheme.labelLarge,
          padding: AppDimens.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.borderButton),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge,
          padding: AppDimens.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.borderButton),
          ),
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.2)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),

      iconTheme: IconThemeData(color: scheme.onSurface),

      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyMedium,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: scheme.surfaceContainerLowest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.inputBorderRadius),
            borderSide: BorderSide.none,
          ),
          contentPadding: AppDimens.inputPadding,
          hintStyle: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
          labelStyle: textTheme.labelSmall,
        ),
      ),

      // Le SnackBar par défaut : les cas colorés (succès, erreur) posent leur
      // propre fond, mais celui-ci doit déjà être lisible.
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        behavior: SnackBarBehavior.floating,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: AppColors.transparent,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        selectedColor: scheme.primary,
        labelStyle: textTheme.bodySmall,
        // `secondaryLabelStyle` est celui de la puce sélectionnée : sans
        // lui, le libellé garde sa couleur de repos sur l'aplat vert.
        secondaryLabelStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onPrimary,
        ),
        side: BorderSide.none,
        showCheckmark: false,
      ),

      dividerTheme: DividerThemeData(
        thickness: AppDimens.borderWidthThin,
        color: scheme.outlineVariant,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
    );
  }

  // ===========================================================================
  // Typographie
  // ===========================================================================

  /// L'échelle complète, couleurs comprises.
  ///
  /// Chaque taille employée dans l'application a sa case : un écran n'a plus
  /// aucune raison d'écrire un `TextStyle` à la main. Les valeurs reprennent
  /// exactement celles qui étaient en place — centraliser n'est pas
  /// redessiner.
  ///
  /// Elle compte cependant treize marches (10 à 28 px), ce qui est le signe
  /// d'une échelle jamais dessinée mais accumulée. La resserrer relève d'une
  /// passe de typographie, pas de ce fichier.
  static TextTheme _textTheme(ColorScheme scheme) {
    TextStyle style(double size, FontWeight weight, {Color? color}) {
      return TextStyle(
        fontFamily: AppFonts.primaryFontFamily,
        fontSize: size,
        fontWeight: weight,
        color: color ?? scheme.onSurface,
      );
    }

    return TextTheme(
      // Titres d'écran.
      displayLarge: style(28, AppFonts.bold, color: scheme.primary),
      displayMedium: style(26, AppFonts.extraBold, color: scheme.primary),
      displaySmall: style(24, AppFonts.bold, color: scheme.primary),

      headlineLarge: style(22, AppFonts.bold, color: scheme.primary),
      headlineMedium: style(20, AppFonts.bold, color: scheme.primary),
      headlineSmall: style(18, AppFonts.extraBold),

      // Titres de section et de carte.
      titleLarge: style(20, AppFonts.bold),
      titleMedium: style(18, AppFonts.medium, color: scheme.primary),
      titleSmall: style(15, AppFonts.semiBold),

      // Corps de texte.
      bodyLarge: style(18, AppFonts.bold),
      bodyMedium: style(16, AppFonts.regular),
      bodySmall: style(12, AppFonts.regular, color: scheme.onSurfaceVariant),

      // Libellés : boutons, puces, mentions.
      labelLarge: style(16, AppFonts.semiBold, color: scheme.onPrimary),
      labelMedium: style(14, AppFonts.regular),
      labelSmall: style(13, AppFonts.regular, color: scheme.onSurfaceVariant),
    );
  }
}
