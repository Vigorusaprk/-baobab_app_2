import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/category_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/category_repository.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/Category_Icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Vérifie la promesse centrale du passage des catégories au back : une
/// catégorie créée en base, dont l'application n'a jamais entendu parler à
/// la compilation, doit s'afficher et filtrer correctement — sans publier
/// de nouvelle version.
class _ServerCategories implements CategoryRepository {
  _ServerCategories(this.categories);
  final List<Category> categories;

  @override
  Future<List<Category>> getCategories() async => categories;

  @override
  Future<Category> getCategoryByType(BusinessType type) async => Category.all;
}

void main() {
  // Une catégorie totalement absente de l'énumération BusinessType.
  const inedite = Category(
    id: 'x1',
    slug: 'pharmacie',
    displayName: 'Pharmacies',
    icon: 'medical_services',
    color: '0xFF10B981',
    sortOrder: 5,
  );

  Widget harness(
    List<Category> serverCategories, {
    ValueChanged<String>? onSelected,
    String? selectedSlug,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider(
          create: (_) => CategoryBloc(
            categoryRepository: _ServerCategories(serverCategories),
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: CategoryIcons(
              selectedSlug: selectedSlug,
              onCategorySelected: onSelected,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('une catégorie inconnue de l\'app s\'affiche quand même', (
    tester,
  ) async {
    await tester.pumpWidget(harness([inedite]));
    await tester.pumpAndSettle();

    expect(find.text('Pharmacies'), findsOneWidget);
    // "Tout" est ajouté côté client : ce n'est pas une catégorie de commerce
    // mais l'absence de filtre, elle ne vient donc pas du serveur.
    expect(find.text('Tout'), findsOneWidget);
  });

  testWidgets('la sélectionner remonte son slug, pas une valeur d\'enum', (
    tester,
  ) async {
    String? recu;
    await tester.pumpWidget(harness([inedite], onSelected: (s) => recu = s));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pharmacies'));
    await tester.pumpAndSettle();

    expect(recu, 'pharmacie');
  });

  testWidgets('le serveur fait autorité sur l\'ordre et les libellés', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(const [
        Category(
          id: 'a',
          slug: 'event',
          displayName: 'Concerts',
          icon: 'celebration',
          color: '0xFFF04452',
          sortOrder: 1,
        ),
        Category(
          id: 'b',
          slug: 'cosmetics',
          displayName: 'Beauté',
          icon: 'auto_awesome',
          color: '0xFFEC4899',
          sortOrder: 2,
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Concerts'), findsOneWidget);
    expect(find.text('Beauté'), findsOneWidget);
    // Aucune trace de la liste historique codée en dur.
    expect(find.text('Restaurants'), findsNothing);
  });

  test('un slug inconnu retombe proprement sur BusinessType.other', () {
    expect(inedite.type, BusinessType.other);
    // Le slug, lui, reste intact : c'est lui qui sert à filtrer.
    expect(inedite.slug, 'pharmacie');
  });

  test('le libellé d\'écran se résout depuis la liste du serveur', () {
    expect(Category.displayNameForSlug('pharmacie', [inedite]), 'Pharmacies');
    expect(
      Category.displayNameForSlug('all', [inedite]),
      'Tous les établissements',
    );
  });
}
