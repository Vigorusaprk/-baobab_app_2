import 'dart:io';

import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Le thème est la source unique de la couleur et de la typographie.
///
/// Ces tests ne vérifient pas un rendu mais une **règle d'architecture** :
/// tant qu'ils passent, un thème sombre reste faisable en ne touchant que
/// `lib/core/themes/`. Dès qu'un écran nomme une couleur ou une police en
/// dur, ils échouent en le désignant.
const _themeDir = 'lib/core/themes';

/// Fichiers restés hors de la règle, avec la raison. Une exception se
/// justifie ; une liste qui s'allonge signale qu'on a cessé de centraliser.
const _allowed = <String>{};

List<File> _sourceFiles() {
  return Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.replaceAll(r'\', '/').contains(_themeDir))
      .toList();
}

Iterable<String> _offenders(bool Function(String line) isOffending) sync* {
  for (final file in _sourceFiles()) {
    final relative = file.path.replaceAll(r'\', '/');
    if (_allowed.contains(relative)) continue;
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trimLeft().startsWith('//')) continue;
      if (isOffending(line)) yield '$relative:${i + 1}  ${line.trim()}';
    }
  }
}

void main() {
  group('Centralisation du thème', () {
    test('aucun écran ne lit AppColors ou AppFonts', () {
      final found = _offenders(
        (l) => l.contains('AppColors.') || l.contains('AppFonts.'),
      ).toList();

      expect(
        found,
        isEmpty,
        reason:
            'Ces fichiers lisent une primitive au lieu d\'un rôle du thème.\n'
            'Utilisez Theme.of(context).colorScheme / .textTheme, ou '
            'OtherTheme.of(context) pour le succès, l\'attention, la note et '
            'les catégories.\n\n${found.join('\n')}',
      );
    });

    test('aucune couleur littérale dans un écran', () {
      final found = _offenders((l) {
        if (l.contains('Color(0x')) return true;
        // `Colors.transparent` n'est pas une couleur de marque : c'est
        // l'absence de couleur.
        final material = RegExp(r'(^|[^.\w])Colors\.(?!transparent)\w+');
        return material.hasMatch(l);
      }).toList();

      expect(
        found,
        isEmpty,
        reason:
            'Une couleur écrite en dur ne suivra jamais un changement de '
            'thème.\n\n${found.join('\n')}',
      );
    });

    test('aucun TextStyle dimensionné à la main', () {
      // Un `TextStyle` sans `fontSize` hérite du style ambiant : il est déjà
      // piloté par le thème. C'est celui qui impose une taille qui sort de
      // l'échelle.
      final found = _offenders(
        (l) => l.contains('fontSize:') && !l.contains('//'),
      ).toList();

      expect(
        found,
        isEmpty,
        reason:
            'Chaque taille employée a une case dans le TextTheme : prenez '
            'la sienne plutôt que d\'en écrire une.\n\n${found.join('\n')}',
      );
    });
  });

  group('Le thème couvre tous les rôles', () {
    final theme = AppTheme.silvaTheme;

    test('l\'extension des rôles étendus est enregistrée', () {
      expect(
        theme.extension<OtherTheme>(),
        isNotNull,
        reason:
            'OtherTheme.of() lève sans elle : succès, attention, note et '
            'catégories deviendraient introuvables.',
      );
    });

    test('les quinze cases typographiques sont remplies', () {
      final t = theme.textTheme;
      final slots = <String, TextStyle?>{
        'displayLarge': t.displayLarge,
        'displayMedium': t.displayMedium,
        'displaySmall': t.displaySmall,
        'headlineLarge': t.headlineLarge,
        'headlineMedium': t.headlineMedium,
        'headlineSmall': t.headlineSmall,
        'titleLarge': t.titleLarge,
        'titleMedium': t.titleMedium,
        'titleSmall': t.titleSmall,
        'bodyLarge': t.bodyLarge,
        'bodyMedium': t.bodyMedium,
        'bodySmall': t.bodySmall,
        'labelLarge': t.labelLarge,
        'labelMedium': t.labelMedium,
        'labelSmall': t.labelSmall,
      };

      for (final entry in slots.entries) {
        final style = entry.value;
        expect(
          style,
          isNotNull,
          reason:
              '${entry.key} est vide : un écran qui la demande retomberait '
              'sur la police par défaut de Flutter.',
        );
        expect(
          style!.fontSize,
          isNotNull,
          reason: '${entry.key} n\'a pas de taille.',
        );
        expect(
          style.color,
          isNotNull,
          reason: '${entry.key} n\'a pas de couleur.',
        );
      }
    });

    test('un second thème se fabrique sans toucher aux écrans', () {
      // Ce que ferait un mode sombre : composer un autre couple
      // (ColorScheme, OtherTheme). Si cette forme cesse de compiler, la
      // promesse de centralisation est rompue.
      final other = theme.extension<OtherTheme>()!;
      final swapped = other.copyWith(warning: const Color(0xFF000000));

      expect(swapped.warning, const Color(0xFF000000));
      expect(
        swapped.success,
        other.success,
        reason: 'copyWith ne doit toucher que ce qu\'on lui donne.',
      );
      expect(other.lerp(swapped, 1).warning, const Color(0xFF000000));
    });
  });
}
