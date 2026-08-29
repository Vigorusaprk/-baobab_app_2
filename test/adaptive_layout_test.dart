import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/core/widgets/adaptive_viewport.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/category_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/category_repository.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/home_sliver_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Une même application doit tenir du téléphone au bureau, dans trois langues
/// et à l'échelle de police que l'utilisateur a choisie.
///
/// Ces tests mesurent, ils ne regardent pas.
///
/// Note sur la typographie en test : le moteur de test remplace la police par
/// une fonte à chasse fixe. Les largeurs de texte n'y valent donc rien —
/// d'où des assertions portant sur le **débordement** et sur la **réaction à
/// l'échelle**, pas sur des tailles absolues.

Future<void> _pumpAt(
  WidgetTester tester,
  Widget home, {
  required Size size,
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.silvaTheme,
      builder: (context, child) => AdaptiveViewport(child: child!),
      home: home,
    ),
  );
}

/// Un faux bloc de catégories : l'en-tête en dépend, mais ce n'est pas lui
/// qu'on mesure ici.
class _IdleCategoryBloc extends CategoryBloc {
  _IdleCategoryBloc() : super(categoryRepository: _NoCategories());
}

class _NoCategories implements CategoryRepository {
  @override
  Future<List<Category>> getCategories() async => Category.fallback;

  @override
  Future<Category> getCategoryByType(BusinessType type) async => Category.all;
}

void main() {
  group('AdaptiveViewport', () {
    testWidgets('sur un téléphone, il ne s\'interpose pas', (tester) async {
      late double seen;
      await _pumpAt(
        tester,
        Builder(
          builder: (context) {
            seen = MediaQuery.of(context).size.width;
            return const SizedBox.shrink();
          },
        ),
        size: const Size(375, 812),
      );

      expect(seen, 375);
    });

    testWidgets('sur un écran large, le contenu tient dans une colonne', (
      tester,
    ) async {
      await _pumpAt(
        tester,
        const Scaffold(body: SizedBox.expand()),
        size: const Size(1400, 900),
      );

      expect(
        tester.getSize(find.byType(Scaffold)).width,
        AdaptiveViewport.maxWidth,
        reason:
            'étirée sur 1400 px, une ligne de commerçant traverserait tout '
            'l\'écran et une description se lirait sur trente mots de large.',
      );
    });

    testWidgets(
      'ce qui mesure la largeur voit celle de la colonne, pas de la fenêtre',
      (tester) async {
        late double seen;
        await _pumpAt(
          tester,
          Builder(
            builder: (context) {
              seen = MediaQuery.of(context).size.width;
              return const SizedBox.shrink();
            },
          ),
          size: const Size(1400, 900),
        );

        expect(
          seen,
          AdaptiveViewport.maxWidth,
          reason:
              'sinon l\'application se croit sur un écran large tout en '
              'n\'occupant qu\'une bande.',
        );
      },
    );
  });

  group('En-tête de l\'accueil', () {
    Widget header() {
      return BlocProvider<CategoryBloc>(
        create: (_) => _IdleCategoryBloc(),
        child: const Scaffold(
          body: CustomScrollView(slivers: [HomeSliverHeader()]),
        ),
      );
    }

    /// Le défaut d'origine : la hauteur du bloc valait 58 px en dur, donc la
    /// question était coupée par une ellipse dès 375 px — et l'aurait été
    /// partout une fois traduite en lingala.
    for (final size in [
      const Size(320, 700),
      const Size(375, 812),
      const Size(560, 900),
      const Size(1400, 900),
    ]) {
      testWidgets('ne déborde pas en ${size.width.toInt()} px', (
        tester,
      ) async {
        await _pumpAt(tester, header(), size: size);
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('ne déborde pas non plus à 160 % de police', (tester) async {
      await _pumpAt(
        tester,
        header(),
        size: const Size(375, 812),
        textScale: 1.6,
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('la hauteur réservée suit l\'échelle de police', (
      tester,
    ) async {
      Future<double> measure(double scale) async {
        late double height;
        await _pumpAt(
          tester,
          Builder(
            builder: (context) {
              height = HomeSliverHeaderMetrics.greetingHeight(context);
              return const SizedBox.shrink();
            },
          ),
          size: const Size(375, 812),
          textScale: scale,
        );
        return height;
      }

      final normal = await measure(1.0);
      final large = await measure(1.6);

      expect(
        large,
        greaterThan(normal),
        reason:
            'une hauteur figée aurait tronqué le texte de l\'utilisateur qui '
            'agrandit sa police.',
      );
    });

    testWidgets('le repliement couvre la salutation et les catégories', (
      tester,
    ) async {
      late double greeting;
      late double range;
      await _pumpAt(
        tester,
        Builder(
          builder: (context) {
            greeting = HomeSliverHeaderMetrics.greetingHeight(context);
            range = HomeSliverHeaderMetrics.collapseRange(context);
            return const SizedBox.shrink();
          },
        ),
        size: const Size(375, 812),
      );

      expect(range, greaterThan(greeting));
    });
  });

  group('Cibles tactiles', () {
    test('le jeton vaut le minimum de Material', () {
      expect(AppDimens.touchTarget, 48.0);
    });
  });
}
