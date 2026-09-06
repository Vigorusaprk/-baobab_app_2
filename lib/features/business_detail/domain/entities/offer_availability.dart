import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Les rendez-vous d'une offre : ce que le commerçant déclare, et ce qu'il
/// reste de libre.
///
/// Ces classes vivent dans le domaine de **l'offre** et non dans celui du
/// commerçant : le client les lit pour choisir son créneau, et faire dépendre
/// la fiche client du domaine commerçant inverserait la dépendance.

// --------------------------------------------------------------- créneaux

/// Une plage hebdomadaire pendant laquelle une offre accepte des
/// rendez-vous.
///
/// Le jour suit la convention ISO — 1 = lundi, 7 = dimanche — la même que
/// `DateTime.weekday`, pour qu'aucune conversion ne traîne entre la base et
/// l'écran.
class AvailabilityRule extends Equatable {
  const AvailabilityRule({
    required this.weekday,
    required this.startsAt,
    required this.endsAt,
    this.capacity,
  });

  final int weekday;
  final TimeOfDay startsAt;
  final TimeOfDay endsAt;

  /// `null` : on retient la capacité de l'offre.
  final int? capacity;

  factory AvailabilityRule.fromJson(Map<String, dynamic> json) {
    return AvailabilityRule(
      weekday: (json['weekday'] as num?)?.toInt() ?? 1,
      startsAt: parseTime(json['starts_at']?.toString()),
      endsAt: parseTime(json['ends_at']?.toString()),
      capacity: (json['capacity'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toBody() => {
    'weekday': weekday,
    'startsAt': formatTime(startsAt),
    'endsAt': formatTime(endsAt),
    'capacity': capacity,
  };

  AvailabilityRule copyWith({
    int? weekday,
    TimeOfDay? startsAt,
    TimeOfDay? endsAt,
    int? capacity,
  }) => AvailabilityRule(
    weekday: weekday ?? this.weekday,
    startsAt: startsAt ?? this.startsAt,
    endsAt: endsAt ?? this.endsAt,
    capacity: capacity ?? this.capacity,
  );

  @override
  List<Object?> get props => [weekday, startsAt, endsAt, capacity];
}

/// Ce qui contredit la règle hebdomadaire un jour précis.
class AvailabilityException extends Equatable {
  const AvailabilityException({
    required this.day,
    this.isClosed = true,
    this.startsAt,
    this.endsAt,
    this.reason,
  });

  final DateTime day;
  final bool isClosed;
  final TimeOfDay? startsAt;
  final TimeOfDay? endsAt;
  final String? reason;

  factory AvailabilityException.fromJson(Map<String, dynamic> json) {
    final open = json['is_closed'] == false;
    return AvailabilityException(
      day: DateTime.tryParse(json['day']?.toString() ?? '') ?? DateTime.now(),
      isClosed: !open,
      startsAt: open ? parseTime(json['starts_at']?.toString()) : null,
      endsAt: open ? parseTime(json['ends_at']?.toString()) : null,
      reason: json['reason']?.toString(),
    );
  }

  Map<String, dynamic> toBody() => {
    'day':
        '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}',
    'isClosed': isClosed,
    if (!isClosed)
      'startsAt': formatTime(startsAt ?? const TimeOfDay(hour: 9, minute: 0)),
    if (!isClosed)
      'endsAt': formatTime(endsAt ?? const TimeOfDay(hour: 17, minute: 0)),
    'reason': reason,
  };

  @override
  List<Object?> get props => [day, isClosed, startsAt, endsAt, reason];
}

/// Un créneau libre, tel que le serveur l'a calculé.
class OfferSlot extends Equatable {
  const OfferSlot({required this.at, required this.remaining});

  final DateTime at;
  final int remaining;

  factory OfferSlot.fromJson(Map<String, dynamic> json) {
    return OfferSlot(
      at:
          DateTime.tryParse(json['slot_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      remaining: (json['remaining'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [at, remaining];
}

/// La réponse de `get-offer-slots` : ce que l'offre déclare, et ce qui reste.
class OfferAvailability extends Equatable {
  const OfferAvailability({
    this.declaresSlots = false,
    this.durationMinutes,
    this.slotCapacity,
    this.leadTimeHours = 2,
    this.horizonDays = 60,
    this.slots = const [],
    this.rules = const [],
    this.exceptions = const [],
  });

  /// `false` : l'offre ne déclare rien et le client garde le choix libre de
  /// sa date. C'est ce qui permet aux offres publiées avant les créneaux de
  /// continuer à fonctionner sans que personne ne les reprenne.
  final bool declaresSlots;

  final int? durationMinutes;
  final int? slotCapacity;
  final int leadTimeHours;
  final int horizonDays;
  final List<OfferSlot> slots;
  final List<AvailabilityRule> rules;
  final List<AvailabilityException> exceptions;

  factory OfferAvailability.fromJson(Map<String, dynamic> json) {
    List<T> parse<T>(String key, T Function(Map<String, dynamic>) build) {
      final list = (json[key] as List?) ?? const [];
      return list
          .map((e) => build(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return OfferAvailability(
      declaresSlots: json['declaresSlots'] == true,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      slotCapacity: (json['slotCapacity'] as num?)?.toInt(),
      leadTimeHours: (json['leadTimeHours'] as num?)?.toInt() ?? 2,
      horizonDays: (json['horizonDays'] as num?)?.toInt() ?? 60,
      slots: parse('slots', OfferSlot.fromJson),
      rules: parse('rules', AvailabilityRule.fromJson),
      exceptions: parse('exceptions', AvailabilityException.fromJson),
    );
  }

  /// Les créneaux d'un jour donné.
  List<OfferSlot> slotsOn(DateTime day) => slots
      .where(
        (slot) =>
            slot.at.year == day.year &&
            slot.at.month == day.month &&
            slot.at.day == day.day,
      )
      .toList();

  /// Les jours qui ont au moins un créneau, dans l'ordre.
  List<DateTime> get openDays {
    final seen = <String, DateTime>{};
    for (final slot in slots) {
      final key = '${slot.at.year}-${slot.at.month}-${slot.at.day}';
      seen.putIfAbsent(
        key,
        () => DateTime(slot.at.year, slot.at.month, slot.at.day),
      );
    }
    return seen.values.toList()..sort((a, b) => a.compareTo(b));
  }

  @override
  List<Object?> get props => [
    declaresSlots,
    durationMinutes,
    slotCapacity,
    leadTimeHours,
    horizonDays,
    slots,
    rules,
    exceptions,
  ];
}

// ---------------------------------------------------------------- outils

/// « 09:00 » vers `TimeOfDay`, et l'inverse.
///
/// Postgres rend `09:00:00` ; l'heure envoyée doit faire exactement `HH:mm`.
TimeOfDay parseTime(String? raw) {
  final parts = (raw ?? '').split(':');
  if (parts.length < 2) return const TimeOfDay(hour: 9, minute: 0);
  return TimeOfDay(
    hour: int.tryParse(parts[0]) ?? 9,
    minute: int.tryParse(parts[1]) ?? 0,
  );
}

String formatTime(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:'
    '${time.minute.toString().padLeft(2, '0')}';

/// Le nom d'un jour ISO, en toutes lettres.
String weekdayName(int weekday) => switch (weekday) {
  1 => 'Lundi',
  2 => 'Mardi',
  3 => 'Mercredi',
  4 => 'Jeudi',
  5 => 'Vendredi',
  6 => 'Samedi',
  _ => 'Dimanche',
};

String weekdayShort(int weekday) => switch (weekday) {
  1 => 'Lun',
  2 => 'Mar',
  3 => 'Mer',
  4 => 'Jeu',
  5 => 'Ven',
  6 => 'Sam',
  _ => 'Dim',
};
