@Tags(['golden'])
library;

import 'dart:async';
import 'dart:io';

import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/settings/data/profile_api_service.dart';
import 'package:baobabe_0_2/features/settings/domain/entities/user_address.dart';
import 'package:baobabe_0_2/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/profil_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Le squelette du profil doit **avoir la forme de la page**.
///
/// Il empilait quatre courtes barres centrées, là où la page réelle aligne une
/// icône puis deux lignes de texte sur toute la largeur : tassé au milieu
/// pendant le chargement, puis saut complet à l'arrivée des données.
///
/// C'est la règle du projet — un squelette d'une autre taille que son contenu
/// fait sauter la page — appliquée ici à la largeur autant qu'à la hauteur.

/// Une API qui ne répond jamais : l'écran reste sur son squelette.
class _NeverAnswers implements ProfileApiService {
  final _pending = Completer<Never>();

  @override
  Future<ProfileBundle> load() => _pending.future;

  @override
  Future<ProfileBundle> save({
    String? name,
    String? phone,
    UserAddress? address,
  }) => _pending.future;

  @override
  Future<List<Province>> locations() => _pending.future;
}

class _Answers implements ProfileApiService {
  @override
  Future<ProfileBundle> load() async => const ProfileBundle(
    profile: UserProfile(
      name: 'Louis-kerry Dev',
      email: 'louiskerry@example.cd',
      phone: '+243 900 000 000',
    ),
    address: UserAddress(
      province: 'Kinshasa',
      ville: 'Kinshasa',
      commune: 'Gombe',
      quartier: 'Lingwala',
      avenue: 'Kasa-Vubu',
      numero: '10F',
    ),
  );

  @override
  Future<ProfileBundle> save({
    String? name,
    String? phone,
    UserAddress? address,
  }) => load();

  @override
  Future<List<Province>> locations() async => const [];
}

Widget _page(ProfileApiService api) => MaterialApp(
  theme: AppTheme.silvaTheme,
  debugShowCheckedModeBanner: false,
  home: BlocProvider(
    create: (_) => ProfileCubit(api: api)..load(),
    child: const ProfilPage(),
  ),
);

Future<void> _loadPoppins() async {
  final loader = FontLoader('Poppins');
  loader.addFont(
    File(
      'assets/Poppins/Poppins-Regular.ttf',
    ).readAsBytes().then((b) => ByteData.view(b.buffer)),
  );
  await loader.load();
}

void main() {
  setUpAll(_loadPoppins);

  testWidgets('le squelette du profil', (tester) async {
    tester.view.physicalSize = const Size(1080, 1700);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_page(_NeverAnswers()));
    await tester.pump();

    await expectLater(
      find.byType(ProfilPage),
      matchesGoldenFile('goldens/profil_squelette.png'),
    );
  });

  testWidgets('la page chargée', (tester) async {
    tester.view.physicalSize = const Size(1080, 1700);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_page(_Answers()));
    // Quelques trames plutôt que `pumpAndSettle` : le shimmer du squelette ne
    // s'arrête jamais de lui-même, l'attente tournerait à vide.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Louis-kerry Dev'), findsOneWidget);
    expect(
      find.text('N° 10F, Av. Kasa-Vubu, Q. Lingwala, C. Gombe, Kinshasa'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await expectLater(
      find.byType(ProfilPage),
      matchesGoldenFile('goldens/profil_charge.png'),
    );
  });
}
