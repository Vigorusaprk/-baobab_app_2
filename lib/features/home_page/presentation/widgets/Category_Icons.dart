import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_category.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/category_entity.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Métriques de la bande de catégories, partagées avec l'en-tête collant
/// qui pilote son repliement ([HomeSliverHeader]). Regroupées ici pour que
/// la hauteur affichée et la hauteur réservée par le sliver ne puissent pas
/// diverger.
class CategoryIconsMetrics {
  const CategoryIconsMetrics._();

  /// Hauteur de la bande en haut de page : vignettes en colonne
  /// (icône ronde + libellé dessous).
  static const double expandedHeight = 104;

  /// Hauteur de la bande une fois l'en-tête figé : pastilles en ligne
  /// (icône + libellé côte à côte).
  static const double collapsedHeight = 46;

  static double heightFor(double collapseProgress) =>
      lerpDouble(expandedHeight, collapsedHeight, collapseProgress)!;
}

/// Bande horizontale de filtres par catégorie.
///
/// [collapseProgress] interpole la vignette entre deux mises en page :
/// `0` = colonne (icône ronde, libellé dessous), `1` = ligne compacte
/// (icône + libellé côte à côte). La valeur vient du `shrinkOffset` de
/// l'en-tête collant, donc le morphing suit le scroll en continu plutôt
/// que de basculer d'un état à l'autre.
class CategoryIcons extends StatelessWidget {
  final double collapseProgress;

  const CategoryIcons({super.key, this.collapseProgress = 0});

