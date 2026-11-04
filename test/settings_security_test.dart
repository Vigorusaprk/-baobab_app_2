import 'package:baobabe_0_2/core/errors/failure.dart';
import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/auth/domain/repositories/auth_repository.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/settings/presentation/cubit/security_cubit.dart';
import 'package:baobabe_0_2/features/settings/presentation/screens/security_screen.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/security_settings_section.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// La page « Sécurité » des paramètres.
///
/// C'est elle qui fait le lien entre deux états : le compte a-t-il un mot
/// de passe, et le formulaire qui en pose un. Les deux se vérifient ici,
/// et les erreurs — dont la ré-authentification requise — remontent
/// jusqu'à l'interface.
class _FakeAuthRepository implements AuthRepository {
  bool hasPasswordValue = true;
  int setPasswordCalls = 0;
  String? setPasswordError;

  @override
  Future<bool> hasPassword() async => hasPasswordValue;

  @override
  Future<Either<Failure, void>> setPassword(String password) async {
    setPasswordCalls++;
    if (setPasswordError != null) {
      return Left(AuthFailure(message: setPasswordError!));
    }
    hasPasswordValue = true;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> requestEmailOtp(String email) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> verifyEmailOtp(String email, String code) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> signOut() async => const Right(null);

  @override
  Future<Either<Failure, AuthResponse>> authWithGoogle() async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> authWithApple() async => const Right(null);
}

void main() {
  late _FakeAuthRepository authRepository;

  Widget host({required bool hasPassword}) {
    authRepository = _FakeAuthRepository()..hasPasswordValue = hasPassword;
    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (context, state) =>
              const Scaffold(body: SecuritySettingsSection()),
        ),
        GoRoute(
          path: '/settings/security',
          name: 'settingsSecurity',
          builder: (context, state) => const SecurityScreen(),
        ),
      ],
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authRepository: authRepository),
        ),
        BlocProvider<SecurityCubit>(
          create: (_) => SecurityCubit(authRepository: authRepository)..load(),
        ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.silvaTheme,
        routerConfig: router,
      ),
    );
  }

  Future<void> openSecurityPage(WidgetTester tester) async {
    await tester.tap(find.text('Définir un mot de passe'));
    await tester.pumpAndSettle();
  }

  testWidgets('sans mot de passe, la tuile invite à en définir un', (
    tester,
  ) async {
    await tester.pumpWidget(host(hasPassword: false));
    await tester.pumpAndSettle();

    expect(find.text('Définir un mot de passe'), findsOneWidget);
    expect(find.text('Changer mon mot de passe'), findsNothing);
  });

  testWidgets('avec mot de passe, la tuile propose de le changer', (
    tester,
  ) async {
    await tester.pumpWidget(host(hasPassword: true));
    await tester.pumpAndSettle();

    expect(find.text('Changer mon mot de passe'), findsOneWidget);
    expect(find.text('Définir un mot de passe'), findsNothing);
  });

  testWidgets('la page sécurité affiche titre, formulaire et texte d\'aide', (
    tester,
  ) async {
    await tester.pumpWidget(host(hasPassword: false));
    await tester.pumpAndSettle();
    await openSecurityPage(tester);

    expect(find.text('Sécurité'), findsOneWidget);
    expect(find.text('Définir le mot de passe'), findsOneWidget);
    expect(find.textContaining('Mot de passe perdu ?'), findsOneWidget);
  });

  testWidgets('définir le mot de passe ferme la page et confirme', (
    tester,
  ) async {
    await tester.pumpWidget(host(hasPassword: false));
    await tester.pumpAndSettle();
    await openSecurityPage(tester);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'ab12cd34ef');
    await tester.pump();
    await tester.enterText(fields.at(1), 'ab12cd34ef');
    await tester.pump();
    await tester.ensureVisible(find.text('Définir le mot de passe'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Définir le mot de passe'));
    await tester.pumpAndSettle();

    expect(authRepository.setPasswordCalls, 1);
    expect(find.text('Mot de passe défini.'), findsOneWidget);
    expect(find.textContaining('Mot de passe perdu ?'), findsNothing);
  });

  testWidgets('une ré-authentification requise affiche le message clair', (
    tester,
  ) async {
    await tester.pumpWidget(host(hasPassword: false));
    authRepository.setPasswordError =
        'Pour votre sécurité, reconnectez-vous par code e-mail '
        'avant de définir votre mot de passe.';
    await tester.pumpAndSettle();
    await openSecurityPage(tester);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'ab12cd34ef');
    await tester.pump();
    await tester.enterText(fields.at(1), 'ab12cd34ef');
    await tester.pump();
    await tester.ensureVisible(find.text('Définir le mot de passe'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Définir le mot de passe'));
    await tester.pumpAndSettle();

    expect(find.textContaining('code e-mail avant de définir votre mot de passe'),
        findsOneWidget);
    expect(authRepository.setPasswordCalls, 1);
  });
}
