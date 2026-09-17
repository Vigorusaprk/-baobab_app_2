import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/filter_sheet_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Une puce de filtre se lit dans les deux états.
///
/// Le thème a un jour résolu le **style** de l'étiquette selon l'état, au
/// lieu de sa couleur : la puce non choisie s'affichait blanc sur blanc, et
/// toute la feuille de filtres était illisible. La puce résout la couleur,
/// pas le style — ce test tient les deux couleurs.
void main() {
  Color labelColor(WidgetTester tester, String label) {
    final style = tester
        .widget<DefaultTextStyle>(
          find
              .ancestor(
                of: find.text(label),
                matching: find.byType(DefaultTextStyle),
              )
              .first,
        )
        .style;
    return style.color!;
  }

  testWidgets('non choisie : sombre sur clair ; choisie : claire sur vert', (
    tester,
  ) async {
    final scheme = AppTheme.silvaTheme.colorScheme;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.silvaTheme,
        home: Scaffold(
          body: Row(
            children: [
              FilterSheetChip(
                label: 'Libre',
                selected: false,
                onSelected: (_) {},
              ),
              FilterSheetChip(
                label: 'Choisie',
                selected: true,
                onSelected: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    final free = labelColor(tester, 'Libre');
    final chosen = labelColor(tester, 'Choisie');

    expect(free, scheme.onSurface);
    expect(free, isNot(Colors.white));
    expect(chosen, scheme.onPrimary);
  });
}
