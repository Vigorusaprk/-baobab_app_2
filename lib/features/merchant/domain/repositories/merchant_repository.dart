import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_space.dart';

/// Ce que l'application sait faire du côté commerçant.
///
/// Une seule lecture ([getSpace]) rapporte tout l'espace : le commerce, les
/// offres, les commandes et les réservations reçues. Les écritures sont
/// volontairement granulaires et renvoient `void` — l'écran recharge
/// l'espace derrière, plutôt que de recoller un état local qui divergerait
/// de la base au premier oubli.
abstract class MerchantRepository {
  Future<MerchantSpace> getSpace();

  /// Dépose la demande de compte commerçant. Renvoie l'espace tel qu'il est
  /// juste après : le serveur accepte pour l'instant à la volée, donc le
  /// commerce est déjà là.
  Future<MerchantSpace> apply({
    required String businessName,
    required String categorySlug,
    required String address,
    required String phone,
    String? description,
  });

  Future<void> createOffer(OfferDraft draft);

  Future<void> updateOffer(String offerId, OfferDraft draft);

  /// Retire l'offre du catalogue sans la supprimer : les commandes déjà
  /// passées la référencent.
  Future<void> setOfferActive(String offerId, bool isActive);

  Future<void> updateOrderStatus(String orderId, String status);

  Future<void> updateReservationStatus(String reservationId, String status);
}

/// Les champs qu'un commerçant saisit pour publier ou modifier une offre.
///
/// Distinct de [Offer] : une offre existante porte aussi sa note, son
/// commerce et ses compteurs, qui ne se saisissent pas.
class OfferDraft {
  final String name;
  final String description;
  final double price;
  final Fulfilment fulfilment;
  final String? section;
  final int? capacity;
  final DateTime? startsAt;
  final String? imageUrl;
  final String? categorySlug;

  const OfferDraft({
    required this.name,
    required this.fulfilment,
    this.description = '',
    this.price = 0,
    this.section,
    this.capacity,
    this.startsAt,
    this.imageUrl,
    this.categorySlug,
  });

  /// Pré-remplit le formulaire à partir d'une offre existante.
  factory OfferDraft.from(Offer offer) {
    return OfferDraft(
      name: offer.name,
      description: offer.description,
      price: offer.price,
      fulfilment: offer.fulfilment,
      section: offer.section,
      capacity: offer.capacity,
      startsAt: offer.startsAt,
      imageUrl: offer.imageUrl,
    );
  }

  Map<String, dynamic> toBody() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'fulfilment': fulfilment.asJson,
      'section': section,
      'capacity': capacity,
      'startsAt': startsAt?.toUtc().toIso8601String(),
      'imageUrl': imageUrl,
      if (categorySlug != null) 'categorySlug': categorySlug,
    };
  }
}

/// Erreur métier renvoyée par l'espace commerçant, déjà rédigée pour
/// l'utilisateur.
///
/// Les Edge Functions répondent en français et parlent du métier
/// (« Vous gérez déjà un commerce ») : ces messages sont faits pour être
/// montrés, pas remplacés par un « une erreur est survenue ».
class MerchantException implements Exception {
  final String message;
  const MerchantException(this.message);

  @override
  String toString() => message;
}
