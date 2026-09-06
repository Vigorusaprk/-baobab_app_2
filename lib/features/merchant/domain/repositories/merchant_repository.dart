import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer_availability.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_extras.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_space.dart';
import 'package:baobabe_0_2/features/settings/domain/entities/user_address.dart';

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
    required UserAddress address,
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

  /// Modifie la fiche du commerce. La catégorie n'en fait pas partie : elle
  /// décide du classement et des filtres de toute la plateforme.
  Future<void> updateBusiness(String businessId, BusinessDraft draft);

  /// Remplace d'un bloc les créneaux d'une offre.
  ///
  /// Remplacement et non fusion : le commerçant voit sa semaine à l'écran et
  /// l'envoie telle qu'elle est.
  Future<void> setAvailability({
    required String offerId,
    required int? durationMinutes,
    required int? slotCapacity,
    required List<AvailabilityRule> rules,
    required List<AvailabilityException> exceptions,
    int? leadTimeHours,
    int? horizonDays,
  });

  /// Les campagnes du commerce, la grille tarifaire, et — pour un
  /// administrateur — la file de ce qui attend un examen.
  Future<AdBoard> getCampaigns({String? businessId});

  /// Demande une mise en avant. Le montant n'est pas envoyé : le serveur le
  /// calcule depuis la grille.
  Future<void> createCampaign({
    required String businessId,
    required AdPlacement placement,
    required DateTime startsOn,
    required DateTime endsOn,
    String? offerId,
  });

  /// Fait avancer une campagne. Le serveur vérifie qui a le droit de
  /// demander quoi, et depuis quel état.
  Future<void> actOnCampaign(
    String campaignId,
    CampaignAction action, {
    double? amount,
    String? note,
  });
}

/// Ce qu'on peut demander à une campagne.
enum CampaignAction {
  /// Réservé à la plateforme : valide et fixe le montant.
  approve,

  /// Réservé à la plateforme : refuse, avec un motif obligatoire.
  reject,

  /// Le commerçant règle. Le paiement en ligne n'existe pas encore : ce
  /// geste vaut accord de règlement et lance la diffusion.
  pay,

  /// Le commerçant renonce.
  cancel;

  String get asJson => name;
}

/// Les campagnes, la grille, et la file d'examen : une seule lecture.
class AdBoard {
  const AdBoard({
    this.isAdmin = false,
    this.prices = const [],
    this.campaigns = const [],
    this.queue = const [],
    this.applications = const [],
  });

  final bool isAdmin;
  final List<AdPrice> prices;
  final List<AdCampaign> campaigns;

  /// Ce qui attend la plateforme. Vide pour un commerçant.
  final List<AdCampaign> queue;

  /// Les dernières demandes de compte commerçant. Elles sont acceptées
  /// automatiquement : la plateforme les regarde, elle ne les arbitre pas.
  final List<MerchantApplication> applications;

  /// Ce qui demande vraiment une décision.
  List<AdCampaign> get toReview =>
      queue.where((c) => c.status == CampaignStatus.inReview).toList();

  /// Le tarif d'un emplacement, ou zéro si la grille ne le connaît pas.
  double perDay(AdPlacement placement) => prices
      .firstWhere(
        (price) => price.placement == placement,
        orElse: () =>
            AdPrice(placement: placement, label: placement.label, usdPerDay: 0),
      )
      .usdPerDay;
}

/// Les champs de la fiche d'un commerce que son commerçant peut modifier.
///
/// Chaque champ est **facultatif** : ce qui n'est pas renseigné n'est pas
/// envoyé, et le serveur ne touche donc pas à ce que l'écran ne montrait pas.
class BusinessDraft {
  const BusinessDraft({
    this.name,
    this.description,
    this.coverImage,
    this.phone,
    this.email,
    this.website,
    this.openingHours,
    this.address,
    this.isPaused,
    this.pauseNote,
  });

  final String? name;
  final String? description;
  final String? coverImage;
  final String? phone;
  final String? email;
  final String? website;

  /// Jour en toutes lettres vers plage horaire : « Lundi » → « 09:00 - 18:00 ».
  final Map<String, String>? openingHours;

  final UserAddress? address;
  final bool? isPaused;
  final String? pauseNote;

  Map<String, dynamic> toBody() => {
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    if (coverImage != null) 'coverImage': coverImage,
    if (phone != null) 'phone': phone,
    if (email != null) 'email': email,
    if (website != null) 'website': website,
    if (openingHours != null) 'openingHours': openingHours,
    if (isPaused != null) 'isPaused': isPaused,
    if (pauseNote != null) 'pauseNote': pauseNote,
    // L'adresse part **en pièces** : le serveur la range dans ses six
    // colonnes et recompose lui-même la ligne d'affichage.
    if (address != null) ...address!.toJson(),
  };
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

  /// Une jauge de places et une date n'ont de sens que pour une
  /// réservation. Les neutraliser ici plutôt que dans le formulaire évite
  /// qu'un appelant distrait ne fasse réapparaître « il reste 2 places »
  /// sur un produit qu'on vient simplement chercher.
  bool get _isBookable => fulfilment == Fulfilment.booking;

  Map<String, dynamic> toBody() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'fulfilment': fulfilment.asJson,
      'section': section,
      'capacity': _isBookable ? capacity : null,
      'startsAt': _isBookable ? startsAt?.toUtc().toIso8601String() : null,
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
