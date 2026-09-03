import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Ce qu'on a demandé à un commerce : une commande, ou une réservation.
enum ActivityKind {
  order,
  booking;

  bool get isOrder => this == ActivityKind.order;
}

/// Une ligne du flux d'activité, quelle que soit son origine.
///
/// L'écran montrait deux onglets — « Commandes » et « Réservations » — et
/// obligeait donc à savoir, avant de chercher, dans lequel des deux ranger ce
/// qu'on cherche. Or on ne se souvient pas d'une catégorie : on se souvient
/// d'un commerce et d'un moment. Le flux est unique et chronologique ; la
/// nature de la demande devient une mention dans la ligne, pas une porte à
/// pousser.
///
/// Cette classe est le seul endroit qui traduit un [Order] ou une
/// [Reservation] en ce que la ligne affiche. Les widgets n'en connaissent
/// aucun des deux.
class ActivityEntry {
  const ActivityEntry({
    required this.kind,
    required this.id,
    required this.businessId,
    required this.businessName,
    required this.happenedAt,
    required this.summary,
    required this.statusLabel,
    required this.statusIcon,
    required this.statusNote,
    required this.step,
    required this.stepCount,
    required this.total,
    required this.isSettled,
    required this.isCancelled,
    this.order,
    this.reservation,
  });

  final ActivityKind kind;
  final String id;
  final String? businessId;
  final String businessName;

  /// Sert au tri et au regroupement par date.
  final DateTime happenedAt;

  /// La deuxième ligne : « Commande · 3 articles · 42,00 $ ».
  final String summary;

  final String statusLabel;
  final IconData statusIcon;

  /// Ce que le statut implique, quand il ne se suffit pas — « le commerçant
  /// doit confirmer ». `null` quand le libellé parle de lui-même.
  final String? statusNote;

  /// Où en est la demande, et sur combien d'étapes. Une commande en compte
  /// cinq, une réservation trois.
  final int step;
  final int stepCount;

  final double total;

  /// Plus rien ne bougera : livrée, honorée, annulée. Ces lignes s'effacent
  /// visuellement au lieu de disparaître — on veut pouvoir les retrouver.
  final bool isSettled;

  final bool isCancelled;

  final Order? order;
  final Reservation? reservation;

