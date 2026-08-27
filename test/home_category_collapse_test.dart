import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/category_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/category_repository.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/Category_Icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Vérifie le repliement de la bande de catégories piloté par l'en-tête
/// collant de l'accueil : passage continu d'une vignette en colonne
/// (icône au-dessus du libellé) à une pastille en ligne (icône à gauche
/// du libellé), sans saut ni débordement.
/// Dépôt factice : les catégories viennent normalement du serveur, mais ce
/// test porte sur la géométrie de la bande, pas sur le réseau.
class _FakeCategoryRepository implements CategoryRepository {
  @override
  Future<List<Category>> getCategories() async => Category.fallback;

  @override
  Future<Category> getCategoryByType(BusinessType type) async => Category.all;
}

void main() {
  Widget harness(double collapseProgress) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider(
          create: (_) => CategoryBloc(categoryRepository: _FakeCategoryRepository()),
          child: Align(
            alignment: Alignment.topLeft,
            child: CategoryIcons(collapseProgress: collapseProgress),
          ),
        ),
      ),
    );
  }

  /// Position de l'icône et du libellé de la première catégorie.
  ({Offset icon, Offset label}) firstChipGeometry(WidgetTester tester) {
    final icon = tester.getCenter(find.byType(Icon).first);
    final label = tester.getCenter(find.byType(Text).first);
    return (icon: icon, label: label);
  }

  testWidgets('étendu : la bande fait sa hauteur pleine et le libellé est '
      'sous l\'icône', (tester) async {
    await tester.pumpWidget(harness(0));
    await tester.pumpAndSettle();

    final band = tester.getSize(find.byType(CategoryIcons));
    expect(band.height, CategoryIconsMetrics.expandedHeight);

    final g = firstChipGeometry(tester);
    expect(
      g.label.dy,
      greaterThan(g.icon.dy),
      reason: 'le libellé doit être sous l\'icône (disposition colonne)',
    );
    expect(
      (g.label.dx - g.icon.dx).abs(),
      lessThan(2),
      reason: 'icône et libellé doivent être alignés horizontalement',
    );
  });

  testWidgets('replié : la bande est raccourcie et le libellé passe à droite '
      'de l\'icône', (tester) async {
    await tester.pumpWidget(harness(1));
    await tester.pumpAndSettle();

    final band = tester.getSize(find.byType(CategoryIcons));
    expect(band.height, CategoryIconsMetrics.collapsedHeight);
    expect(
      CategoryIconsMetrics.collapsedHeight,
      lessThan(CategoryIconsMetrics.expandedHeight),
    );

    final g = firstChipGeometry(tester);
    expect(
      g.label.dx,
      greaterThan(g.icon.dx),
      reason: 'le libellé doit être à droite de l\'icône (disposition ligne)',
    );
    expect(
      (g.label.dy - g.icon.dy).abs(),
      lessThan(2),
      reason: 'icône et libellé doivent être centrés verticalement ensemble',
    );
  });

  /// Largeur rendue de la vignette portant [label].
  double chipWidth(WidgetTester tester, String label) {
    final stack = find
        .ancestor(of: find.text(label), matching: find.byType(Stack))
        .first;
    return tester.getSize(stack).width;
  }

  testWidgets('le libellé n\'est jamais tronqué, quelle que soit sa longueur', (
    tester,
  ) async {
    for (final t in [0.0, 1.0]) {
      await tester.pumpWidget(harness(t));
      await tester.pumpAndSettle();

      for (final label in ['Tout', 'Restaurants', 'Fast Food']) {
        final paragraph = tester.renderObject<RenderParagraph>(
          find.text(label),
        );
        expect(
          paragraph.didExceedMaxLines,
          isFalse,
          reason: '"$label" est tronqué à collapseProgress=$t',
        );
      }
    }
  });

  testWidgets('la vignette épouse la largeur de son libellé', (tester) async {
    // Replié : la pastille est dimensionnée sur son contenu, donc un
    // libellé long occupe plus de place qu'un libellé court.
    await tester.pumpWidget(harness(1));
    await tester.pumpAndSettle();
    expect(
      chipWidth(tester, 'Restaurants'),
      greaterThan(chipWidth(tester, 'Tout')),
    );

    // Étendu : un libellé long ne doit pas être comprimé dans la même
    // largeur qu'un libellé court — c'était le défaut d'une largeur figée.
    await tester.pumpWidget(harness(0));
    await tester.pumpAndSettle();
    expect(
      chipWidth(tester, 'Restaurants'),
      greaterThanOrEqualTo(chipWidth(tester, 'Tout')),
    );
  });

  testWidgets('la transition est continue et ne déborde jamais', (tester) async {
    Offset? previousLabel;

    for (final t in [0.0, 0.25, 0.5, 0.75, 1.0]) {
      await tester.pumpWidget(harness(t));
      await tester.pumpAndSettle();

      // Aucun débordement de rendu à aucune étape intermédiaire.
      expect(
        tester.takeException(),
        isNull,
        reason: 'rendu en échec à collapseProgress=$t',
      );

      expect(
        tester.getSize(find.byType(CategoryIcons)).height,
        CategoryIconsMetrics.heightFor(t),
      );

      // Le libellé se déplace de façon monotone vers la droite : preuve que
      // le morphing est bien interpolé et non basculé d'un coup.
      final label = tester.getCenter(find.byType(Text).first);
      if (previousLabel != null) {
        expect(
          label.dx,
          greaterThan(previousLabel.dx),
          reason: 'le libellé doit glisser progressivement, pas sauter',
        );
      }
      previousLabel = label;
    }
  });
}
