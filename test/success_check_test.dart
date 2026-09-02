import 'package:baobabe_0_2/core/animation/success_check.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/core/widgets/otp_code_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deux composants partagés, et la promesse de chacun.

Widget _app(Widget child, {bool reduceMotion = false}) => MaterialApp(
  theme: AppTheme.silvaTheme,
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  group('La coche de réussite', () {
    testWidgets('prévient quand elle a fini', (tester) async {
      // C'est cette annonce qui permet d'enchaîner — refermer la feuille de
      // connexion — sans qu'un appelant recopie la durée de l'animation.
      var fini = false;
      await tester.pumpWidget(
        _app(SuccessCheck(onFinished: () => fini = true)),
      );

      expect(fini, isFalse, reason: 'annoncé avant même d\'avoir commencé');
      await tester.pumpAndSettle();
      expect(fini, isTrue);
    });

    testWidgets('mouvement réduit : pas d\'attente imposée', (tester) async {
      // Le réglage existe pour les personnes que le mouvement gêne. Il ne
      // doit pas leur coûter une seconde d'immobilité.
      var fini = false;
      await tester.pumpWidget(
        _app(SuccessCheck(onFinished: () => fini = true), reduceMotion: true),
      );

      expect(fini, isTrue);
    });
  });

  group('Les cases du code', () {
    testWidgets('la case et son contour font la même hauteur', (tester) async {
      // Le défaut d'origine : le contour était dessiné par le décorateur du
      // champ, qui — en mode dense et sans remplissage — calcule une hauteur
      // bien inférieure à la case. On voyait donc un contour en pastille
      // posé sur un bloc blanc plus haut.
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 360,
            child: OtpCodeField(
              controller: TextEditingController(),
              autofocus: false,
            ),
          ),
        ),
      );

      final cases = find.descendant(
        of: find.byType(OtpCodeField),
        matching: find.byType(AnimatedContainer),
      );
      expect(cases, findsNWidgets(6));
      for (var i = 0; i < 6; i++) {
        expect(tester.getSize(cases.at(i)).height, AppDimens.otpBoxHeight);
      }

      // Et le champ ne dessine plus aucune bordure : la case est seule à en
      // porter une.
      for (final field in tester.widgetList<TextField>(
        find.descendant(
          of: find.byType(OtpCodeField),
          matching: find.byType(TextField),
        ),
      )) {
        expect(field.decoration?.border, InputBorder.none);
        expect(field.decoration?.focusedBorder, InputBorder.none);
      }
    });

    testWidgets('les six cases se partagent la largeur', (tester) async {
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 360,
            child: OtpCodeField(
              controller: TextEditingController(),
              autofocus: false,
            ),
          ),
        ),
      );

      final cases = find.descendant(
        of: find.byType(OtpCodeField),
        matching: find.byType(AnimatedContainer),
      );
      final premiere = tester.getSize(cases.at(0)).width;

      // Une largeur en dur déborderait sur un écran de 360 px ; six largeurs
      // égales, non. Et elles sont bien **égales** : l'écart est porté par la
      // rangée, pas par un remplissage dans la case — sinon la dernière
      // serait plus large que les cinq autres.
      for (var i = 1; i < 6; i++) {
        expect(tester.getSize(cases.at(i)).width, closeTo(premiere, 0.5));
      }
      expect(premiere * 6 + AppDimens.small * 5, closeTo(360, 1.0));
    });
  });
}
