import 'package:baobabe_0_2/features/home_page/presentation/widgets/home_sliver_header.dart';
import 'package:flutter_test/flutter_test.dart';

/// La salutation de l'accueil.
///
/// Elle disait « Bonjour, » à tout le monde. Elle nomme maintenant la
/// personne connectée — et seulement elle : une visite sans compte garde la
/// formule d'avant, plutôt qu'un « cher client » de circonstance.
void main() {
  test('sans compte, la formule ne change pas', () {
    final sans = HomeSliverHeaderMetrics.greeting(null);
    expect(sans.endsWith(','), isTrue);
    expect(sans.split(' ').length, lessThanOrEqualTo(2));
  });

  test('connecté, la salutation porte le prénom', () {
    expect(
      HomeSliverHeaderMetrics.greeting('Louis-kerry'),
      endsWith(' Louis-kerry,'),
    );
  });

  test('seul le prénom est retenu', () {
    // La ligne est unique et partage sa largeur avec la cloche de
    // notifications : un nom complet la ferait déborder.
    expect(
      HomeSliverHeaderMetrics.firstName('Louis-kerry Guillaume'),
      'Louis-kerry',
    );
    expect(HomeSliverHeaderMetrics.firstName('  Marie   Claire '), 'Marie');
  });

  test('la question suit le moment de la journée', () {
    // Elle disait « aujourd'hui » à toute heure. À 21 h, proposer un
    // programme pour la journée sonne faux : ce qui reste, c'est la soirée.
    String q(int h) =>
        HomeSliverHeaderMetrics.question(DateTime(2026, 9, 2, h));

    expect(q(9), contains("aujourd'hui"));
    expect(q(15), contains('cet après-midi'));
    expect(q(21), contains('ce soir'));
    expect(q(3), contains('cette nuit'));
  });

  test('la salutation aussi', () {
    String g(int h) =>
        HomeSliverHeaderMetrics.greeting(null, DateTime(2026, 9, 2, h));

    expect(g(9), startsWith('Bonjour'));
    expect(g(15), startsWith('Bon après-midi'));
    expect(g(21), startsWith('Bonsoir'));
    expect(g(3), startsWith('Bonne nuit'));
  });

  test('un nom vide vaut pas de nom', () {
    expect(HomeSliverHeaderMetrics.firstName(''), isNull);
    expect(HomeSliverHeaderMetrics.firstName('   '), isNull);
    expect(HomeSliverHeaderMetrics.firstName(null), isNull);
  });
}
