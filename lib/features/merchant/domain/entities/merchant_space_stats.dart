part of 'merchant_space.dart';

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
