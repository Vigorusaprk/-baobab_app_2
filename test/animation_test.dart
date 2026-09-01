import 'package:baobabe_0_2/core/animation/animated_count.dart';
import 'package:baobabe_0_2/core/animation/app_motion.dart';
import 'package:baobabe_0_2/core/animation/appear.dart';
import 'package:baobabe_0_2/core/animation/fade_swap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Le mouvement de l'application.
///
/// Ce qui est tenu ici n'est pas « ça bouge joliment » — ça ne se teste pas —
/// mais les deux promesses qui, si elles cassent, se voient tout de suite :
/// une animation qui ne joue jamais, et une animation qui joue alors que
/// l'utilisateur a demandé de les réduire.

Widget _app(Widget child, {bool reduceMotion = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(body: child),
  ),
);

/// Le fondu **d'`Appear`**, et non celui que `MaterialApp` pose sur ses
/// routes : sans cette restriction, `find.byType(FadeTransition).first`
/// attrape la transition de page et le test ne mesure pas ce qu'il croit.
Finder _appearFade() => find.descendant(
  of: find.byType(Appear),
  matching: find.byType(FadeTransition),
);

void main() {
  group('Le vocabulaire', () {
    testWidgets('les durées tombent à zéro si le système le demande', (
      tester,
    ) async {
      // Ce réglage existe pour les personnes que le mouvement gêne. Une
      // animation « juste jolie » ne vaut pas leur inconfort.
      late BuildContext reduit;
      late BuildContext normal;

      await tester.pumpWidget(
        _app(
          Builder(builder: (c) => SizedBox(key: ValueKey(reduit = c))),
          reduceMotion: true,
        ),
      );
      expect(AppMotion.duration(reduit, AppMotion.base), Duration.zero);
      expect(AppMotion.delayFor(reduit, 5), Duration.zero);
      expect(AppMotion.reduced(reduit), isTrue);

      await tester.pumpWidget(
        _app(Builder(builder: (c) => SizedBox(key: ValueKey(normal = c)))),
      );
      expect(AppMotion.duration(normal, AppMotion.base), AppMotion.base);
      expect(AppMotion.reduced(normal), isFalse);
    });

    test('le décalage d\'entrée est plafonné', () {
      // Sans plafond, le trentième élément d'une liste attendrait plus d'une
      // seconde : l'effet deviendrait une attente.
      final dixieme = AppMotion.stagger * AppMotion.maxStaggered;
      expect(AppMotion.stagger * 30, greaterThan(dixieme));
      expect(AppMotion.maxStaggered, lessThanOrEqualTo(10));
    });
  });

  group('Appear', () {
    testWidgets('l\'élément ne se déplace pas en apparaissant', (tester) async {
      // À cet endroit se tenait un squelette de même taille. Faire glisser
      // la carte par-dessus donnait un déplacement que rien ne justifie :
      // elle doit devenir nette, pas arriver.
      await tester.pumpWidget(_app(const Appear(child: Text('bonjour'))));
      final debut = tester.getTopLeft(find.text('bonjour'));

      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('bonjour')), debut);
    });

    testWidgets('part invisible et finit visible', (tester) async {
      await tester.pumpWidget(_app(const Appear(child: Text('bonjour'))));

      // Première trame : l'entrée commence à peine.
      final debut = tester.widget<FadeTransition>(_appearFade().first);
      expect(debut.opacity.value, lessThan(0.5));

      await tester.pumpAndSettle();
      final fin = tester.widget<FadeTransition>(_appearFade().first);
      expect(fin.opacity.value, 1.0);
      expect(find.text('bonjour'), findsOneWidget);
    });

    testWidgets('mouvement réduit : l\'élément est là d\'emblée', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const Appear(index: 5, child: Text('bonjour')),
          reduceMotion: true,
        ),
      );

      final transition = tester.widget<FadeTransition>(
        find.byType(FadeTransition).first,
      );
      expect(transition.opacity.value, 1.0);
    });

    testWidgets('un élément lointain n\'attend pas indéfiniment', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const Appear(index: 40, child: Text('x'))));

      // Le plafond s'applique : passé le décalage maximal, l'entrée démarre.
      // Deux temps sont nécessaires — le premier fait échoir l'attente, le
      // second joue l'animation qu'elle libère.
      await tester.pump(AppMotion.stagger * AppMotion.maxStaggered);
      await tester.pumpAndSettle();
      final transition = tester.widget<FadeTransition>(_appearFade().first);
      expect(transition.opacity.value, 1.0);
    });
  });

  group('FadeSwap', () {
    testWidgets('croise l\'ancien contenu et le nouveau', (tester) async {
      await tester.pumpWidget(
        _app(const FadeSwap(child: Text('avant', key: ValueKey('a')))),
      );
      expect(find.text('avant'), findsOneWidget);

      await tester.pumpWidget(
        _app(const FadeSwap(child: Text('après', key: ValueKey('b')))),
      );
      await tester.pump(const Duration(milliseconds: 60));

      // Pendant le croisement, les deux sont présents : c'est ce qui distingue
      // un fondu d'un remplacement sec.
      expect(find.text('avant'), findsOneWidget);
      expect(find.text('après'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('avant'), findsNothing);
      expect(find.text('après'), findsOneWidget);
    });

    testWidgets('le nouveau contenu ne glisse pas', (tester) async {
      // Même raison que pour `Appear` : le contenu remplace un squelette de
      // même forme, au même endroit.
      await tester.pumpWidget(
        _app(const FadeSwap(child: Text('avant', key: ValueKey('a')))),
      );
      final place = tester.getTopLeft(find.text('avant'));

      await tester.pumpWidget(
        _app(const FadeSwap(child: Text('après', key: ValueKey('b')))),
      );
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.getTopLeft(find.text('après')), place);

      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('après')), place);
    });

    testWidgets('sans clé distincte, rien ne se croise', (tester) async {
      // Le piège du widget : deux contenus de même type et de même clé sont
      // « le même widget » pour Flutter. C'est documenté sur `FadeSwap`, et
      // ce test le rend visible.
      await tester.pumpWidget(_app(const FadeSwap(child: Text('avant'))));
      await tester.pumpWidget(_app(const FadeSwap(child: Text('après'))));
      await tester.pump(const Duration(milliseconds: 60));

      expect(find.text('avant'), findsNothing);
      expect(find.text('après'), findsOneWidget);
    });
  });

  group('AnimatedCount', () {
    testWidgets('passe par les valeurs intermédiaires', (tester) async {
      await tester.pumpWidget(_app(const AnimatedCount(value: 0)));
      expect(find.text('0'), findsOneWidget);

      await tester.pumpWidget(_app(const AnimatedCount(value: 10)));
      await tester.pump(const Duration(milliseconds: 160));

      // Ni 0 ni 10 : le compteur défile. Sans cela il sauterait, et on
      // verrait le nouveau chiffre sans avoir vu qu'il avait bougé.
      expect(find.text('0'), findsNothing);
      expect(find.text('10'), findsNothing);

      await tester.pumpAndSettle();
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('mouvement réduit : le chiffre change sans défiler', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const AnimatedCount(value: 0), reduceMotion: true),
      );
      await tester.pumpWidget(
        _app(const AnimatedCount(value: 10), reduceMotion: true),
      );
      await tester.pump();

      expect(find.text('10'), findsOneWidget);
    });
  });
}
