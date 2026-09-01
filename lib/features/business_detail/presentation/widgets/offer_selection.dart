import 'package:baobabe_0_2/features/booking_page/data/models/reservation_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
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

  double totalFor(List<Offer> offers) =>
      selectedFrom(offers).fold(0, (sum, o) => sum + o.price * quantityOf(o));

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
    required String businessId,
    required List<Offer> offers,
    required String userId,
    String? deliveryAddress,
    OrderApiService? service,
  }) {
    final selected = selectedFrom(offers);
    return (service ?? OrderApiService()).createOrder(
      userId: userId,
      businessId: businessId,
      deliveryAddress: deliveryAddress,
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

  /// Enregistre la réservation de l'offre sélectionnée.
  ///
  /// On réserve *une* chose (un concert, une table, un soin) alors qu'on
  /// commande *plusieurs* articles : garder une seule offre par
  /// réservation rend le décompte des places exact, ce qu'un panier
  /// multi-offres aurait rendu approximatif.
  ///
  /// Le montant n'est pas transmis : le serveur le calcule, vérifie qu'il
  /// reste des places et refuse une date passée.
  Future<void> submitBooking({
    required List<Offer> offers,
    String? contactPhone,
    ReservationApiService? service,
  }) {
    final selected = selectedFrom(offers);
    if (selected.isEmpty) {
      throw StateError('Aucune offre sélectionnée');
    }
    final offer = selected.first;

    return (service ?? ReservationApiService()).createReservation(
      offerId: offer.id,
      quantity: quantityOf(offer),
      reservationDate: offer.hasFixedDate ? null : chosenDate,
      // Le numéro voyage dans `details` : c'est le champ libre de la
      // réservation, et le client peut refuser de le donner.
      details: contactPhone == null ? null : {'contactPhone': contactPhone},
    );
  }
}
