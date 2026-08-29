import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Le vocabulaire de l'interface, tenu par des tests.
///
/// PRODUCT.md fixe un glossaire — **offre**, **commerçant**, **commerce**,
/// **activités**. Une interface qui emploie deux mots pour une même chose
/// oblige l'utilisateur à deviner s'il s'agit de la même chose.
///
/// Chaque règle ci-dessous vient d'un défaut trouvé dans ce code.

List<File> _dartFiles() => Directory('lib')
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList();

/// Le texte des chaînes littérales, hors commentaires et hors identifiants
/// de code — c'est ce que l'utilisateur lit, pas ce que le programme nomme.
Iterable<String> _userFacingLines() sync* {
  final quoted = RegExp(r"""(?:'([^'\n]{4,})'|"([^"\n]{4,})")""");
  for (final file in _dartFiles()) {
    final relative = file.path.replaceAll(r'\', '/');
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trimLeft();
      if (trimmed.startsWith('//') || trimmed.startsWith('///')) continue;
      if (trimmed.startsWith('import ') || trimmed.startsWith('export ')) {
        continue;
      }
      for (final m in quoted.allMatches(line)) {
        final text = m.group(1) ?? m.group(2) ?? '';
        // On ne juge que ce qui ressemble à une phrase : un identifiant, un
        // chemin ou une clé n'est pas du texte d'interface.
        if (!text.contains(' ')) continue;
        if (text.contains('/') || text.contains('_')) continue;
        yield '$relative:${i + 1}  $text';
      }
    }
  }
}

void main() {
  group('Vocabulaire', () {
    test('l\'interface dit « commerce », jamais « établissement »', () {
      // Les deux mots cohabitaient : « Aucun établissement dans cette
      // catégorie » à un écran, « commerces populaires » à l'autre.
      final found = _userFacingLines()
          .where((l) => l.toLowerCase().contains('établissement'))
          .toList();

      expect(found, isEmpty, reason: found.join('\n'));
    });
  });

  group('Langage interne', () {
    test('aucun texte n\'avoue une fonctionnalité manquante', () {
      // « Profil mis à jour (à implémenter) » confirmait un enregistrement
      // qui n'avait pas eu lieu. Une confirmation ne confirme que ce qui
      // s'est produit.
      final found = _userFacingLines()
          .where(
            (l) =>
                l.contains('à implémenter') ||
                l.contains('TODO') ||
                l.contains('à venir)'),
          )
          .toList();

      expect(found, isEmpty, reason: found.join('\n'));
    });

    test('aucun texte d\'interface en anglais', () {
      // Les erreurs de connexion Google étaient en anglais, et l'une citait
      // « Bicount » — le nom d'un autre produit — sur un écran français.
      const anglicismes = [
        'Please ',
        'failed.',
        'cancelled.',
        'Try again',
        'sign-in',
        'Bicount',
      ];
      final found = _userFacingLines()
          .where((l) => anglicismes.any(l.contains))
          .toList();

      expect(found, isEmpty, reason: found.join('\n'));
    });
  });

  group('Pluriel', () {
    test('aucun ternaire de pluriel dont les deux branches sont identiques', () {
      // `${n > 1 ? 'avis' : 'avis'}` : une règle de pluriel qui ne pluralise
      // rien, donc une intention perdue.
      final pattern = RegExp(r"""\?\s*'(\w+)'\s*:\s*'(\w+)'""");
      final found = <String>[];
      for (final file in _dartFiles()) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          for (final m in pattern.allMatches(lines[i])) {
            if (m.group(1) == m.group(2)) {
              found.add(
                '${file.path.replaceAll(r'\', '/')}:${i + 1}  ${lines[i].trim()}',
              );
            }
          }
        }
      }

      expect(found, isEmpty, reason: found.join('\n'));
    });
  });
}
