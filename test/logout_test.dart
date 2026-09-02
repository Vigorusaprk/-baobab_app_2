import 'dart:async';

import 'package:baobabe_0_2/core/errors/failure.dart';
import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/auth/domain/repositories/auth_repository.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// La déconnexion.
///
/// Elle en demandait deux pour une. `add(SignOutEvent())` ne fait qu'empiler
/// l'événement ; la navigation qui suivait partait donc alors que la session
/// était encore ouverte, et la garde du routeur la renvoyait à l'accueil. Ce
/// test tient l'ordre : **on ne quitte l'écran qu'une fois la session
/// réellement fermée**.

class _FakeAuthRepository implements AuthRepository {
  /// Tenue ouverte tant que le test ne décide pas que la déconnexion aboutit.
  final Completer<Either<Failure, void>> pending = Completer();

  @override
  Future<Either<Failure, void>> signOut() => pending.future;

  @override
  Future<Either<Failure, void>> requestEmailOtp(String email) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> verifyEmailOtp(String email, String code) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, AuthResponse>> authWithGoogle() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> authWithApple() => throw UnimplementedError();
}

Widget _app(AuthRepository repository) {
  final router = GoRouter(
    initialLocation: '/settings',
    routes: [
      GoRoute(
        path: '/settings',
        builder: (context, _) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => showLogoutConfirmationDialog(context),
              child: const Text('Déconnexion'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Accueil connexion'))),
      ),
    ],
  );

  return BlocProvider(
    create: (_) => AuthBloc(authRepository: repository),
    child: MaterialApp.router(theme: AppTheme.silvaTheme, routerConfig: router),
  );
}

Future<void> _confirm(WidgetTester tester) async {
  await tester.tap(find.text('Déconnexion'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Confirmer'));
  await tester.pump();
}

void main() {
  testWidgets('on ne navigue qu\'une fois la session fermée', (tester) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_app(repository));

    await _confirm(tester);
    await tester.pump(const Duration(milliseconds: 300));

    // La déconnexion est en cours : on est toujours sur les réglages. C'est
    // exactement ce qui manquait — on partait déjà, et la garde du routeur
    // renvoyait à l'accueil parce que la session tenait encore.
    expect(find.text('Accueil connexion'), findsNothing);

    repository.pending.complete(const Right(null));
    await tester.pumpAndSettle();

    expect(find.text('Accueil connexion'), findsOneWidget);
  });

  testWidgets('une déconnexion refusée ne fait pas croire au contraire', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_app(repository));

    await _confirm(tester);
    repository.pending.complete(
      Left(AuthFailure(message: 'Réseau indisponible.')),
    );
    await tester.pumpAndSettle();

    // On reste sur place : la session n'est pas fermée, il ne faut pas
    // laisser croire qu'elle l'est.
    expect(find.text('Accueil connexion'), findsNothing);
    expect(find.text('Réseau indisponible.'), findsOneWidget);
  });

  testWidgets('renoncer ne déconnecte pas', (tester) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_app(repository));

    await tester.tap(find.text('Déconnexion'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retour'));
    await tester.pumpAndSettle();

    expect(find.text('Accueil connexion'), findsNothing);
    expect(repository.pending.isCompleted, isFalse);
  });
}
