import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Ce qui doit rester vrai quand l'application rencontre le réel : réseau
/// qui tombe, langue inattendue, doigt qui tape deux fois, texte trop long.
///
/// Ces tests lisent le code plutôt que de le faire tourner. C'est volontaire :
/// les défauts visés sont des **omissions** — un tooltip absent, une
/// exception affichée telle quelle, une initialisation oubliée — et une
/// omission ne se voit pas à l'exécution tant qu'on n'est pas tombé dessus.

const _lib = 'lib';

List<File> _dartFiles() => Directory(_lib)
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList();

Iterable<String> _matches(RegExp pattern) sync* {
  for (final file in _dartFiles()) {
    final relative = file.path.replaceAll(r'\', '/');
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].trimLeft().startsWith('//')) continue;
      if (pattern.hasMatch(lines[i])) yield '$relative:${i + 1}';
    }
  }
}

void main() {
  group('Erreurs', () {
    test('aucune exception brute n\'est montrée à l\'utilisateur', () {
      // `Text('Erreur: $e')` affiche une trace de pile à quelqu'un qui
      // voulait lire un avis. Un message écrit dit ce qui a échoué et ce
      // qu'on peut faire.
      final found = _matches(
        RegExp(r'''Text\(\s*.?['"][^'"]*\$\{?(e|error|snapshot\.error)'''),
      ).toList();

      expect(found, isEmpty, reason: found.join('\n'));
    });
  });

  group('Internationalisation', () {
    test('les données de locale sont chargées au démarrage', () {
      // Sans `initializeDateFormatting`, tout `DateFormat` en français lève
      // `LocaleDataException` — ce qui cassait la fiche d'une offre datée et
      // la boîte de réception du commerçant.
      final main = File('lib/main.dart').readAsStringSync();

      expect(
        main,
        contains('initializeDateFormatting'),
        reason:
            'trois écrans formatent des dates en français ; sans cet appel '
            'ils lèvent au premier affichage.',
      );
    });

    test('une locale que le socle ne sait pas rendre retombe sur le français', () {
      // `ln_CD` n'existe pas dans les locales de Flutter : un téléphone réglé
      // dessus laissait l'application à moitié localisée.
      final app = File('lib/app/main_app.dart').readAsStringSync();

      expect(
        app,
        contains('localeResolutionCallback'),
        reason:
            'sans repli explicite, le sélecteur de date passe en anglais '
            'derrière une interface française.',
      );
    });

    test('aucune largeur figée ne contient du texte traduisible', () {
      // Le produit tient trois langues : une boîte de largeur constante
      // autour d'un libellé finit toujours par le couper.
      final found = _matches(
        RegExp(r'SizedBox\(\s*width:\s*\d+\s*,\s*child:\s*Text\('),
      ).toList();

      expect(found, isEmpty, reason: found.join('\n'));
    });
  });

  group('Promesses tenues', () {
    test('aucun bouton ne mène nulle part', () {
      // `onPressed: () {}` et `onTap: () {}` sont des contrôles décoratifs :
      // ils annoncent une action qui n'existe pas.
      final found = _matches(
        RegExp(r'on(Pressed|Tap|Changed):\s*\(\s*\)\s*\{\s*\}'),
      ).toList();

      expect(
        found,
        isEmpty,
        reason:
            'un contrôle sans effet est une promesse non tenue.\n'
            '${found.join('\n')}',
      );
    });
  });
}
