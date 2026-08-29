import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Les dates de l'application s'écrivent en français.
///
/// `intl` ne connaît que sa locale par défaut tant qu'on ne charge pas les
/// données des autres : sans `initializeDateFormatting`, tout `DateFormat`
/// en français lève. Le défaut ne se voyait qu'à l'exécution, sur la fiche
/// d'une offre datée et dans la boîte de réception du commerçant.
void main() {
  test('sans initialisation, le format français lève', () {
    expect(
      () => DateFormat('EEEE d MMMM', 'ja_JP').format(DateTime(2026, 9, 20)),
      throwsA(anything),
      reason:
          'preuve que le chargement des données de locale est nécessaire, '
          'et non une précaution théorique.',
    );
  });

  test('une fois initialisée, elle écrit bien en français', () async {
    await initializeDateFormatting('fr_FR');

    final texte = DateFormat(
      'EEEE d MMMM à HH:mm',
      'fr_FR',
    ).format(DateTime(2026, 9, 20, 15, 30));

    expect(texte, contains('septembre'));
    expect(texte, contains('dimanche'));
  });
}
