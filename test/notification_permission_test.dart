import 'package:baobabe_0_2/core/database/local_cache.dart';
import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/notification/data/notification_preferences.dart';
import 'package:baobabe_0_2/features/notification/domain/notification_reason.dart';
import 'package:baobabe_0_2/features/notification/presentation/widgets/notification_permission_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// La règle de la demande de notifications.
///
/// Tout le dispositif tient sur cette règle, et elle est la seule pièce qui
/// décide quoi que ce soit — d'où le fait qu'elle se teste sans émulateur,
/// sans Firebase et sans widget :
///
/// - accepté une fois, plus jamais demandé ;
/// - refusé, on ne redemande pas pour la même nature d'action ;
/// - une action d'une autre nature peut reposer la question, une fois ;
/// - au-delà de deux refus, plus jamais.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Hive écrit sur disque ; le dossier temporaire du test suffit et évite
    // qu'un test hérite de ce qu'un autre a mémorisé.
    await LocalCache.initialize(path: '.dart_tool/test_cache');
    await NotificationPreferences.reset();
  });

  group('La règle', () {
    test('la première fois, on demande', () async {
      final prefs = await NotificationPreferences.load();
      expect(prefs.shouldAsk(NotificationReason.orderPlaced), isTrue);
      expect(prefs.exhausted, isFalse);
    });

    test(
      'accepté une fois : plus jamais demandé, pour aucune action',
      () async {
        var prefs = await NotificationPreferences.load();
        prefs = await prefs.markGranted();

        for (final reason in NotificationReason.values) {
          expect(
            prefs.shouldAsk(reason),
            isFalse,
            reason: 'redemandé après un accord : ${reason.key}',
          );
        }
        expect(prefs.exhausted, isTrue);

        // Et cela survit au redémarrage : la mémoire est sur disque.
        final relu = await NotificationPreferences.load();
        expect(relu.granted, isTrue);
        expect(relu.shouldAsk(NotificationReason.orderPlaced), isFalse);
      },
    );

    test('refusé : on n\'insiste pas sur le même prétexte', () async {
      var prefs = await NotificationPreferences.load();
      prefs = await prefs.markRefused(NotificationReason.orderPlaced);

      expect(prefs.shouldAsk(NotificationReason.orderPlaced), isFalse);
      // Mais une autre nature d'action garde le droit de demander : refuser
      // pour une commande ne veut pas dire refuser pour son commerce.
      expect(prefs.shouldAsk(NotificationReason.merchantJoined), isTrue);
    });

    test('au-delà de deux refus, plus rien', () async {
      var prefs = await NotificationPreferences.load();
      prefs = await prefs.markRefused(NotificationReason.orderPlaced);
      prefs = await prefs.markRefused(NotificationReason.reservationPlaced);

      expect(prefs.exhausted, isTrue);
      for (final reason in NotificationReason.values) {
        expect(prefs.shouldAsk(reason), isFalse);
      }
    });

    test('un même refus ne compte qu\'une fois', () async {
      // Sans cette garde, deux commandes refusées d'affilée épuiseraient le
      // quota, et le commerçant n'aurait jamais sa question.
      var prefs = await NotificationPreferences.load();
      prefs = await prefs.markRefused(NotificationReason.orderPlaced);
      prefs = await prefs.markRefused(NotificationReason.orderPlaced);

      expect(prefs.refused.length, 1);
      expect(prefs.shouldAsk(NotificationReason.merchantJoined), isTrue);
    });

    test('le réglage remet le compteur à zéro', () async {
      var prefs = await NotificationPreferences.load();
      prefs = await prefs.markRefused(NotificationReason.orderPlaced);
      prefs = await prefs.markRefused(NotificationReason.reservationPlaced);
      expect(prefs.exhausted, isTrue);

      // Quelqu'un qui active les notifications lui-même revient sur son
      // refus : le lui opposer encore serait absurde.
      await NotificationPreferences.reset();
      final relu = await NotificationPreferences.load();
      expect(relu.shouldAsk(NotificationReason.orderPlaced), isTrue);
    });
  });

  group('La feuille', () {
    Widget host(
      NotificationReason reason,
      ValueChanged<PermissionAnswer> onAnswer,
    ) => MaterialApp(
      theme: AppTheme.silvaTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () async => onAnswer(
                await showNotificationPermissionSheet(context, reason: reason),
              ),
              child: const Text('ouvrir'),
            ),
          ),
        ),
      ),
    );

    testWidgets('elle donne la raison de l\'action accomplie', (tester) async {
      await tester.pumpWidget(host(NotificationReason.orderPlaced, (_) {}));
      await tester.tap(find.text('ouvrir'));
      await tester.pumpAndSettle();

      expect(find.text(NotificationReason.orderPlaced.title), findsOneWidget);
      expect(find.text(NotificationReason.orderPlaced.main), findsOneWidget);
      // Et les raisons secondaires, en retrait mais présentes.
      for (final item in NotificationReason.secondary) {
        expect(find.text(item.label), findsOneWidget);
      }
    });

    testWidgets('la raison suit l\'action', (tester) async {
      await tester.pumpWidget(host(NotificationReason.merchantJoined, (_) {}));
      await tester.tap(find.text('ouvrir'));
      await tester.pumpAndSettle();

      expect(find.text(NotificationReason.merchantJoined.main), findsOneWidget);
      expect(find.text(NotificationReason.orderPlaced.main), findsNothing);
    });

    testWidgets('« Plus tard » vaut un refus', (tester) async {
      PermissionAnswer? answer;
      await tester.pumpWidget(
        host(NotificationReason.orderPlaced, (value) => answer = value),
      );
      await tester.tap(find.text('ouvrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Plus tard'));
      await tester.pumpAndSettle();

      expect(answer, PermissionAnswer.decline);
    });

    testWidgets('fermer la feuille vaut aussi un refus', (tester) async {
      // Une fermeture n'est pas une hésitation à exploiter : on n'insistera
      // plus pour cette action.
      PermissionAnswer? answer;
      await tester.pumpWidget(
        host(NotificationReason.orderPlaced, (value) => answer = value),
      );
      await tester.tap(find.text('ouvrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Fermer'));
      await tester.pumpAndSettle();

      expect(answer, PermissionAnswer.decline);
    });

    testWidgets('accepter renvoie l\'accord', (tester) async {
      PermissionAnswer? answer;
      await tester.pumpWidget(
        host(NotificationReason.orderPlaced, (value) => answer = value),
      );
      await tester.tap(find.text('ouvrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Activer les notifications'));
      await tester.pumpAndSettle();

      expect(answer, PermissionAnswer.accept);
    });
  });
}
