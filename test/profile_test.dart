import 'dart:io';

import 'package:baobabe_0_2/features/settings/data/profile_api_service.dart';
import 'package:baobabe_0_2/features/settings/domain/entities/user_address.dart';
import 'package:baobabe_0_2/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

/// Le profil : six colonnes en base, une seule ligne à l'écran.
///
/// L'adresse est découpée en paliers (province, ville, commune, quartier,
/// avenue, numéro) parce que c'est ainsi qu'elle se dit à Kinshasa et que ça
/// permettra de grouper les livraisons. Mais on ne montre pas six lignes à
/// quelqu'un qui veut relire son adresse.

class _FakeApi implements ProfileApiService {
  _FakeApi({this.bundle, this.fail = false});

  ProfileBundle? bundle;
  final bool fail;

  final List<Map<String, Object?>> writes = [];

  @override
  Future<ProfileBundle> load() async {
    if (fail) throw Exception('réseau indisponible');
    return bundle ??
        const ProfileBundle(profile: UserProfile(), address: null);
  }

  @override
  Future<ProfileBundle> save({
    String? name,
    String? phone,
    UserAddress? address,
  }) async {
    writes.add({'name': name, 'phone': phone, 'address': address});
    if (fail) throw Exception('réseau indisponible');
    final saved = ProfileBundle(
      profile: UserProfile(name: name, phone: phone),
      address: address,
    );
    bundle = saved;
    return saved;
  }

  @override
  Future<List<Province>> locations() async => const [
    Province(name: 'Kinshasa', cities: ['Kinshasa']),
    Province(name: 'Nord-Kivu', cities: ['Goma', 'Butembo']),
  ];
}

void main() {
  group("L'adresse sur une ligne", () {
    test('se lit du précis au large, comme on la dit', () {
      const address = UserAddress(
        province: 'Kinshasa',
        ville: 'Kinshasa',
        commune: 'Gombe',
        quartier: 'Lingwala',
        avenue: 'Kasa-Vubu',
        numero: '10F',
      );

      expect(
        address.oneLine,
        'N° 10F, Av. Kasa-Vubu, Q. Lingwala, C. Gombe, Kinshasa',
      );
    });

    test('les paliers manquants sont omis, sans virgule orpheline', () {
      // Le cas courant tant que la fiche n'est pas terminée.
      const address = UserAddress(province: 'Kinshasa', commune: 'Limete');

      expect(address.oneLine, 'C. Limete, Kinshasa');
      expect(address.oneLine, isNot(contains(', ,')));
      expect(address.oneLine.trim(), isNot(endsWith(',')));
    });

    test('la ville ne se répète pas quand elle porte le nom de la province', () {
      // Kinshasa est à la fois province et ville : l'écrire deux fois se
      // lirait comme une erreur.
      const address = UserAddress(
        province: 'Kinshasa',
        ville: 'Kinshasa',
        commune: 'Gombe',
      );

      expect(address.oneLine, 'C. Gombe, Kinshasa');
    });

    test('une ville distincte de la province apparaît', () {
      const address = UserAddress(
        province: 'Nord-Kivu',
        ville: 'Goma',
        commune: 'Karisimbi',
      );

      expect(address.oneLine, 'C. Karisimbi, Goma, Nord-Kivu');
    });

    test('une adresse réduite à la province est vide', () {
      // On ne peut livrer nulle part avec ça : la feuille de commande le
      // refuse, et le profil la traite comme non renseignée.
      const address = UserAddress();
      expect(address.isEmpty, isTrue);
      expect(const UserAddress(commune: 'Gombe').isEmpty, isFalse);
    });

    test('Kinshasa est la province proposée par défaut', () {
      expect(const UserAddress().province, 'Kinshasa');
      expect(UserAddress.fromJson(const {}).province, 'Kinshasa');
    });

    test('une chaîne vide vaut « non renseigné »', () {
      // Sans ce nettoyage, un champ effacé resterait à '' et l'adresse
      // afficherait « C. , Kinshasa ».
      final address = UserAddress.fromJson(const {
        'province': 'Kinshasa',
        'commune': '   ',
        'avenue': '',
      });

      expect(address.commune, isNull);
      expect(address.avenue, isNull);
      expect(address.oneLine, 'Kinshasa');
    });
  });

  group('Le profil incomplet se signale', () {
    test('sans nom ni téléphone, la fiche est à compléter', () async {
      final cubit = ProfileCubit(api: _FakeApi());
      await cubit.load();

      expect(cubit.state.isIncomplete, isTrue);
      await cubit.close();
    });

    test('renseignée, elle ne l\'est plus', () async {
      final api = _FakeApi(
        bundle: const ProfileBundle(
          profile: UserProfile(name: 'Nadine', phone: '+243900000000'),
          address: UserAddress(commune: 'Gombe', avenue: 'Kasa-Vubu'),
        ),
      );
      final cubit = ProfileCubit(api: api);
      await cubit.load();

      expect(cubit.state.isIncomplete, isFalse);
      await cubit.close();
    });

    test('une adresse manquante suffit à rendre la fiche incomplète', () async {
      final api = _FakeApi(
        bundle: const ProfileBundle(
          profile: UserProfile(name: 'Nadine', phone: '+243900000000'),
          address: null,
        ),
      );
      final cubit = ProfileCubit(api: api);
      await cubit.load();

      expect(cubit.state.isIncomplete, isTrue);
      await cubit.close();
    });
  });

  group('Enregistrer', () {
    test('un échec rend faux et laisse un message écrit', () async {
      final cubit = ProfileCubit(api: _FakeApi(fail: true));

      final ok = await cubit.save(name: 'Nadine');

      expect(ok, isFalse);
      expect(cubit.state.message, isNotNull);
      expect(cubit.state.message, isNot(contains('Exception')));
      await cubit.close();
    });

    test('le référentiel n\'est chargé qu\'une fois', () async {
      final cubit = ProfileCubit(api: _FakeApi());

      await cubit.loadProvinces();
      final first = cubit.state.provinces;
      await cubit.loadProvinces();

      expect(cubit.state.provinces, same(first));
      await cubit.close();
    });
  });

  group('Les écrans passent par la barre commune', () {
    test('aucune page ne construit son propre AppBar', () {
      // `custom_app_bar.dart` définit le fond, l'élévation et la teinte une
      // fois. Onze pages les redéfinissaient chacune de leur côté.
      final fautifs = <String>[];
      for (final file in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final relative = file.path.replaceAll(r'\', '/');
        if (relative.endsWith('core/widgets/custom_app_bar.dart')) continue;
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (lines[i].contains('appBar: AppBar(')) {
            fautifs.add('$relative:${i + 1}');
          }
        }
      }

      expect(
        fautifs,
        isEmpty,
        reason:
            'utilisez CustomOtherAppBar (titre texte) ou CustomAppBar '
            '(titre widget).\n${fautifs.join('\n')}',
      );
    });
  });
}
