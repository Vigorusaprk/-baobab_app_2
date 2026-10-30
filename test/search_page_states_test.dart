import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/explore_cubit.dart';
import 'package:baobabe_0_2/features/home_page/presentation/screens/explore_results.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _screen(ExploreState state, {VoidCallback? onRetry}) => MaterialApp(
  theme: AppTheme.silvaTheme,
  home: Scaffold(
    body: ExploreResults(
      state: state,
      scroll: ScrollController(),
      onRetry: onRetry ?? () {},
      onClearFilters: () {},
    ),
  ),
);

void main() {
  testWidgets('affiche le squelette pendant le chargement', (tester) async {
    await tester.pumpWidget(_screen(const ExploreState()));
    expect(find.byKey(const ValueKey('squelette')), findsOneWidget);
  });

  testWidgets('affiche le message quand la recherche est vide', (tester) async {
    await tester.pumpWidget(
      _screen(const ExploreState(status: ExploreStatus.ready)),
    );
    expect(find.text('Aucun commerce ne correspond'), findsOneWidget);
  });

  testWidgets('l’échec propose Réessayer', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      _screen(
        const ExploreState(status: ExploreStatus.failure),
        onRetry: () => retried = true,
      ),
    );
    await tester.tap(find.text('Réessayer'));
    expect(retried, isTrue);
  });
}
