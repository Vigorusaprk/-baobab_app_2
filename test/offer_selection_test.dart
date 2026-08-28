import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_selection.dart';
import 'package:flutter_test/flutter_test.dart';

/// Vérifie la sélection d'offres : ce que l'utilisateur choisit, ce que ça
/// coûte, et quelle date fait foi. Le montant réellement enregistré est
/// recalculé par le serveur — ces totaux ne servent qu'à l'affichage.
Offer _offer(
  String id, {
  double price = 10,
  Fulfilment fulfilment = Fulfilment.order,
  DateTime? startsAt,
  int? capacity,
}) => Offer(
  id: id,
  name: 'Offre $id',
  price: price,
  fulfilment: fulfilment,
  startsAt: startsAt,
  capacity: capacity,
);

void main() {
  test('une offre non choisie ne compte pas dans le total', () {
    final s = OfferSelection();
    final offers = [_offer('a'), _offer('b', price: 25)];

    s.setQuantity(offers[1], 2);

    expect(s.selectedFrom(offers).map((o) => o.id), ['b']);
    expect(s.totalFor(offers), 50);
  });

  test('ramener la quantité à zéro retire l\'offre', () {
    final s = OfferSelection();
    final offers = [_offer('a')];

    s.setQuantity(offers.first, 3);
    expect(s.totalFor(offers), 30);

    s.setQuantity(offers.first, 0);
    expect(s.selectedFrom(offers), isEmpty);
    expect(s.totalFor(offers), 0);
  });

  test('une offre datée impose sa date, on ne la demande pas', () {
    final s = OfferSelection();
    final seance = _offer(
      'seance',
      fulfilment: Fulfilment.booking,
      startsAt: DateTime(2026, 12, 24, 20),
      capacity: 80,
    );
    s.setQuantity(seance, 2);

    expect(s.needsDateChoice([seance]), isFalse);
    expect(s.effectiveDate([seance]), DateTime(2026, 12, 24, 20));
  });

  test('sans date imposée, c\'est celle de l\'utilisateur qui fait foi', () {
    final s = OfferSelection();
    final soin = _offer('soin', fulfilment: Fulfilment.booking);
    s.setQuantity(soin, 1);

    expect(s.needsDateChoice([soin]), isTrue);
    expect(s.effectiveDate([soin]), isNull);

    s.chosenDate = DateTime(2026, 11, 3, 15);
    expect(s.effectiveDate([soin]), DateTime(2026, 11, 3, 15));
  });

  test('aucune sélection : rien à réserver, rien à demander', () {
    final s = OfferSelection();
    final offers = [_offer('a', fulfilment: Fulfilment.booking)];

    expect(s.needsDateChoice(offers), isFalse);
    expect(() => s.submitBooking(offers: offers), throwsStateError);
  });
}
