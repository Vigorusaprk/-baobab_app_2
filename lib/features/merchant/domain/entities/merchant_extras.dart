import 'package:equatable/equatable.dart';

/// Les campagnes du commerçant, et ce que ses fiches ont fait.
///
/// Séparé de `merchant_space.dart`, qui portait déjà la moitié de la
/// fonctionnalité : un fichier de six cents lignes n'est plus une frontière,
/// c'est un dépotoir. Les créneaux, eux, vivent dans le domaine de l'offre —
/// le client les lit aussi.

// -------------------------------------------------------------- publicité

/// Où une campagne s'affiche.
enum AdPlacement {
  home,
  category,
  search;

  static AdPlacement fromJson(String? value) => switch (value) {
    'category' => AdPlacement.category,
    'search' => AdPlacement.search,
    _ => AdPlacement.home,
  };

  String get asJson => name;

  String get label => switch (this) {
    AdPlacement.home => 'Accueil',
    AdPlacement.category => 'Catégorie',
    AdPlacement.search => 'Recherche',
  };

  String get explanation => switch (this) {
    AdPlacement.home => "En tête de l'accueil, pour tout le monde.",
    AdPlacement.category => 'Dans votre catégorie, auprès de qui la filtre.',
    AdPlacement.search => 'Dans les résultats de recherche.',
  };
}

/// Le tarif d'un emplacement, fixé par la plateforme.
class AdPrice extends Equatable {
  const AdPrice({
    required this.placement,
    required this.label,
    required this.usdPerDay,
  });

  final AdPlacement placement;
  final String label;
  final double usdPerDay;

  factory AdPrice.fromJson(Map<String, dynamic> json) => AdPrice(
    placement: AdPlacement.fromJson(json['placement']?.toString()),
    label: json['label']?.toString() ?? '',
    usdPerDay: (json['usd_per_day'] as num?)?.toDouble() ?? 0,
  );

  @override
  List<Object?> get props => [placement, label, usdPerDay];
}

/// Où en est une campagne.
///
/// L'ordre des états est celui du cycle : demandée, examinée, réglée,
/// diffusée. Un refus et une annulation en sortent.
enum CampaignStatus {
  inReview,
  approved,
  running,
  finished,
  rejected,
  cancelled;

  static CampaignStatus fromJson(String? value) => switch (value) {
    'approved' => CampaignStatus.approved,
    'running' => CampaignStatus.running,
    'finished' => CampaignStatus.finished,
    'rejected' => CampaignStatus.rejected,
    'cancelled' => CampaignStatus.cancelled,
    _ => CampaignStatus.inReview,
  };

  String get label => switch (this) {
    CampaignStatus.inReview => 'En examen',
    CampaignStatus.approved => 'À régler',
    CampaignStatus.running => 'En diffusion',
    CampaignStatus.finished => 'Terminée',
    CampaignStatus.rejected => 'Refusée',
    CampaignStatus.cancelled => 'Annulée',
  };

  /// Ce que l'état implique, quand le libellé ne se suffit pas.
  String? get note => switch (this) {
    CampaignStatus.inReview => 'Baobabe examine votre demande.',
    CampaignStatus.approved => 'Réglez pour lancer la diffusion.',
    CampaignStatus.running => null,
    CampaignStatus.finished => null,
    CampaignStatus.rejected => null,
    CampaignStatus.cancelled => null,
  };

  bool get isLive => this == CampaignStatus.running;
  bool get isOver =>
      this == CampaignStatus.finished ||
      this == CampaignStatus.rejected ||
      this == CampaignStatus.cancelled;
}

/// Une mise en avant, demandée par un commerçant.
class AdCampaign extends Equatable {
  const AdCampaign({
    required this.id,
    required this.businessId,
    required this.placement,
    required this.startsOn,
    required this.endsOn,
    required this.status,
    required this.quotedAmount,
    this.amount,
    this.offerId,
    this.offerName,
    this.businessName,
    this.reviewNote,
    this.paidAt,
    this.createdAt,
  });

  final String id;
  final String businessId;
  final String? offerId;
  final String? offerName;
  final String? businessName;
  final AdPlacement placement;
  final DateTime startsOn;
  final DateTime endsOn;
  final CampaignStatus status;

  /// Le devis calculé à la demande. Gardé même si la grille change ensuite.
  final double quotedAmount;

  /// Ce que la plateforme a retenu. `null` tant qu'elle n'a pas tranché.
  final double? amount;

  final String? reviewNote;
  final DateTime? paidAt;
  final DateTime? createdAt;

  factory AdCampaign.fromJson(Map<String, dynamic> json) {
    final offer = json['offers'];
    final business = json['business'];
    return AdCampaign(
      id: json['id']?.toString() ?? '',
      businessId: json['business_id']?.toString() ?? '',
      offerId: json['offer_id']?.toString(),
      offerName: offer is Map ? offer['name']?.toString() : null,
      businessName: business is Map ? business['name']?.toString() : null,
      placement: AdPlacement.fromJson(json['placement']?.toString()),
      startsOn:
          DateTime.tryParse(json['starts_on']?.toString() ?? '') ??
          DateTime.now(),
      endsOn:
          DateTime.tryParse(json['ends_on']?.toString() ?? '') ??
          DateTime.now(),
      status: CampaignStatus.fromJson(json['status']?.toString()),
      quotedAmount: (json['quoted_amount'] as num?)?.toDouble() ?? 0,
      amount: (json['amount'] as num?)?.toDouble(),
      reviewNote: json['review_note']?.toString(),
      paidAt: DateTime.tryParse(json['paid_at']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  /// Ce qui sera réclamé : le montant retenu, à défaut le devis.
  double get dueAmount => amount ?? quotedAmount;

  int get days => endsOn.difference(startsOn).inDays + 1;

  /// Ce que la campagne pousse : une offre, ou le commerce entier.
  String get target => offerName ?? 'Tout le commerce';

  @override
  List<Object?> get props => [
    id,
    businessId,
    offerId,
    placement,
    startsOn,
    endsOn,
    status,
    quotedAmount,
    amount,
    reviewNote,
    paidAt,
  ];
}

// ---------------------------------------------------------------- mesures

/// Une journée de mesures, pour une offre ou pour le commerce entier.
class DailyMetric extends Equatable {
  const DailyMetric({
    required this.day,
    this.offerId,
    this.views = 0,
    this.clicks = 0,
  });

  final DateTime day;
  final String? offerId;
  final int views;
  final int clicks;

  factory DailyMetric.fromJson(Map<String, dynamic> json) => DailyMetric(
    day: DateTime.tryParse(json['day']?.toString() ?? '') ?? DateTime.now(),
    offerId: json['offer_id']?.toString(),
    views: (json['views'] as num?)?.toInt() ?? 0,
    clicks: (json['clicks'] as num?)?.toInt() ?? 0,
  );

  @override
  List<Object?> get props => [day, offerId, views, clicks];
}
