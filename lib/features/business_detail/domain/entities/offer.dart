import 'package:equatable/equatable.dart';

/// Manière d'acquérir une offre. C'est la seule distinction structurante de
/// la plateforme : on **commande** un produit (pizza, cosmétique), on
/// **réserve** une place ou un créneau (table, séance, concert, soin).
enum Fulfilment {
  order,
  booking;

  static Fulfilment fromJson(String? value) =>
      value == 'order' ? Fulfilment.order : Fulfilment.booking;

  String get asJson => name;
}

/// Une offre publiée par un commerçant.
///
/// Modèle unique : un plat, une chambre, un véhicule, un soin, une séance,
/// un concert ou un produit sont la même chose vue d'ici. Ce qui les
/// distingue tient dans [fulfilment] et dans les champs optionnels
/// ([startsAt] pour une offre datée, [capacity] pour un nombre de places).
class Offer extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final double price;
  final String currency;
  final Fulfilment fulfilment;

  /// Regroupement interne au catalogue du commerçant (Entrées, Chambres,
  /// Séances...). Sert uniquement à ordonner l'affichage.
  final String? section;

  /// Places disponibles, quand le commerçant en déclare.
  final int? capacity;

  /// Renseigné pour une offre à date fixe (séance, concert). Vide quand
  /// c'est le client qui choisit sa date (chambre, table, soin).
  final DateTime? startsAt;
  final DateTime? endsAt;

  final Map<String, dynamic> metadata;

  const Offer({
    required this.id,
    required this.name,
    this.description = '',
    this.imageUrl,
    this.price = 0,
    this.currency = 'USD',
    required this.fulfilment,
    this.section,
    this.capacity,
    this.startsAt,
    this.endsAt,
    this.metadata = const {},
  });

  bool get isOrderable => fulfilment == Fulfilment.order;
  bool get isBookable => fulfilment == Fulfilment.booking;

  /// Une offre datée impose sa date ; sinon le client choisit la sienne.
  bool get hasFixedDate => startsAt != null;

  bool get isFree => price <= 0;

  factory Offer.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(Object? value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return Offer(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      price: (json['price'] as num?)?.toDouble() ??
          double.tryParse(json['price']?.toString() ?? '') ??
          0,
      currency: json['currency']?.toString() ?? 'USD',
      fulfilment: Fulfilment.fromJson(json['fulfilment']?.toString()),
      section: json['section']?.toString(),
      capacity: (json['capacity'] as num?)?.toInt(),
      startsAt: parseDate(json['starts_at']),
      endsAt: parseDate(json['ends_at']),
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : const {},
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    imageUrl,
    price,
    currency,
    fulfilment,
    section,
    capacity,
    startsAt,
    endsAt,
  ];
}

/// Ce qu'un utilisateur peut réellement faire chez un commerçant.
///
/// Calculé côté serveur à partir des offres publiées, et non déduit du type
/// de commerce : c'est ce qui permet à n'importe quelle catégorie de
/// fonctionner sans code dédié, et surtout ce qui évite d'afficher un
/// bouton qui ne mène nulle part.
class BusinessCapabilities extends Equatable {
  final bool canOrder;
  final bool canBook;
  final int orderableCount;
  final int bookableCount;

  const BusinessCapabilities({
    this.canOrder = false,
    this.canBook = false,
    this.orderableCount = 0,
    this.bookableCount = 0,
  });

  bool get hasAny => canOrder || canBook;

  factory BusinessCapabilities.fromJson(Map<String, dynamic> json) {
    return BusinessCapabilities(
      canOrder: json['canOrder'] == true,
      canBook: json['canBook'] == true,
      orderableCount: (json['orderableCount'] as num?)?.toInt() ?? 0,
      bookableCount: (json['bookableCount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    canOrder,
    canBook,
    orderableCount,
    bookableCount,
  ];
}

/// Catalogue d'un commerçant : ses offres et ce qu'elles permettent.
class BusinessCatalogue extends Equatable {
  final List<Offer> offers;
  final BusinessCapabilities capabilities;

  const BusinessCatalogue({
    this.offers = const [],
    this.capabilities = const BusinessCapabilities(),
  });

  List<Offer> get orderable =>
      offers.where((o) => o.isOrderable).toList(growable: false);

  List<Offer> get bookable =>
      offers.where((o) => o.isBookable).toList(growable: false);

  @override
  List<Object?> get props => [offers, capabilities];
}
