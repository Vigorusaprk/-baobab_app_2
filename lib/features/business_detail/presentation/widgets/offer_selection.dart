import 'package:baobabe_0_2/features/booking_page/data/models/reservation_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order_item.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/order_service.dart';

/// Ce que l'utilisateur a sélectionné dans un catalogue, et comment le
/// transformer en commande ou en réservation.
///
/// Extrait de l'écran pour garder la logique hors du widget : la page se
/// contente d'afficher et de déléguer.
class OfferSelection {
  /// Quantité choisie par offre. Une offre absente n'est pas sélectionnée.
  final Map<String, int> quantities = {};

  /// Date choisie par l'utilisateur, pour les offres sans date imposée.
  DateTime? chosenDate;

  int quantityOf(Offer offer) => quantities[offer.id] ?? 0;

  void setQuantity(Offer offer, int quantity) {
    if (quantity <= 0) {
      quantities.remove(offer.id);
    } else {
      quantities[offer.id] = quantity;
    }
  }

  List<Offer> selectedFrom(List<Offer> offers) =>
      offers.where((o) => quantityOf(o) > 0).toList();

  double totalFor(List<Offer> offers) => selectedFrom(offers).fold(
    0,
    (sum, o) => sum + o.price * quantityOf(o),
  );

  /// Vrai quand aucune offre sélectionnée n'impose sa date : c'est alors à
  /// l'utilisateur d'en choisir une.
  bool needsDateChoice(List<Offer> offers) {
    final selected = selectedFrom(offers);
    return selected.isNotEmpty && selected.every((o) => !o.hasFixedDate);
  }

  /// Date retenue : celle de l'offre quand elle est imposée (séance,
  /// concert), sinon celle choisie par l'utilisateur.
  DateTime? effectiveDate(List<Offer> offers) {
    for (final offer in selectedFrom(offers)) {
      if (offer.startsAt != null) return offer.startsAt;
    }
    return chosenDate;
  }

  /// Passe la commande des offres sélectionnées.
  Future<void> submitOrder({
    required Business business,
    required List<Offer> offers,
    required String userId,
    OrderApiService? service,
  }) {
    final selected = selectedFrom(offers);
    return (service ?? OrderApiService()).createOrder(
      userId: userId,
      businessId: business.id,
      items: selected
          .map(
            (o) => OrderItem(
              menuItemId: o.id,
              name: o.name,
              price: o.price,
              quantity: quantityOf(o),
            ),
          )
          .toList(),
    );
  }

  /// Enregistre la réservation des offres sélectionnées.
  ///
  /// Le détail conserve chaque offre retenue, sa quantité et sa date : c'est
  /// ce qui permet à l'historique d'afficher une réservation lisible quelle
  /// que soit la catégorie, sans code par métier.
  Future<void> submitBooking({
    required Business business,
    required List<Offer> offers,
    ReservationApiService? service,
  }) {
    final selected = selectedFrom(offers);
    return (service ?? ReservationApiService()).createReservation(
      businessId: business.id,
      type: business.type.name,
      reservationDate: effectiveDate(offers) ?? DateTime.now(),
      totalAmount: totalFor(offers),
      establishmentName: business.name,
      details: {
        'offers': selected
            .map(
              (o) => {
                'offer_id': o.id,
                'name': o.name,
                'price': o.price,
                'quantity': quantityOf(o),
                if (o.startsAt != null)
                  'starts_at': o.startsAt!.toIso8601String(),
              },
            )
            .toList(),
      },
    );
  }
}