  @override
  Widget build(BuildContext context) {
    final t = collapseProgress.clamp(0.0, 1.0);

    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        Category selectedCategory = Category.allCategories.first;

        if (categoryState is CategoriesLoaded) {
          selectedCategory = categoryState.selectedCategory;
        }

        return SizedBox(
          height: CategoryIconsMetrics.heightFor(t),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: UICategory.allCategories.length,
            itemBuilder: (context, index) {
              final uiCategory = UICategory.allCategories[index];
              final bool isActive =
                  selectedCategory.id == uiCategory.category.id;

              return GestureDetector(
                onTap: () {
                  // Sélection visuelle de la catégorie
                  context.read<CategoryBloc>().add(
                    SelectCategory(uiCategory.category),
                  );

                  // FILTRAGE : On envoie bien le .type (Enum BusinessType)
                  context.read<BusinessBloc>().add(
                    LoadBusinessesByCategory(uiCategory.category.type),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? AppDimens.appPaddingValue : 4.0,
                    right: index == UICategory.allCategories.length - 1
                        ? AppDimens.appPaddingValue
                        : 4.0,
                    top: lerpDouble(8.0, 4.0, t)!,
                    bottom: lerpDouble(8.0, 4.0, t)!,
                  ),
                  child: _CategoryChip(
                    uiCategory: uiCategory,
                    isActive: isActive,
                    collapseProgress: t,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Vignette de catégorie capable de se transformer de façon continue entre
/// une disposition en colonne et une disposition en ligne.
///
/// Le morphing ne peut pas être fait en échangeant un `Column` contre un
/// `Row` (ça produirait un saut au moment de la bascule) : l'icône et le
/// libellé sont donc positionnés à la main dans un [Stack], et chaque
/// coordonnée est interpolée entre sa valeur « colonne » et sa valeur
/// « ligne ».
class _CategoryChip extends StatelessWidget {
  final UICategory uiCategory;
  final bool isActive;
  final double collapseProgress;

  const _CategoryChip({
    required this.uiCategory,
    required this.isActive,
    required this.collapseProgress,
  });

  static const double _expandedIconSize = 52;
  static const double _collapsedIconSize = 30;
  static const double _horizontalPadding = 10;
  static const double _iconLabelGap = 8;

  /// Largeur de contenu plancher en disposition colonne, pour que les
  /// libellés courts ("Tout", "Spa") ne produisent pas des vignettes
  /// étriquées à côté des autres.
  static const double _minColumnContentWidth = 65;

  static const Color _inactiveBackground = Color(0xFFF5F7F9);

  /// Mesure du libellé mise en cache : la vignette est reconstruite à
  /// chaque frame de scroll, et sa largeur dépend de celle du texte. Le
  /// texte, lui, ne change jamais — inutile de le remesurer.
  ///
  /// La mesure est faite en gras (le poids le plus large) quel que soit
  /// l'état réel : la largeur de la pastille reste ainsi stable quand on
  /// sélectionne une catégorie, au lieu de sursauter.
  static final Map<String, Size> _labelSizeCache = {};

  /// Mesure le libellé **exactement comme il sera rendu**.
  ///
  /// Mesurer avec le seul [TextStyle] local ne suffit pas : le widget
  /// [Text] fusionne ce style avec le `DefaultTextStyle` ambiant et
  /// applique l'échelle typographique de l'utilisateur. Un [TextPainter]
  /// nourri du style brut sous-estime donc la largeur, et le texte se
  /// retrouve tronqué d'un ou deux pixels.
  static Size _labelSize(
    BuildContext context,
    String label,
    TextStyle style,
  ) {
    final effectiveStyle = DefaultTextStyle.of(
      context,
    ).style.merge(style).copyWith(fontWeight: FontWeight.w700);
    final scaler = MediaQuery.textScalerOf(context);

    final key = '$label|${scaler.scale(effectiveStyle.fontSize ?? 12)}';
    return _labelSizeCache.putIfAbsent(key, () {
      final painter = TextPainter(
        text: TextSpan(text: label, style: effectiveStyle),
        maxLines: 1,
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout();
      // Arrondi au pixel supérieur : une contrainte exactement égale à la
      // largeur mesurée suffit à déclencher l'ellipse au rendu.
      return Size(painter.width.ceilToDouble() + 1, painter.height);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = collapseProgress;
    final label = uiCategory.category.displayName;

    final labelStyle = TextStyle(
      fontSize: 12,
      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
      fontFamily: 'Poppins',
    );
    final labelSize = _labelSize(context, label, labelStyle);

    final iconSize = lerpDouble(_expandedIconSize, _collapsedIconSize, t)!;

    // La largeur est dérivée du contenu réel dans les deux dispositions, au
    // lieu d'être figée à une valeur unique : un libellé long comme
    // « Restaurants » obtient la place qu'il lui faut au lieu d'être
    // comprimé, et la vignette épouse son contenu à chaque instant plutôt
    // que de laisser du vide autour.
    final columnContentWidth = math.max(
      _minColumnContentWidth,
      math.max(_expandedIconSize, labelSize.width),
    );
    final rowContentWidth =
        _collapsedIconSize + _iconLabelGap + labelSize.width;
    final contentWidth = lerpDouble(columnContentWidth, rowContentWidth, t)!;
    final width = contentWidth + _horizontalPadding * 2;

    // La géométrie (largeur, rayon, taille d'icône) est pilotée par le
    // scroll : elle doit suivre le doigt à la frame près, donc aucun
    // widget animé ne doit s'interposer. Seul le changement de sélection
    // est animé, via ce facteur 0→1.
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: isActive ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      builder: (context, selected, _) => Container(
        width: width,
        decoration: BoxDecoration(
          color: Color.lerp(_inactiveBackground, AppColors.white, selected),
          borderRadius: BorderRadius.circular(
            // Le rayon suit la forme : carte arrondie étendue, pastille repliée.
            lerpDouble(
              AppDimens.cardBorderRadius,
              AppDimens.borderRadiusFull,
              t,
            )!,
          ),
          boxShadow: [
            BoxShadow(
              color: uiCategory.color.withValues(alpha: 0.2 * selected),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: uiCategory.color.withValues(alpha: 0.5 * selected),
            width: 1.5,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;

            // Disposition « colonne » : icône centrée en largeur, libellé
            // juste dessous, l'ensemble centré verticalement.
            final columnBlockHeight =
                _expandedIconSize + _iconLabelGap + labelSize.height;
            final columnIconTop = (height - columnBlockHeight) / 2;
            final columnIconLeft =
                _horizontalPadding + (contentWidth - iconSize) / 2;
            final columnLabelTop =
                columnIconTop + _expandedIconSize + _iconLabelGap;
            const columnLabelLeft = _horizontalPadding;
            final columnLabelWidth = contentWidth;

            // Disposition « ligne » : icône collée à gauche, libellé à sa
            // droite, les deux centrés verticalement.
            //
            // Le libellé n'est pas positionné à partir de sa hauteur
            // mesurée — celle-ci dépend des métriques de la police et ne
            // correspond pas exactement à la hauteur rendue, ce qui
            // décalait le texte de quelques pixels par rapport à l'icône.
            // On lui donne toute la hauteur disponible et c'est l'Align
            // qui le centre, donc exactement.
            final rowIconTop = (height - iconSize) / 2;
            const rowIconLeft = _horizontalPadding;
            const rowLabelTop = 0.0;
            const rowLabelLeft =
                _horizontalPadding + _collapsedIconSize + _iconLabelGap;
            final rowLabelWidth = labelSize.width;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: lerpDouble(columnIconTop, rowIconTop, t),
                  left: lerpDouble(columnIconLeft, rowIconLeft, t),
                  child: Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        uiCategory.color.withValues(alpha: 0.12),
                        uiCategory.color,
                        selected,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      uiCategory.icon,
                      color: Color.lerp(
                        uiCategory.color,
                        AppColors.white,
                        selected,
                      ),
                      size: lerpDouble(26, 17, t),
                    ),
                  ),
                ),
                Positioned(
                  top: lerpDouble(columnLabelTop, rowLabelTop, t),
                  left: lerpDouble(columnLabelLeft, rowLabelLeft, t),
                  width: lerpDouble(columnLabelWidth, rowLabelWidth, t),
                  height: lerpDouble(labelSize.height, height, t),
                  child: Align(
                    // Centré sous l'icône en colonne, aligné à gauche et
                    // centré verticalement en ligne.
                    alignment: Alignment.lerp(
                      Alignment.topCenter,
                      Alignment.centerLeft,
                      t,
                    )!,
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: labelStyle.copyWith(
                        color: Color.lerp(
                          AppColors.textSecondary,
                          AppColors.textPrimary,
                          selected,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
