import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_extras.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order_parsing_utils.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order_status.dart';
import 'package:equatable/equatable.dart';

/// État de la demande d'un utilisateur pour devenir commerçant.
///
/// `approved` est aujourd'hui immédiat : tant qu'il n'existe pas de panneau
/// d'administration, le serveur accepte la demande à la volée. Les trois
/// états existent quand même côté client, pour que l'arrivée d'une
/// modération ne demande aucune reprise de l'interface.
enum ApplicationStatus {
  pending,
  approved,
  rejected;

  static ApplicationStatus fromJson(String? value) {
    switch (value) {
      case 'approved':
        return ApplicationStatus.approved;
      case 'rejected':
        return ApplicationStatus.rejected;
      default:
        return ApplicationStatus.pending;
    }
  }
}

/// Demande de compte commerçant déposée par l'utilisateur.
class MerchantApplication extends Equatable {
  final String id;
  final String businessName;
  final ApplicationStatus status;

  /// Motif renseigné lors de la décision — la raison d'un refus, ou la
  /// mention d'acceptation automatique.
  final String? reviewNote;
  final DateTime? createdAt;

  const MerchantApplication({
    required this.id,
    required this.businessName,
    required this.status,
    this.reviewNote,
    this.createdAt,
  });

  factory MerchantApplication.fromJson(Map<String, dynamic> json) {
    return MerchantApplication(
      id: json['id']?.toString() ?? '',
      businessName: json['business_name']?.toString() ?? '',
      status: ApplicationStatus.fromJson(json['status']?.toString()),
      reviewNote: json['review_note']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  @override
  List<Object?> get props => [id, businessName, status, reviewNote, createdAt];
}

/// Qui a passé la commande ou la réservation.
///
/// Le commerçant ne voit que ses propres clients : une policy en base
/// n'ouvre les fiches qu'aux personnes ayant commandé ou réservé chez lui.
class Customer extends Equatable {
  final String name;
  final String? phone;

  const Customer({required this.name, this.phone});

  static Customer? fromJson(Object? json) {
    if (json is! Map) return null;
    final name = json['name']?.toString();
    if (name == null || name.isEmpty) return null;
    return Customer(name: name, phone: json['phone']?.toString());
  }

  @override
  List<Object?> get props => [name, phone];
}

/// Une ligne d'une commande reçue.
class ReceivedOrderLine extends Equatable {
  final String name;
  final int quantity;
  final double price;

  const ReceivedOrderLine({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory ReceivedOrderLine.fromJson(Map<String, dynamic> json) {
    return ReceivedOrderLine(
      name: json['item_name']?.toString() ?? 'Article',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object?> get props => [name, quantity, price];
}

/// Une commande vue du côté de celui qui doit la préparer.
class ReceivedOrder extends Equatable {
  final String id;
  final OrderStatus status;
  final double total;
  final DateTime? createdAt;
  final String? notes;
  final Customer? customer;
  final List<ReceivedOrderLine> lines;

  const ReceivedOrder({
    required this.id,
    required this.status,
    required this.total,
    this.createdAt,
    this.notes,
    this.customer,
    this.lines = const [],
  });

  factory ReceivedOrder.fromJson(Map<String, dynamic> json) {
    final items = (json['order_items'] as List?) ?? const [];
    return ReceivedOrder(
      id: json['id']?.toString() ?? '',
      status: parseOrderStatus(json['status']),
      total:
          (json['total_amount'] as num?)?.toDouble() ??
          (json['total_price'] as num?)?.toDouble() ??
          0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      notes: json['notes']?.toString(),
      customer: Customer.fromJson(json['customer']),
      lines: items
          .map((e) => ReceivedOrderLine.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, status, total, createdAt, customer, lines];
}

/// Où en est une réservation reçue.
enum ReservationStatus {
  pending,
  confirmed,
  cancelled,
  completed;

  static ReservationStatus fromJson(String? value) {
    switch (value) {
      case 'confirmed':
        return ReservationStatus.confirmed;
      case 'cancelled':
        return ReservationStatus.cancelled;
      case 'completed':
        return ReservationStatus.completed;
      default:
        return ReservationStatus.pending;
    }
  }

  String get asJson => name;

  String get label {
    switch (this) {
      case ReservationStatus.pending:
        return 'À confirmer';
      case ReservationStatus.confirmed:
        return 'Confirmée';
      case ReservationStatus.cancelled:
        return 'Annulée';
      case ReservationStatus.completed:
        return 'Honorée';
    }
  }
}

/// Une réservation vue du côté de celui qui doit l'honorer.
class ReceivedReservation extends Equatable {
  final String id;
  final ReservationStatus status;
  final String itemName;
  final int quantity;
  final double total;
  final DateTime? date;
  final Customer? customer;

  const ReceivedReservation({
    required this.id,
    required this.status,
    required this.itemName,
    this.quantity = 1,
    this.total = 0,
    this.date,
    this.customer,
  });

  factory ReceivedReservation.fromJson(Map<String, dynamic> json) {
    return ReceivedReservation(
      id: json['id']?.toString() ?? '',
      status: ReservationStatus.fromJson(json['status']?.toString()),
      itemName: json['item_name']?.toString() ?? 'Réservation',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      total: (json['total_amount'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse(json['reservation_date']?.toString() ?? ''),
      customer: Customer.fromJson(json['customer']),
    );
  }

  @override
  List<Object?> get props => [id, status, itemName, quantity, date, customer];
}

/// Les chiffres du tableau de bord, calculés par le serveur.
///
/// Aucun n'est recalculé côté client : en tenir une seconde version, ce
/// serait deux vérités pour une même chose.
class MerchantStats extends Equatable {
  final int offerCount;
  final int pendingOrders;
  final int pendingReservations;
  final int upcomingReservations;

  /// Ce qui a effectivement été encaissé : les commandes prêtes ou livrées.
  final double revenue;

  /// Ce que les fiches ont fait sur trente jours. Sans ces deux nombres, une
  /// campagne n'a aucun résultat à montrer.
  final int views;
  final int clicks;

  final int runningCampaigns;

  const MerchantStats({
    this.offerCount = 0,
    this.pendingOrders = 0,
    this.pendingReservations = 0,
    this.upcomingReservations = 0,
    this.revenue = 0,
    this.views = 0,
    this.clicks = 0,
    this.runningCampaigns = 0,
  });

  factory MerchantStats.fromJson(Map<String, dynamic> json) {
    int asInt(Object? v) => (v as num?)?.toInt() ?? 0;
    return MerchantStats(
      offerCount: asInt(json['offerCount']),
      pendingOrders: asInt(json['pendingOrders']),
      pendingReservations: asInt(json['pendingReservations']),
      upcomingReservations: asInt(json['upcomingReservations']),
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      views: asInt(json['views']),
      clicks: asInt(json['clicks']),
      runningCampaigns: asInt(json['runningCampaigns']),
    );
  }

  /// Ce qui attend une réponse du commerçant, tous types confondus.
  int get pending => pendingOrders + pendingReservations;

  @override
  List<Object?> get props => [
    offerCount,
    pendingOrders,
    pendingReservations,
    upcomingReservations,
    revenue,
    views,
    clicks,
    runningCampaigns,
  ];
}

/// Tout ce que le commerçant gère, en une réponse.
///
/// [business] à null est la réponse à « cet utilisateur est-il commerçant ? » :
/// non, et l'application reste alors du côté client.
class MerchantSpace extends Equatable {
  final Business? business;
  final String? role;
  final List<Offer> offers;
  final List<ReceivedOrder> orders;
  final List<ReceivedReservation> reservations;
  final MerchantStats stats;
  final MerchantApplication? application;

  /// Les campagnes du commerce, de la plus récente à la plus ancienne.
  final List<AdCampaign> campaigns;

  /// Trente jours de mesures, par jour et par offre.
  final List<DailyMetric> metrics;

  /// Combien de plages de rendez-vous chaque offre déclare. Le catalogue le
  /// montre sans avoir à interroger chaque offre une par une.
  final Map<String, int> availability;

  /// Ce compte administre-t-il la plateforme ? La réponse vient de la même
  /// lecture : l'application n'a pas à poser une seconde question au
  /// lancement pour savoir si un espace de plus existe.
  final bool isAdmin;

  const MerchantSpace({
    this.business,
    this.role,
    this.offers = const [],
    this.orders = const [],
    this.reservations = const [],
    this.stats = const MerchantStats(),
    this.application,
    this.campaigns = const [],
    this.metrics = const [],
    this.availability = const {},
    this.isAdmin = false,
  });

  bool get isMerchant => business != null;

  /// Les offres encore au catalogue, puis celles retirées : un commerçant
  /// travaille sur ce qui est en ligne, pas sur son historique.
  List<Offer> get activeOffers => offers.where((o) => o.isActive).toList();
  List<Offer> get retiredOffers => offers.where((o) => !o.isActive).toList();

  /// Les campagnes qui demandent un geste : à régler, ou en examen.
  List<AdCampaign> get openCampaigns =>
      campaigns.where((c) => !c.status.isOver).toList();

  @override
  List<Object?> get props => [
    business,
    role,
    offers,
    orders,
    reservations,
    stats,
    application,
    campaigns,
    metrics,
    availability,
    isAdmin,
  ];
}
