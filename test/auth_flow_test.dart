import 'package:baobabe_0_2/core/errors/failure.dart';
import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/core/widgets/custom_bottom_sheet.dart';
import 'package:baobabe_0_2/core/widgets/otp_code_field.dart';
import 'package:baobabe_0_2/features/auth/domain/repositories/auth_repository.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/widgets/auth_form.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// La connexion par e-mail et code, telle qu'elle se joue dans la feuille.
///
/// Trois temps : l'adresse, le code, la confirmation. Ce qui est tenu ici,
/// c'est l'enchaînement — le titre de l'étape, le retour possible ou non, le
/// verdict du serveur rendu visible sur les cases, et le bouton qui ne
/// s'allume que quand il y a quelque chose à envoyer.

/// Dépôt factice : ce test porte sur le parcours, pas sur le réseau.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.envoiEchoue});

  /// Message d'erreur à renvoyer à la demande de code, ou `null` si elle
  /// réussit.
  final String? envoiEchoue;
  static const String codeAttendu = '123456';

  @override
  Future<Either<Failure, void>> requestEmailOtp(String email) async =>
      envoiEchoue == null
      ? const Right(null)
      : Left(AuthFailure(message: envoiEchoue!));

  @override
  Future<Either<Failure, void>> verifyEmailOtp(
    String email,
    String code,
  ) async => code == codeAttendu
      ? const Right(null)
      : Left(AuthFailure(message: 'code refusé'));

  @override
  Future<Either<Failure, void>> signOut() async => const Right(null);

  @override
  Future<Either<Failure, AuthResponse>> authWithGoogle() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> authWithApple() => throw UnimplementedError();
}

Widget _host(AuthRepository repository) => MaterialApp(
  theme: AppTheme.silvaTheme,
  home: BlocProvider(
    create: (_) => AuthBloc(authRepository: repository),
    child: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () => showCustomBottomSheet<void>(
              context: context,
              child: BlocProvider.value(
                value: context.read<AuthBloc>(),
                child: const AuthForm(),
              ),
            ),
            child: const Text('se connecter'),
          ),
        ),
      ),
    ),
  ),
);

Future<void> _openSheet(WidgetTester tester, AuthRepository repo) async {
  await tester.pumpWidget(_host(repo));
  await tester.tap(find.text('se connecter'));
  await tester.pumpAndSettle();
}

Future<void> _typeCode(WidgetTester tester, String code) async {
  final boxes = find.descendant(
    of: find.byType(OtpCodeField),
    matching: find.byType(TextField),
  );
  for (var i = 0; i < code.length; i++) {
    await tester.enterText(boxes.at(i), code[i]);
    await tester.pump();
  }
}

/// L'état des cases, lu sur le widget plutôt que sur les pixels.
OtpStatus _status(WidgetTester tester) =>
    tester.widget<OtpCodeField>(find.byType(OtpCodeField)).status;

