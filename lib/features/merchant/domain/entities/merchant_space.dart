import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_extras.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order_parsing_utils.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order_status.dart';
import 'package:equatable/equatable.dart';

part 'merchant_space_stats.dart';

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
/// Un instant venu du serveur, ramené à l'heure de l'appareil.
///
/// Postgres rend « 2026-09-07T10:00:00+00:00 » et `DateTime.tryParse` en fait
/// un `DateTime` **en UTC** : formaté tel quel, un rendez-vous pris à 11 h à
/// Kinshasa s'affichait 10 h dans l'agenda du commerçant, une heure avant
/// l'heure que le client avait choisie. Le reste de l'application convertit
/// à l'affichage ; ici on convertit à la lecture, une fois, pour que tous
/// les écrans de l'espace commerçant parlent de la même heure.
DateTime? _instant(Object? raw) =>
    DateTime.tryParse(raw?.toString() ?? '')?.toLocal();

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
      createdAt: _instant(json['created_at']),
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
      createdAt: _instant(json['created_at']),
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
      date: _instant(json['reservation_date']),
      customer: Customer.fromJson(json['customer']),
    );
  }

  @override
  List<Object?> get props => [id, status, itemName, quantity, date, customer];
}
