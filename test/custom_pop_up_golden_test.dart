@Tags(['golden'])
library;

import 'dart:io';

import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/core/widgets/custom_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rend la fenêtre de confirmation en image, avec les vraies polices.
///
/// Les tests de widget utilisent normalement une police de substitution qui
/// dessine des rectangles : une capture n'y montrerait rien. On charge donc
/// Poppins depuis `assets/` avant de peindre.
///
/// Lancer `flutter test --update-goldens test/custom_pop_up_golden_test.dart`
/// régénère les images de `test/goldens/`.

Future<void> _loadPoppins() async {
  for (final entry in {
    'Poppins': ['assets/Poppins/Poppins-Regular.ttf'],
    'Poppins-Bold': ['assets/Poppins/Poppins-Bold.ttf'],
  }.entries) {
    final loader = FontLoader(entry.key);
    for (final path in entry.value) {
      loader.addFont(
        File(path).readAsBytes().then((b) => ByteData.view(b.buffer)),
      );
    }
    await loader.load();
  }
}

void main() {
  setUpAll(_loadPoppins);

  testWidgets('annuler une commande', (tester) async {
    // Un vrai gabarit de téléphone (390x844 logiques), pour que la
    // capture montre ce que l'utilisateur voit.
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.silvaTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showCustomPopUp(
                context: context,
                title: 'Voulez-vous vraiment annuler votre commande ?',
                message:
                    'Votre commande chez Mama Africa Resto sera annulée. '
                    'Vous pourrez en passer une nouvelle quand vous voulez.',
              ),
              child: const Text('ouvrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(AlertDialog),
      matchesGoldenFile('goldens/pop_up_annuler_commande.png'),
    );
  });

  testWidgets('se déconnecter — avec pictogramme', (tester) async {
    // Un vrai gabarit de téléphone (390x844 logiques), pour que la
    // capture montre ce que l'utilisateur voit.
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.silvaTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showCustomPopUp(
                context: context,
                title: 'Voulez-vous vraiment vous déconnecter ?',
                message:
                    'Vous devrez vous reconnecter pour retrouver vos '
                    'commandes et vos réservations. À bientôt !',
                icon: Icons.logout_rounded,
              ),
              child: const Text('ouvrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(AlertDialog),
      matchesGoldenFile('goldens/pop_up_deconnexion.png'),
    );
  });
}
