import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/home_page/presentation/screens/discover_ad_preview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('signale l’aperçu fictif et permet de le passer', (tester) async {
    var skipped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.silvaTheme,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 500,
              child: DiscoverAdPreviewCard(onSkip: () => skipped = true),
            ),
          ),
        ),
      ),
    );

    expect(find.text('APERÇU FICTIF'), findsOneWidget);
    expect(find.text('Commerce de démonstration'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.bySemanticsLabel('Passer l’aperçu publicitaire'));
    expect(skipped, isTrue);
  });
}
