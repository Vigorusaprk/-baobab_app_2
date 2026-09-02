import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_session_cubit.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_space.dart';
import 'package:baobabe_0_2/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:baobabe_0_2/features/settings/data/profile_api_service.dart';
import 'package:baobabe_0_2/features/settings/domain/entities/user_address.dart';
import 'package:baobabe_0_2/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:baobabe_0_2/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:baobabe_0_2/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Les réglages doivent suivre la session.
///
/// Le défaut signalé : se connecter depuis cet écran fermait la feuille et
/// laissait la page telle quelle — « Se connecter » toujours affiché, pas de
/// bouton de déconnexion — jusqu'à ce qu'un autre événement provoque une
/// reconstruction. La session était lue **une fois**, au moment du `build`.
///
/// `AuthSessionCubit` existait déjà et était fourni pour toute l'application ;
/// cet écran ne s'en servait pas.

/// Laisse le test décider de l'état de session, sans Supabase.
class _ControllableSession extends AuthSessionCubit {
  void signIn() => emit(const AuthSessionAuthenticated());
  void signOut() => emit(const AuthSessionUnauthenticated());
}

class _FakeProfileApi implements ProfileApiService {
  @override
  Future<ProfileBundle> load() async =>
      const ProfileBundle(profile: UserProfile(), address: null);

  @override
  Future<ProfileBundle> save({
    String? name,
    String? phone,
    UserAddress? address,
  }) async => load();

  @override
  Future<List<Province>> locations() async => const [];
}

class _FakeMerchantRepository implements MerchantRepository {
  @override
  Future<MerchantSpace> getSpace() async => const MerchantSpace();

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestableMerchantCubit extends MerchantCubit {
  _TestableMerchantCubit(super.repository) : super.forTest();

  @override
  bool get isSignedIn => false;
}

void main() {
  testWidgets('la page suit la session, sans qu\'on la quitte', (tester) async {
    final session = _ControllableSession();
    addTearDown(session.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthSessionCubit>.value(value: session),
          BlocProvider(create: (_) => SettingsCubit()),
          BlocProvider(create: (_) => ProfileCubit(api: _FakeProfileApi())),
          BlocProvider<MerchantCubit>(
            create: (_) => _TestableMerchantCubit(_FakeMerchantRepository()),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.silvaTheme,
          home: const Scaffold(body: SettingsScreen()),
        ),
      ),
    );
    await tester.pump();

    // Visiteur : la carte invite à se connecter, et il n'y a rien à quitter.
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Déconnexion'), findsNothing);

    // La session s'ouvre. **Aucune interaction** avec la page : c'est tout
    // l'enjeu — elle doit se remettre à jour d'elle-même.
    session.signIn();
    // Deux temps : un bloc livre son état sur une micro-tâche, et la
    // première trame se peint avant qu'elle ne s'exécute.
    await tester.pump();
    await tester.pump();

    expect(find.text('Se connecter'), findsNothing);
    expect(find.text('Déconnexion'), findsOneWidget);

    // Et dans l'autre sens.
    session.signOut();
    await tester.pump();
    await tester.pump();

    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Déconnexion'), findsNothing);
  });
}
