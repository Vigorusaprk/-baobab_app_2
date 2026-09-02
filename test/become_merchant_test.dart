import 'package:baobabe_0_2/core/themes/app_theme.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

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

void main() {
  late _FakeMerchantRepository repository;

  Widget host() {
    repository = _FakeMerchantRepository();
    return MultiBlocProvider(
      providers: [
        BlocProvider<MerchantCubit>(
          create: (_) => _TestableMerchantCubit(repository),
        ),
        BlocProvider(
          create: (_) => CategoryBloc(categoryRepository: _FakeCategories()),
        ),
        BlocProvider(create: (_) => ProfileCubit(api: _FakeProfileApi())),
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
    // Fermée au départ : elle rassure la première fois et encombre les
    // suivantes.
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

    // Les mêmes paliers que `user_info`, et désormais les mêmes colonnes sur
    // `business` : une ligne de texte libre interdisait de lister les
    // commerces d'une commune.
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
    // Kinshasa est proposée d'emblée : le formulaire démarre à moitié rempli.
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

    // La feuille défile : sans l'amener à l'écran, le tap tomberait à côté
    // du bouton et l'envoi ne serait jamais déclenché.
    await tester.ensureVisible(find.text('Envoyer ma demande'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Envoyer ma demande'));
    await tester.pumpAndSettle();

    // Rien n'est parti : sans commune ni avenue, un client ne trouverait pas
    // le commerce. Même exigence que la feuille de livraison, et que la base.
    expect(repository.sentAddress, isNull);
    expect(
      find.text('Indiquez au moins votre commune et votre avenue.'),
      findsOneWidget,
    );
  });
}