  /// Le code à présenter au commerce.
  ///
  /// **Huit chiffres**, groupés par quatre. Il mêlait lettres et chiffres, ce
  /// qui obligeait à l'épeler au comptoir — et à distinguer un O d'un zéro.
  /// Un nombre se dit, se retient et se saisit sur un pavé numérique.
  ///
  /// Dérivé de l'identifiant, donc stable et reproductible d'un affichage à
  /// l'autre. La nature de la demande entre dans le calcul : une commande et
  /// une réservation ne peuvent pas tomber sur le même code. **Rien ne le
  /// vérifie côté serveur pour l'instant** : il tient lieu de référence
  /// lisible, pas de preuve.
  String get code {
    var hash = kind.isOrder ? 17 : 29;
    for (final unit in id.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    final digits = (hash % 100000000).toString().padLeft(8, '0');
    return '${digits.substring(0, 4)} ${digits.substring(4)}';
  }

  /// Ce que le QR encode. Un identifiant réel, pour qu'un scanner futur ait
  /// quelque chose à interroger.
  String get qrPayload => 'baobabe:${kind.isOrder ? 'order' : 'booking'}:$id';

  String get reference =>
      '${kind.isOrder ? 'COMMANDE' : 'RÉSERVATION'} · $code';

  /// Une commande en attente ou en cours peut encore être annulée par le
  /// client ; au-delà cela se règle avec le commerçant.
  bool get canCancel => !isSettled;

  // ---------------------------------------------------------------- Order

  factory ActivityEntry.fromOrder(Order order) {
    final count = order.items.fold<int>(0, (sum, i) => sum + i.quantity);
    final settled =
        order.status == OrderStatus.delivered ||
        order.status == OrderStatus.cancelled;

    return ActivityEntry(
      kind: ActivityKind.order,
      id: order.id,
      businessId: order.establishmentId,
      businessName: order.establishmentName,
      happenedAt: order.orderDate,
      summary:
          'Commande · $count article${count > 1 ? 's' : ''} · '
          '${_money(order.totalAmount)}',
      statusLabel: order.status.displayName,
      statusIcon: _orderIcon(order.status),
      statusNote: order.status == OrderStatus.pending
          ? 'Le commerçant doit accepter'
          : null,
      step: _orderStep(order.status),
      stepCount: 5,
      total: order.totalAmount,
      isSettled: settled,
      isCancelled: order.status == OrderStatus.cancelled,
      order: order,
    );
  }

  static int _orderStep(OrderStatus status) => switch (status) {
    OrderStatus.pending => 1,
    OrderStatus.confirmed => 2,
    OrderStatus.preparing => 3,
    OrderStatus.ready => 4,
    OrderStatus.delivered => 5,
    OrderStatus.cancelled => 0,
  };

  static IconData _orderIcon(OrderStatus status) => switch (status) {
    OrderStatus.pending => Icons.hourglass_empty_rounded,
    OrderStatus.confirmed => Icons.check_rounded,
    OrderStatus.preparing => Icons.local_fire_department_outlined,
    OrderStatus.ready => Icons.shopping_bag_outlined,
    OrderStatus.delivered => Icons.check_circle_rounded,
    OrderStatus.cancelled => Icons.cancel_outlined,
  };

  // ---------------------------------------------------------- Reservation

  factory ActivityEntry.fromReservation(Reservation reservation) {
    final status = reservation.status.toLowerCase();
    final settled = status == 'completed' || status == 'cancelled';
    final when = DateFormat(
      'EEE d MMM, HH:mm',
      'fr_FR',
    ).format(reservation.reservationDate);

    return ActivityEntry(
      kind: ActivityKind.booking,
      id: reservation.id,
      businessId: reservation.businessId,
      businessName: reservation.establishmentName,
      // La date de création, et non celle de la réservation : le flux est
      // l'historique de ce qu'on a demandé, pas un agenda.
      happenedAt: reservation.createdAt ?? reservation.reservationDate,
      summary: 'Réservation · $when · ${_money(reservation.totalAmount)}',
      statusLabel: _bookingLabel(status),
      statusIcon: _bookingIcon(status),
      statusNote: status == 'pending' ? 'Le commerçant doit confirmer' : null,
      step: _bookingStep(status),
      stepCount: 3,
      total: reservation.totalAmount,
      isSettled: settled,
      isCancelled: status == 'cancelled',
      reservation: reservation,
    );
  }

  static String _bookingLabel(String status) => switch (status) {
    'confirmed' => 'Confirmée',
    'cancelled' => 'Annulée',
    'completed' => 'Honorée',
    _ => 'En attente',
  };

  static int _bookingStep(String status) => switch (status) {
    'confirmed' => 2,
    'completed' => 3,
    'cancelled' => 0,
    _ => 1,
  };

  static IconData _bookingIcon(String status) => switch (status) {
    'confirmed' => Icons.event_available_rounded,
    'cancelled' => Icons.cancel_outlined,
    'completed' => Icons.check_circle_rounded,
    _ => Icons.hourglass_empty_rounded,
  };

  static String _money(double amount) =>
      '${amount.toStringAsFixed(2).replaceAll('.', ',')} \$';
}

/// Un paquet de lignes : ce qui est en cours, ou un même repère de temps.
class ActivityGroup {
  const ActivityGroup({required this.label, required this.entries});

  /// Le libellé du premier groupe, celui qui échappe à la chronologie.
  static const String ongoingLabel = 'En cours';

  final String label;
  final List<ActivityEntry> entries;

  /// **Ce qui est en cours d'abord, l'historique ensuite.**
  ///
  /// Le flux était purement chronologique, et une commande de la semaine
  /// dernière que le commerçant n'a pas encore honorée se retrouvait donc
  /// enterrée sous les repas d'hier. Or c'est exactement la ligne qu'on
  /// vient voir : celle qui attend quelque chose. Elle remonte en tête,
  /// sous son propre repère, quelle que soit sa date.
  ///
  /// Le reste garde les repères dont on se sert en parlant — « hier »,
  /// « cette semaine » — et non des dates : personne ne cherche sa commande
  /// au 28 août, on la cherche « la semaine dernière ».
  static List<ActivityGroup> from(List<ActivityEntry> entries) {
    final sorted = [...entries]
      ..sort((a, b) => b.happenedAt.compareTo(a.happenedAt));

    // Une ligne annulée est réglée : elle n'attend rien, elle appartient à
    // l'historique.
    final ongoing = sorted.where((e) => !e.isSettled).toList();

    final byDate = <String, List<ActivityEntry>>{};
    for (final entry in sorted.where((e) => e.isSettled)) {
      byDate.putIfAbsent(_labelFor(entry.happenedAt), () => []).add(entry);
    }

    return [
      if (ongoing.isNotEmpty)
        ActivityGroup(label: ongoingLabel, entries: ongoing),
      for (final e in byDate.entries)
        ActivityGroup(label: e.key, entries: e.value),
    ];
  }

  static String _labelFor(DateTime moment) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(moment.year, moment.month, moment.day);
    final days = today.difference(day).inDays;

    if (days <= 0) return 'Aujourd\'hui';
    if (days == 1) return 'Hier';
    if (days < 7) return 'Cette semaine';
    if (days < 30) return 'Ce mois-ci';
    return DateFormat('MMMM yyyy', 'fr_FR').format(moment);
  }
}
