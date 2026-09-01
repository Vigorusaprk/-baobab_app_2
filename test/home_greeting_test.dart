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

  test('un nom vide vaut pas de nom', () {
    expect(HomeSliverHeaderMetrics.firstName(''), isNull);
    expect(HomeSliverHeaderMetrics.firstName('   '), isNull);
    expect(HomeSliverHeaderMetrics.firstName(null), isNull);
  });
}