void main() {
  testWidgets('première étape : l\'adresse, sans retour possible', (
    tester,
  ) async {
    await _openSheet(tester, _FakeAuthRepository());

    expect(find.text('Adresse e-mail'), findsWidgets);
    // Rien derrière la première étape.
    expect(find.byTooltip('Étape précédente'), findsNothing);
    expect(
      find.textContaining('Nous vous enverrons ensuite un code'),
      findsOneWidget,
    );
  });

  testWidgets('l\'envoi refusé s\'affiche sous le champ', (tester) async {
    await _openSheet(
      tester,
      _FakeAuthRepository(envoiEchoue: 'Adresse inconnue.'),
    );

    await tester.enterText(find.byType(TextFormField), 'hello@kunn.me');
    await tester.pump();
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();

    // Sous le champ, pas dans une notification en bas d'écran : celle-ci
    // passerait derrière la feuille.
    expect(find.text('Adresse inconnue.'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('le parcours complet, de l\'adresse à la confirmation', (
    tester,
  ) async {
    await _openSheet(tester, _FakeAuthRepository());

    // --- Étape 1 : l'adresse -------------------------------------------
    await tester.enterText(find.byType(TextFormField), 'hello@kunn.me');
    await tester.pump();
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();

    // --- Étape 2 : le code ---------------------------------------------
    expect(find.text('Code de confirmation'), findsOneWidget);
    // Le retour apparaît : on peut corriger son adresse.
    expect(find.byTooltip('Étape précédente'), findsOneWidget);
    expect(find.textContaining('hello@kunn.me'), findsOneWidget);
    expect(_status(tester), OtpStatus.editing);

    // Un code faux : les cases le disent, en couleur et en toutes lettres.
    await _typeCode(tester, '000000');
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(_status(tester), OtpStatus.invalid);
    expect(find.text('Code invalide. Veuillez réessayer.'), findsOneWidget);

    // Le corriger efface le verdict : il portait sur un code qui n'existe
    // plus.
    await _typeCode(tester, '1');
    await tester.pumpAndSettle();
    expect(_status(tester), OtpStatus.editing);

    // Le bon code. Les cases passent au vert et **y restent un instant** :
    // sans cette pause, le verdict serait remplacé dans la trame qui
    // l'affiche, et on ne verrait jamais que le code a été accepté.
    await _typeCode(tester, '123456');
    await tester.tap(find.text('Suivant'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(_status(tester), OtpStatus.verified);
    expect(find.text('Code vérifié.'), findsOneWidget);

    // --- Étape 3 : la confirmation, sans qu'on appuie sur rien ----------
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Terminé'), findsOneWidget);
    expect(find.text('Connexion réussie'), findsOneWidget);
    // On ne revient pas en arrière depuis une connexion faite.
    expect(find.byTooltip('Étape précédente'), findsNothing);

    // Puis la feuille se referme d'elle-même, et l'on retrouve la page d'où
    // l'on venait. Trois temps, parce que `pumpAndSettle` fait tourner les
    // animations mais n'avance pas la pause de lecture, qui est un `Timer`.
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.text('Connexion réussie'), findsNothing);
    expect(find.text('se connecter'), findsOneWidget);
  });

  testWidgets('le retour ramène à l\'adresse et vide le code', (tester) async {
    await _openSheet(tester, _FakeAuthRepository());

    await tester.enterText(find.byType(TextFormField), 'hello@kunn.me');
    await tester.pump();
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();

    await _typeCode(tester, '999');
    await tester.tap(find.byTooltip('Étape précédente'));
    await tester.pumpAndSettle();

    expect(find.text('Adresse e-mail'), findsWidgets);

    // Revenir au code : les cases sont vides, pas remplies d'un essai
    // abandonné.
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    final rempli = tester
        .widgetList<TextField>(
          find.descendant(
            of: find.byType(OtpCodeField),
            matching: find.byType(TextField),
          ),
        )
        .where((f) => (f.controller?.text ?? '').isNotEmpty);
    expect(rempli, isEmpty);
  });

  group('Le champ de code', () {
    Widget field(TextEditingController c, {OtpStatus s = OtpStatus.editing}) =>
        MaterialApp(
          theme: AppTheme.silvaTheme,
          home: Scaffold(
            body: OtpCodeField(controller: c, status: s, autofocus: false),
          ),
        );

    testWidgets('un code collé d\'un bloc se répartit sur les cases', (
      tester,
    ) async {
      final code = TextEditingController();
      await tester.pumpWidget(field(code));

      // C'est ce que fait le gestionnaire de mots de passe, et ce que fait
      // un collage : tout arrive dans la première case.
      await tester.enterText(find.byType(TextField).first, '482913');
      await tester.pumpAndSettle();

      expect(code.text, '482913');
    });

    testWidgets('ce qui n\'est pas un chiffre est écarté', (tester) async {
      final code = TextEditingController();
      await tester.pumpWidget(field(code));

      await tester.enterText(find.byType(TextField).first, '4-8 2b9 13');
      await tester.pumpAndSettle();

      expect(code.text, '482913');
    });
  });
}
