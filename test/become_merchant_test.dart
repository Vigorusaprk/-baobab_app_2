import 'package:baobabe_0_2/core/errors/failure.dart';
import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/auth/domain/repositories/auth_repository.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/category_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/repositories/category_repository.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_space.dart';
import 'package:baobabe_0_2/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/become_merchant_sheet.dart';
import 'package:baobabe_0_2/features/settings/data/profile_api_service.dart';
import 'package:baobabe_0_2/features/settings/domain/entities/user_address.dart';
import 'package:baobabe_0_2/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Le formulaire d'ouverture de commerce.
///
/// C'était une page pleine dont le haut était occupé par un paragraphe
/// d'explication, et dont l'adresse tenait sur une ligne de texte libre.
/// Trois choses ont changé, et les trois se vérifient ici : la feuille,
/// l'explication rangée derrière un bouton, et l'adresse en six champs — les
/// mêmes que la livraison, et les mêmes colonnes en base.

class _FakeMerchantRepository implements MerchantRepository {
  UserAddress? sentAddress;
  String? sentName;

  @override
  Future<MerchantSpace> apply({
    required String businessName,
    required String categorySlug,
    required UserAddress address,
    required String phone,
    String? description,
  }) async {
    sentName = businessName;
    sentAddress = address;
    return const MerchantSpace();
  }

  @override
  Future<MerchantSpace> getSpace() async => const MerchantSpace();

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestableMerchantCubit extends MerchantCubit {
  _TestableMerchantCubit(super.repository) : super.forTest();

  @override
  bool get isSignedIn => true;
}

class _FakeCategories implements CategoryRepository {
  @override
  Future<List<Category>> getCategories() async => Category.fallback;

  @override
  Future<Category> getCategoryByType(BusinessType type) async => Category.all;
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
  Future<List<Province>> locations() async => const [
    Province(name: 'Kinshasa', cities: ['Kinshasa']),
  ];
}

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
  Future<Either<Failure, void>> requestEmailOtp(String email) async => const Right(null);

  @override
  Future<Either<Failure, void>> verifyEmailOtp(String email, String code) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> signOut() async => const Right(null);

  @override
  Future<Either<Failure, AuthResponse>> authWithGoogle() async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> authWithApple() async => const Right(null);
}

void main() {
  late _FakeMerchantRepository repository;
  late _FakeAuthRepository authRepository;

  Widget host() {
    repository = _FakeMerchantRepository();
    authRepository = _FakeAuthRepository();
    return MultiBlocProvider(
      providers: [
        BlocProvider<MerchantCubit>(
          create: (_) => _TestableMerchantCubit(repository),
        ),
        BlocProvider(
          create: (_) => CategoryBloc(categoryRepository: _FakeCategories()),
        ),
        BlocProvider(create: (_) => ProfileCubit(api: _FakeProfileApi())),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authRepository: authRepository),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.silvaTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () => showBecomeMerchantSheet(context),
                child: const Text('ouvrir'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('le formulaire vit dans une feuille', (tester) async {
    await open(tester);

    expect(find.text('Devenir commerçant'), findsOneWidget);
    expect(find.byTooltip('Fermer'), findsOneWidget);
  });

  testWidgets('l\'explication est rangée derrière un bouton', (tester) async {
    await open(tester);

    const explication = 'Publiez vos produits';
    expect(find.textContaining(explication), findsNothing);

    await tester.tap(find.byTooltip('À quoi sert un compte commerçant ?'));
    await tester.pumpAndSettle();
    expect(find.textContaining(explication), findsOneWidget);

    await tester.tap(find.byTooltip('Masquer l\'explication'));
    await tester.pumpAndSettle();
    expect(find.textContaining(explication), findsNothing);
  });

  testWidgets('l\'adresse a les six champs de la livraison', (tester) async {
    await open(tester);

    for (final label in [
      'Province',
      'Ville',
      'Commune',
      'Quartier',
      'Avenue',
      'N°',
    ]) {
      expect(
        find.text(label),
        findsOneWidget,
        reason: 'palier manquant : $label',
      );
    }
    expect(find.text(UserAddress.defaultProvince), findsWidgets);
  });

  testWidgets('une adresse réduite à la province est refusée', (tester) async {
    await open(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Chez Mama Nzuzi'),
      'Chez Mama Nzuzi',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, '+243 …'),
      '+243 900 000 000',
    );
    await tester.ensureVisible(find.text(Category.fallback.last.displayName));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Category.fallback.last.displayName));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Envoyer ma demande'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Envoyer ma demande'));
    await tester.pumpAndSettle();

    expect(repository.sentAddress, isNull);
    expect(
      find.text('Indiquez au moins votre commune et votre avenue.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'sans mot de passe enregistré, la première étape sécurise l\'accès marchand',
    (tester) async {
      await open(tester);
      authRepository.hasPasswordValue = false;

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Chez Mama Nzuzi'),
        'Chez Mama Nzuzi',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '+243 …'),
        '+243 900 000 000',
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Envoyer ma demande'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Envoyer ma demande'));
      await tester.pumpAndSettle();

      expect(find.text('Sécurisez votre accès marchand'), findsOneWidget);
      expect(
        find.textContaining(
          'Ce mot de password vous servira à vous connecter à Baobab Business',
        ),
        findsOneWidget,
      );
      expect(find.text('Définir le mot de passe'), findsOneWidget);
    },
  );

  testWidgets(
    'après un mot de passe posé, la demande repart sans redemander',
    (tester) async {
      await open(tester);
      authRepository.hasPasswordValue = false;

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Chez Mama Nzuzi'),
        'Chez Mama Nzuzi',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '+243 …'),
        '+243 900 000 000',
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Envoyer ma demande'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Envoyer ma demande'));
      await tester.pumpAndSettle();
      expect(find.text('Sécurisez votre accès marchand'), findsOneWidget);

      final passwordField = find.widgetWithText(
        TextFormField,
        '10 caractères minimum, une lettre et un chiffre',
      );
      final confirmationField = find.widgetWithText(
        TextFormField,
        'Saisissez le même mot de passe',
      );
      await tester.enterText(passwordField, 'ab12cd34ef');
      await tester.pump();
      await tester.enterText(confirmationField, 'ab12cd34ef');
      await tester.pump();
      await tester.ensureVisible(find.text('Définir le mot de passe'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Définir le mot de passe'));
      await tester.pumpAndSettle();

      expect(authRepository.setPasswordCalls, 1);
      expect(find.text('Sécurisez votre accès marchand'), findsNothing);
    },
  );

  testWidgets(
    'quand le mot de passe existe déjà, la demande part directement',
    (tester) async {
      await open(tester);
      authRepository.hasPasswordValue = true;

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Chez Mama Nzuzi'),
        'Chez Mama Nzuzi',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '+243 …'),
        '+243 900 000 000',
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Envoyer ma demande'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Envoyer ma demande'));
      await tester.pumpAndSettle();

      expect(find.text('Sécurisez votre accès marchand'), findsNothing);
      expect(find.text('Envoyer ma demande'), findsOneWidget);
    },
  );
}
