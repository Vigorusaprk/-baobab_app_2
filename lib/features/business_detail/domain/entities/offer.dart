import 'package:equatable/equatable.dart';

/// Manière d'acquérir une offre. C'est la seule distinction structurante de
/// la plateforme : on **commande** un produit (pizza, cosmétique), on
/// **réserve** une place ou un créneau (table, séance, concert, soin), ou
/// l'offre est simplement **disponible en boutique** — elle se voit dans
/// l'application, elle se prend sur place.
enum Fulfilment {
  order,
  booking,
  inStore;

  static Fulfilment fromJson(String? value) {
    switch (value) {
      case 'order':
        return Fulfilment.order;
      case 'in_store':
        return Fulfilment.inStore;
      default:
        return Fulfilment.booking;
    }
  }

  String get asJson => this == Fulfilment.inStore ? 'in_store' : name;

  /// Ce que l'utilisateur peut en faire, dit en deux mots sur une carte.
  String get badge {
    switch (this) {
      case Fulfilment.order:
        return 'À commander';
      case Fulfilment.booking:
        return 'À réserver';
      case Fulfilment.inStore:
        return 'En boutique';
    }
  }

  /// La valeur attendue par l'API (`fulfilment` en base et dans get-home).
  String get apiValue {
    switch (this) {
      case Fulfilment.order:
        return 'order';
      case Fulfilment.booking:
        return 'booking';
      case Fulfilment.inStore:
        return 'in_store';
    }
  }
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

  /// Note de l'offre elle-même, moyenne des avis la visant. La note d'un
  /// commerçant découle de celles de ses offres.
  final double rating;
  final int reviewCount;

  /// Chez qui l'offre est proposée. Renseigné quand l'offre est affichée
  /// hors de la fiche du commerçant — sur l'accueil, une carte d'offre doit
  /// pouvoir dire d'où elle vient.
  final String? businessId;
  final String? businessName;
  final String? businessType;
  final String? businessImage;

  /// Depuis quand l'offre est publiée, pour la section « Nouveautés ».
  final DateTime? createdAt;

  /// Une offre retirée par le commerçant reste en base — les commandes
  /// passées la référencent — mais disparaît du catalogue. Seul l'espace
  /// commerçant la voit encore.
  final bool isActive;

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
    this.rating = 0,
    this.reviewCount = 0,
    this.businessId,
    this.businessName,
    this.businessType,
    this.businessImage,
    this.createdAt,
    this.isActive = true,
  });

  bool get isOrderable => fulfilment == Fulfilment.order;
  bool get isBookable => fulfilment == Fulfilment.booking;

  /// Ni commande ni réservation : l'offre se trouve sur place. Rien à
  /// valider dans l'application, donc aucun bouton d'achat.
  bool get isInStoreOnly => fulfilment == Fulfilment.inStore;

  /// Une offre datée impose sa date ; sinon le client choisit la sienne.
  bool get hasFixedDate => startsAt != null;

  bool get isFree => price <= 0;

  /// Visuel à afficher : celui de l'offre, à défaut celui du commerçant —
  /// une carte sans image serait un trou dans la liste.
  String? get displayImage {
    final own = imageUrl;
    if (own != null && own.isNotEmpty) return own;
    final fallback = businessImage;
    return (fallback != null && fallback.isNotEmpty) ? fallback : null;
  }

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
      price:
          (json['price'] as num?)?.toDouble() ??
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
      rating:
          (json['rating'] as num?)?.toDouble() ??
          double.tryParse(json['rating']?.toString() ?? '') ??
          0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      businessId:
          json['business_id']?.toString() ??
          (json['business'] is Map
              ? (json['business'] as Map)['id']?.toString()
              : null),
      businessName: json['business'] is Map
          ? (json['business'] as Map)['name']?.toString()
          : json['business_name']?.toString(),
      businessType: json['business'] is Map
          ? (json['business'] as Map)['type']?.toString()
          : json['business_type']?.toString(),
      businessImage: json['business'] is Map
          ? (json['business'] as Map)['bgImg']?.toString()
          : null,
      createdAt: parseDate(json['created_at']),
      isActive: json['is_active'] as bool? ?? true,
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
    rating,
    reviewCount,
    businessId,
    isActive,
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

  /// Le commerçant expose au moins une offre à retrouver sur place.
  final bool hasInStore;

  final int orderableCount;
  final int bookableCount;
  final int inStoreCount;

  const BusinessCapabilities({
    this.canOrder = false,
    this.canBook = false,
    this.hasInStore = false,
    this.orderableCount = 0,
    this.bookableCount = 0,
    this.inStoreCount = 0,
  });

  bool get hasAny => canOrder || canBook || hasInStore;

  factory BusinessCapabilities.fromJson(Map<String, dynamic> json) {
    return BusinessCapabilities(
      canOrder: json['canOrder'] == true,
      canBook: json['canBook'] == true,
      hasInStore: json['hasInStore'] == true,
      orderableCount: (json['orderableCount'] as num?)?.toInt() ?? 0,
      bookableCount: (json['bookableCount'] as num?)?.toInt() ?? 0,
      inStoreCount: (json['inStoreCount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    canOrder,
    canBook,
    hasInStore,
    orderableCount,
    bookableCount,
    inStoreCount,
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
