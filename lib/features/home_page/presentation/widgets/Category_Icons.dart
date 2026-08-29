import 'dart:ui' show lerpDouble;

import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/category_chip.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_category.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/category_entity.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:flutter/material.dart';
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

  /// Slug de la catégorie mise en avant. Laisser à null pour lire la
  /// sélection dans le [CategoryBloc] ambiant (cas de l'accueil).
  final String? selectedSlug;

  /// Appelé quand l'utilisateur choisit une catégorie, avec son slug.
  ///
  /// Laisser à null pour le comportement de l'accueil : la sélection est
  /// propagée au [CategoryBloc] et le flux est rechargé via [BusinessBloc].
  /// Tout écran qui affiche ses propres données doit fournir ce callback,
  /// sinon la bande piloterait un état qui n'est pas le sien.
  final ValueChanged<String>? onCategorySelected;

  const CategoryIcons({
    super.key,
    this.collapseProgress = 0,
    this.selectedSlug,
    this.onCategorySelected,
  });

  void _handleTap(BuildContext context, Category category) {
    final custom = onCategorySelected;
    if (custom != null) {
      custom(category.slug);
      return;
    }
    context.read<CategoryBloc>().add(SelectCategory(category));
    context.read<BusinessBloc>().add(LoadBusinessesBySlug(category.slug));
  }

  @override
  Widget build(BuildContext context) {
    // La liste vient du serveur : une catégorie ajoutée en base apparaît
    // sans publier de version. "Tout" est ajouté côté client, ce n'est pas
    // une catégorie de commerce mais l'absence de filtre.
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        final loaded = categoryState is CategoriesLoaded
            ? categoryState.categories
            : Category.fallback;
        final categories = [Category.all, ...loaded];

        final selected = selectedSlug != null
            ? categories.firstWhere(
                (c) => c.slug == selectedSlug,
                orElse: () => Category.all,
              )
            : (categoryState is CategoriesLoaded
                  ? categoryState.selectedCategory
                  : Category.all);

        return _band(context, categories, selected);
      },
    );
  }

  Widget _band(
    BuildContext context,
    List<Category> categories,
    Category selectedCategory,
  ) {
    final t = collapseProgress.clamp(0.0, 1.0);
    return SizedBox(
      height: CategoryIconsMetrics.heightFor(t),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final uiCategory = UICategory(categories[index]);
          final bool isActive =
              selectedCategory.slug == uiCategory.category.slug;

          return GestureDetector(
            onTap: () => _handleTap(context, uiCategory.category),
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? AppDimens.appPaddingValue : 4.0,
                right: index == categories.length - 1
                    ? AppDimens.appPaddingValue
                    : 4.0,
                top: lerpDouble(8.0, 4.0, t)!,
                bottom: lerpDouble(8.0, 4.0, t)!,
              ),
              child: CategoryChip(
                uiCategory: uiCategory,
                isActive: isActive,
                collapseProgress: t,
              ),
            ),
          );
        },
      ),
    );
  }
}
