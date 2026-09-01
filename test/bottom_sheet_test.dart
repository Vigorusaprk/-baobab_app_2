import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/core/widgets/custom_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// La feuille modale partagée.
///
/// Deux défauts se voyaient à l'usage et n'étaient tenus par rien :
///
/// - le clic à l'extérieur ne fermait pas. Le voile flouté couvrait tout
///   l'écran, et un `Container` coloré est opaque au test de contact même
///   quand sa couleur est transparente : il avalait la touche avant qu'elle
///   n'atteigne la barrière de la route ;
/// - la feuille ne remontait pas au-dessus du clavier. Les métriques étaient
///   lues sur le contexte **appelant**, avant l'ouverture de la route, où
///   `viewInsets` vaut toujours zéro.
///
/// Ces deux tests les tiennent.

Widget _host({
  String? title,
  VoidCallback? onBack,
  bool showCloseButton = true,
}) => MaterialApp(
  theme: AppTheme.silvaTheme,
  home: Scaffold(
    body: Builder(
      builder: (context) => Center(
        child: TextButton(
          onPressed: () => showCustomBottomSheet<void>(
            context: context,
            title: title,
            onBack: onBack,
            showCloseButton: showCloseButton,
            child: const SizedBox(height: 120, child: Text('contenu')),
          ),
          child: const Text('ouvrir'),
        ),
      ),
    ),
  ),
);

Future<void> _open(WidgetTester tester, Widget host) async {
  await tester.pumpWidget(host);
  await tester.tap(find.text('ouvrir'));
  await tester.pumpAndSettle();
  expect(find.text('contenu'), findsOneWidget);
}

void main() {
  testWidgets('un clic à l\'extérieur ferme la feuille', (tester) async {
    await _open(tester, _host());

    // En haut de l'écran : au-dessus de la feuille, donc sur la barrière.
    await tester.tapAt(const Offset(200, 40));
    await tester.pumpAndSettle();

    expect(find.text('contenu'), findsNothing);
  });

  testWidgets('la croix ferme la feuille', (tester) async {
    await _open(tester, _host());

    await tester.tap(find.byTooltip('Fermer'));
    await tester.pumpAndSettle();

    expect(find.text('contenu'), findsNothing);
  });

  testWidgets('la croix peut être retirée', (tester) async {
    await _open(tester, _host(showCloseButton: false));
    expect(find.byTooltip('Fermer'), findsNothing);
  });

  testWidgets('le clavier pousse la feuille au lieu de la recouvrir', (
    tester,
  ) async {
    const clavier = 300.0;
    // Le clavier se déclare sur la **vue**, comme le fait le système : la
    // feuille vit dans l'overlay du navigateur, au-dessus de tout
    // `MediaQuery` qu'un test poserait autour de la page appelante.
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    tester.view.viewInsets = const FakeViewPadding(bottom: clavier);
    addTearDown(tester.view.reset);

    await _open(tester, _host());

    final bas = tester.getRect(find.text('contenu')).bottom;
    const ecran = 800.0;

    // Le contenu tient au-dessus de la zone occupée par le clavier. Il
    // s'arrêtait auparavant en bas de l'écran, donc dessous.
    expect(
      bas,
      lessThan(ecran - clavier),
      reason: 'la feuille reste sous le clavier',
    );
  });

  testWidgets('l\'en-tête porte le titre et le retour', (tester) async {
    var revenu = false;
    await _open(
      tester,
      _host(title: 'Adresse e-mail', onBack: () => revenu = true),
    );

    expect(find.text('Adresse e-mail'), findsOneWidget);
    await tester.tap(find.byTooltip('Étape précédente'));
    expect(revenu, isTrue);
  });

  testWidgets('sans retour, la flèche n\'est pas là', (tester) async {
    await _open(tester, _host(title: 'Adresse e-mail'));
    expect(find.byTooltip('Étape précédente'), findsNothing);
  });
}
