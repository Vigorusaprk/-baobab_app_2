import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/features/auth/presentation/widgets/set_password_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.silvaTheme,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('rend le champ mot de passe, la confirmation et le bouton', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(SetPasswordForm(onSubmit: _submit)));
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Définir le mot de passe'), findsOneWidget);
  });

  testWidgets('le bouton est inactif tant que le mot de passe est invalide', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(SetPasswordForm(onSubmit: _submit)));
    final button = tester.widget<CustomButton>(find.byType(CustomButton));
    expect(button.isActive, isFalse);
  });

  testWidgets('le bouton s\'active et soumet quand le couple est valide', (
    tester,
  ) async {
    var submittedPassword = '';
    await tester.pumpWidget(
      _wrap(SetPasswordForm(onSubmit: (password) => submittedPassword = password)),
    );
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'ab12cd34ef');
    await tester.pump();
    await tester.enterText(fields.at(1), 'ab12cd34ef');
    await tester.pump();
    final button = tester.widget<CustomButton>(find.byType(CustomButton));
    expect(button.isActive, isTrue);
    await tester.tap(find.byType(CustomButton));
    await tester.pump();
    expect(submittedPassword, 'ab12cd34ef');
  });

  testWidgets('affiche l\'erreur', (tester) async {
    await tester.pumpWidget(
      _wrap(
        SetPasswordForm(
          onSubmit: _submit,
          error: 'Le mot de passe est trop faible.',
        ),
      ),
    );
    expect(find.text('Le mot de passe est trop faible.'), findsOneWidget);
  });
}

void _submit(String _) {}
