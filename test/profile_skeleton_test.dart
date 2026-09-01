import 'dart:async';

import 'package:baobabe_0_2/core/themes/app_theme.dart';
import 'package:baobabe_0_2/features/settings/data/profile_api_service.dart';
import 'package:baobabe_0_2/features/settings/domain/entities/user_address.dart';
import 'package:baobabe_0_2/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/profile_details.dart';
import 'package:flutter/material.dart';
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
///
/// La garantie était tenue par une capture d'écran. Elle l'est maintenant par
/// une **mesure** : on compare la largeur occupée par le squelette à celle du
/// contenu réel. Une image dit « ça a changé » sans dire quoi, et diffère
/// d'une machine à l'autre selon le rendu des polices ; un nombre dit
/// exactement ce qui casse.

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
    // La clé porte l'API : sans elle, un second `pumpWidget` réutilise
    // l'élément existant, `create` ne rejoue pas, et l'écran garde le cubit
    // du premier appel — le test mesurerait deux fois le squelette.
    key: ValueKey(api.runtimeType),
    create: (_) => ProfileCubit(api: api)..load(),
    child: const Scaffold(body: ProfileDetails(title: 'Mon profil')),
  ),
);

/// Largeur peinte par le bloc de texte, squelette ou contenu.
double _textBlockWidth(WidgetTester tester) {
  final column = find.descendant(
    of: find.byType(ProfileDetails),
    matching: find.byType(Column),
  );
  return tester.getSize(column.first).width;
}

void main() {
  const pageWidth = 400.0;

  Future<void> pumpAt(WidgetTester tester, ProfileApiService api) async {
    tester.view.physicalSize = const Size(pageWidth, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_page(api));
  }

  testWidgets('le squelette occupe la largeur de la page', (tester) async {
    await pumpAt(tester, _NeverAnswers());
    await tester.pump();

    // Le défaut d'origine : quatre barres courtes serrées à gauche. Le
    // squelette doit tenir la même largeur que la page, à ses marges près.
    final width = _textBlockWidth(tester);
    expect(
      width,
      greaterThan(pageWidth * 0.8),
      reason: 'le squelette est tassé au lieu de tenir la largeur',
    );
  });

  testWidgets('le squelette et le contenu ont la même largeur', (tester) async {
    await pumpAt(tester, _NeverAnswers());
    await tester.pump();
    final squelette = _textBlockWidth(tester);

    await pumpAt(tester, _Answers());
    await tester.pump();
    // Au-delà du fondu entre squelette et contenu, sinon on mesure les deux.
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Louis-kerry Dev'), findsOneWidget);
    expect(
      find.text('N° 10F, Av. Kasa-Vubu, Q. Lingwala, C. Gombe, Kinshasa'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    // C'est l'écart entre les deux qui faisait sauter la page à l'arrivée
    // des données.
    expect(_textBlockWidth(tester), closeTo(squelette, 1.0));
  });
}
