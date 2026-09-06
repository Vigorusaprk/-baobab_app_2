part of 'offer_availability_page.dart';

/// Ce que le commerçant modifie dans sa semaine : ouvrir un jour, déplacer
/// une heure, fermer une date. Séparé de la page pour tenir la limite de
/// 300 lignes du projet — même comportement, aucun changement d'interface.
extension _AvailabilityEdits on _OfferAvailabilityPageState {
  void _toggleDay(int weekday, bool open) {
    _mutate(() {
      if (open) {
        _rules.add(
          AvailabilityRule(
            weekday: weekday,
            startsAt: const TimeOfDay(hour: 9, minute: 0),
            endsAt: const TimeOfDay(hour: 17, minute: 0),
          ),
        );
      } else {
        _rules.removeWhere((rule) => rule.weekday == weekday);
      }
    });
    _touch();
  }

  Future<void> _editRange(
    AvailabilityRule rule, {
    required bool isStart,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? rule.startsAt : rule.endsAt,
    );
    if (picked == null) return;
    _mutate(() {
      final index = _rules.indexOf(rule);
      if (index < 0) return;
      _rules[index] = isStart
          ? rule.copyWith(startsAt: picked)
          : rule.copyWith(endsAt: picked);
    });
    _touch();
  }

  Future<void> _addClosure() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    final day = DateTime(picked.year, picked.month, picked.day);
    _mutate(() {
      _exceptions.removeWhere(
        (item) =>
            item.day.year == day.year &&
            item.day.month == day.month &&
            item.day.day == day.day,
      );
      _exceptions.add(AvailabilityException(day: day));
      _exceptions.sort((a, b) => a.day.compareTo(b.day));
    });
    _touch();
  }

  Future<void> _save() async {
    _mutate(() => _saving = true);
    final error = await context.read<MerchantCubit>().setAvailability(
      offerId: widget.offer.id,
      durationMinutes: _rules.isEmpty ? null : _duration,
      slotCapacity: _capacity,
      leadTimeHours: _lead,
      rules: _rules,
      exceptions: _exceptions,
    );
    if (!mounted) return;
    _mutate(() {
      _saving = false;
      _dirty = error != null;
    });

    if (error != null) {
      _notify(error, isError: true);
      return;
    }
    _notify('Vos créneaux sont à jour.');
    await _load();
  }
}
