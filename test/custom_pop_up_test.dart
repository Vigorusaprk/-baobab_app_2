import 'dart:io';

import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/core/widgets/custom_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// La fenêtre de confirmation de l'application.
///
/// Deux gabarits cohabitaient avant : l'écran d'activité posait un bouton
/// texte rouge, la déconnexion un bouton plein rouge, et chacun réécrivait
/// ses libellés. Ces tests tiennent le modèle unique et, surtout, la réponse
/// qu'il rend — c'est elle qui décide si on supprime.

/// Recueille la réponse de la fenêtre. `valeur` reste `null` tant que la
/// question n'a pas été tranchée — c'est justement ce qu'on veut pouvoir
/// distinguer d'un « non ».
class _Reponse {
  bool? valeur;
}

/// Ouvre la fenêtre et rend le recueil de sa réponse.
Future<_Reponse> _ask(WidgetTester tester, {PopUpIntent? intent}) async {
  final reponse = _Reponse();
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.silvaTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              reponse.valeur = await showCustomPopUp(
                context: context,
                title: 'Voulez-vous vraiment annuler votre réservation ?',
                message:
                    'Votre réservation chez Chez Nadine sera supprimée. '
                    'Vous pourrez réserver à nouveau quand vous voulez.',
                intent: intent ?? PopUpIntent.destructive,
              );
            },
            child: const Text('ouvrir'),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('ouvrir'));
  await tester.pumpAndSettle();
  return reponse;
}

void main() {
  group('La réponse rendue', () {
    testWidgets('la question et sa conséquence sont toutes deux lisibles', (
      tester,
    ) async {
      await _ask(tester);

      expect(
        find.text('Voulez-vous vraiment annuler votre réservation ?'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Vous pourrez réserver à nouveau'),
        findsOneWidget,
      );
      // La précision est dans la question ; les boutons restent courts.
      expect(find.widgetWithText(FilledButton, 'Confirmer'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Retour'), findsOneWidget);
    });

    testWidgets('confirmer rend vrai', (tester) async {
      final reponse = await _ask(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Confirmer'));
      await tester.pumpAndSettle();

      expect(reponse.valeur, isTrue);
    });

    testWidgets('annuler rend faux, pas null', (tester) async {
      final reponse = await _ask(tester);

      await tester.tap(find.text('Retour'));
      await tester.pumpAndSettle();

      expect(reponse.valeur, isFalse);
    });

    testWidgets('fermer d\'un retour arrière vaut « non »', (tester) async {
      // Le piège que le modèle referme : `showDialog` rend `null` quand on
      // sort sans choisir. Un `null` remonté tel quel se lit « faux » dans un
      // `if`, mais « vrai » dans un `!= false` — soit une suppression que
      // personne n'a demandée.
      final reponse = await _ask(tester);

      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();

      expect(reponse.valeur, isFalse);
      expect(reponse.valeur, isNotNull);
    });
  });

  group('Les deux boutons sur une ligne', () {
    testWidgets('« Retour » et « Confirmer » partagent la même ligne', (
      tester,
    ) async {
      await _ask(tester);

      final retour = tester.getRect(find.widgetWithText(TextButton, 'Retour'));
      final confirmer = tester.getRect(
        find.widgetWithText(FilledButton, 'Confirmer'),
      );

      // Même hauteur de centre : ils sont côte à côte, pas empilés.
      expect(retour.center.dy, moreOrLessEquals(confirmer.center.dy));
      // Et « Retour » est bien à gauche.
      expect(retour.right, lessThanOrEqualTo(confirmer.left));
    });

    testWidgets('un libellé long ne les renvoie pas à la ligne', (
      tester,
    ) async {
      // C'est le défaut d'origine : « Annuler la commande » face à
      // « Annuler » débordait, et `OverflowBar` empilait les deux boutons.
      // Ils se partagent désormais la largeur à parts égales.
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.silvaTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showCustomPopUp(
                  context: context,
                  title: 'Voulez-vous vraiment annuler votre commande ?',
                  message: 'Votre commande sera annulée.',
                  cancelLabel: 'Revenir en arrière sans rien changer',
                  confirmLabel: 'Oui, annuler définitivement ma commande',
                ),
                child: const Text('ouvrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('ouvrir'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      final gauche = tester.getRect(find.byType(TextButton));
      final droite = tester.getRect(find.byType(FilledButton));
      expect(gauche.center.dy, moreOrLessEquals(droite.center.dy));
      // Parts égales : ni l'un ni l'autre n'écrase son voisin.
      expect(gauche.width, moreOrLessEquals(droite.width, epsilon: 1));
    });
  });

  group('Le texte tient', () {
    testWidgets('un fort agrandissement du texte ne coupe pas le message', (
      tester,
    ) async {
      // La zone de contenu d'`AlertDialog` ne défile pas d'elle-même : à
      // 2× la fin du message disparaissait sans que rien ne le signale.
      tester.view.physicalSize = const Size(400, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.silvaTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showCustomPopUp(
                  context: context,
                  title: 'Voulez-vous vraiment vous déconnecter ?',
                  message:
                      'Vous devrez vous reconnecter pour retrouver vos '
                      'commandes et vos réservations. À bientôt !',
                ),
                child: const Text('ouvrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('ouvrir'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Les boutons restent atteignables : c'est le message qui défile.
      expect(find.widgetWithText(FilledButton, 'Confirmer'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Retour'), findsOneWidget);
    });
  });

  group('L\'intention se lit', () {
    testWidgets('une action destructrice porte la couleur d\'alerte', (
      tester,
    ) async {
      await _ask(tester, intent: PopUpIntent.destructive);

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      final background = button.style?.backgroundColor?.resolve({});
      expect(background, AppTheme.silvaTheme.colorScheme.error);
    });

    testWidgets('une confirmation ordinaire porte la couleur d\'action', (
      tester,
    ) async {
      await _ask(tester, intent: PopUpIntent.neutral);

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      final background = button.style?.backgroundColor?.resolve({});
      expect(background, AppTheme.silvaTheme.colorScheme.primary);
    });
  });

  group('Centralisation', () {
    test('aucun écran ne rebâtit sa propre fenêtre de confirmation', () {
      // Le but de `custom_pop_up.dart` : une seule fenêtre à corriger quand
      // la règle change. Un `AlertDialog` posé dans un écran la contourne.
      //
      // Seule exception, nommée ici plutôt que tolérée en silence : le
      // sélecteur de langue, qui n'est pas une confirmation mais un choix
      // entre plusieurs options.
      const autorises = {
        'lib/core/widgets/custom_pop_up.dart',
        'lib/features/settings/presentation/widgets/language_picker_dialog.dart',
      };

      final fautifs = <String>[];
      final fichiers = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in fichiers) {
        final relative = file.path.replaceAll(r'\', '/');
        if (autorises.contains(relative)) continue;
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.trimLeft().startsWith('//')) continue;
          if (line.contains('AlertDialog(') ||
              line.contains('CupertinoAlertDialog(')) {
            fautifs.add('$relative:${i + 1}');
          }
        }
      }

      expect(
        fautifs,
        isEmpty,
        reason:
            'passez par showCustomPopUp() : une confirmation doit se '
            'présenter partout de la même façon.\n${fautifs.join('\n')}',
      );
    });
  });
}
