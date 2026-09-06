import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Ce qui s'est passé, du point de vue de celui qu'on prévient.
///
/// Le vocabulaire est celui de la contrainte `notifications_kind_check` en
/// base : les deux doivent rester d'accord. Une valeur inconnue retombe sur
/// [NotificationKind.other] plutôt que de faire échouer la lecture — une
/// version publiée avant l'ajout d'un genre doit continuer d'afficher la
/// liste, sans deviner ce qu'elle ne connaît pas.
enum NotificationKind {
  orderReceived,
  orderStatus,
  reservationReceived,
  reservationStatus,
  reviewReceived,
  campaignToReview,
  campaignStatus,
  applicationReceived,
  applicationDecided,
  other;

  static NotificationKind fromJson(String? raw) => switch (raw) {
    'order_received' => NotificationKind.orderReceived,
    'order_status' => NotificationKind.orderStatus,
    'reservation_received' => NotificationKind.reservationReceived,
    'reservation_status' => NotificationKind.reservationStatus,
    'review_received' => NotificationKind.reviewReceived,
    'campaign_to_review' => NotificationKind.campaignToReview,
    'campaign_status' => NotificationKind.campaignStatus,
    'application_received' => NotificationKind.applicationReceived,
    'application_decided' => NotificationKind.applicationDecided,
    _ => NotificationKind.other,
  };

  /// L'icône dit d'un coup d'œil de quoi il s'agit, avant même de lire le
  /// titre : une commande, un rendez-vous, un avis, une mise en avant.
  IconData get icon => switch (this) {
    NotificationKind.orderReceived ||
    NotificationKind.orderStatus => Icons.receipt_long_outlined,
    NotificationKind.reservationReceived ||
    NotificationKind.reservationStatus => Icons.event_available_outlined,
    NotificationKind.reviewReceived => Icons.star_outline_rounded,
    NotificationKind.campaignToReview ||
    NotificationKind.campaignStatus => Icons.campaign_outlined,
    NotificationKind.applicationReceived ||
    NotificationKind.applicationDecided => Icons.storefront_outlined,
    NotificationKind.other => Icons.notifications_none_rounded,
  };

  /// Ce que l'action promet. Nul quand la notification ne mène nulle part —
  /// un bouton qui n'ouvre rien vaut moins que pas de bouton.
  String? get actionLabel => switch (this) {
    NotificationKind.orderStatus => 'Voir la commande',
    NotificationKind.reservationStatus => 'Voir la réservation',
    NotificationKind.orderReceived ||
    NotificationKind.reservationReceived => 'Ouvrir les demandes',
    NotificationKind.reviewReceived => 'Voir mon commerce',
    NotificationKind.campaignToReview => 'Examiner',
    NotificationKind.campaignStatus => 'Voir la mise en avant',
    NotificationKind.applicationReceived => 'Ouvrir l\'administration',
    NotificationKind.applicationDecided => 'Ouvrir mon espace',
    NotificationKind.other => null,
  };
}

/// Une notification, telle qu'elle est en base.
///
/// C'est désormais la seule source : l'écran fabriquait ses lignes à partir
/// des commandes et des réservations du client, ce qui ne pouvait montrer ni
/// un avis reçu, ni une mise en avant validée, ni quoi que ce soit du côté
/// commerçant — et l'état « lu » ne survivait pas à la fermeture de
/// l'application, faute d'endroit pour l'écrire.
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.route,
    this.subjectType,
    this.subjectId,
    this.payload = const {},
    this.readAt,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final DateTime createdAt;

  /// Où mène la notification quand on la touche.
  final String? route;

  final String? subjectType;
  final String? subjectId;
  final Map<String, dynamic> payload;

  final DateTime? readAt;

  bool get isRead => readAt != null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      kind: NotificationKind.fromJson(json['kind']?.toString()),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      // À l'heure de l'appareil : le serveur rend de l'UTC, et une heure
      // affichée telle quelle décalerait tout le fil.
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      route: _text(json['route']),
      subjectType: _text(json['subject_type']),
      subjectId: _text(json['subject_id']),
      payload: json['payload'] is Map
          ? Map<String, dynamic>.from(json['payload'] as Map)
          : const {},
      readAt: DateTime.tryParse(json['read_at']?.toString() ?? '')?.toLocal(),
    );
  }

  static String? _text(Object? raw) {
    final value = raw?.toString();
    return value == null || value.isEmpty ? null : value;
  }

  AppNotification copyWith({DateTime? readAt}) => AppNotification(
    id: id,
    kind: kind,
    title: title,
    body: body,
    createdAt: createdAt,
    route: route,
    subjectType: subjectType,
    subjectId: subjectId,
    payload: payload,
    readAt: readAt ?? this.readAt,
  );

  @override
  List<Object?> get props => [
    id,
    kind,
    title,
    body,
    createdAt,
    route,
    subjectType,
    subjectId,
    readAt,
  ];
}

/// Une page du fil, et le nombre de non-lues — qui ne dépend pas de la page.
class NotificationPage extends Equatable {
  const NotificationPage({
    this.items = const [],
    this.hasMore = false,
    this.unread = 0,
  });

  final List<AppNotification> items;
  final bool hasMore;
  final int unread;

  @override
  List<Object?> get props => [items, hasMore, unread];
}
