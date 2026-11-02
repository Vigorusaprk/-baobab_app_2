import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/auth/presentation/widgets/password_rules_hint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.silvaTheme,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('vide : aucune règle n\'est satisfaite', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(PasswordRulesHint(controller: controller)));
    expect(find.byIcon(Icons.cancel), findsNWidgets(2));
  });

  testWidgets('mot de passe conforme : toutes les règles sont satisfaites', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'ab12cd34ef');
    await tester.pumpWidget(
      _wrap(PasswordRulesHint(controller: controller, email: 'user@baobab.com')),
    );
    expect(find.byIcon(Icons.check), findsNWidgets(4));
    expect(find.byIcon(Icons.cancel), findsNothing);
  });

  testWidgets('mot de passe sans chiffre : une règle échoue', (tester) async {
    final controller = TextEditingController(text: 'abcdefghij');
    await tester.pumpWidget(_wrap(PasswordRulesHint(controller: controller)));
    expect(find.byIcon(Icons.check), findsNWidgets(3));
    expect(find.byIcon(Icons.cancel), findsNWidgets(1));
  });
}
