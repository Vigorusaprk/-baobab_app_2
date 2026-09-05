import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_app_bar.dart';
import 'package:baobabe_0_2/features/business_detail/data/offer_slots_api_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer_availability.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Les rendez-vous d'une offre : quand elle est ouverte, et pour combien de
/// monde à la fois.
///
/// Sans cet écran, le client proposait la date de son choix et le commerçant
/// recevait des demandes pour des heures où il est fermé — puis les refusait
/// une par une. Ce qui se déclare ici devient la **seule** chose que le
/// client peut choisir.
///
/// Déclaré **par offre** : une nuit d'hôtel, une coupe de trente minutes et
/// une soirée en terrasse ne tombent pas dans la même grille.
class OfferAvailabilityPage extends StatefulWidget {
  const OfferAvailabilityPage({super.key, required this.offer});

  final Offer offer;

  @override
  State<OfferAvailabilityPage> createState() => _OfferAvailabilityPageState();
}

class _OfferAvailabilityPageState extends State<OfferAvailabilityPage> {
  final _api = OfferSlotsApiService();

  /// Les durées qu'on choisit vraiment. Au-delà, le champ libre du serveur
  /// accepte n'importe quoi entre 5 minutes et 24 heures.
  static const List<int> _durations = [30, 45, 60, 90, 120, 240, 1440];

  int? _duration;
  int _capacity = 1;
  int _lead = 2;
  List<AvailabilityRule> _rules = [];
  List<AvailabilityException> _exceptions = [];

  OfferAvailability? _loaded;
  bool _saving = false;
  bool _dirty = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final availability = await _api.getAvailability(widget.offer.id);
      if (!mounted) return;
      setState(() {
        _loaded = availability;
        _duration = availability.durationMinutes;
        _capacity = availability.slotCapacity ?? 1;
        _lead = availability.leadTimeHours;
        _rules = List.of(availability.rules);
        _exceptions = List.of(availability.exceptions);
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  void _touch() {
    if (!_dirty) setState(() => _dirty = true);
  }

  List<AvailabilityRule> _rulesOf(int weekday) =>
      _rules.where((rule) => rule.weekday == weekday).toList();

  void _toggleDay(int weekday, bool open) {
    setState(() {
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

  Future<void> _editRange(AvailabilityRule rule, {required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? rule.startsAt : rule.endsAt,
    );
    if (picked == null) return;
    setState(() {
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
    setState(() {
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
    setState(() => _saving = true);
    final error = await context.read<MerchantCubit>().setAvailability(
      offerId: widget.offer.id,
      durationMinutes: _rules.isEmpty ? null : _duration,
      slotCapacity: _capacity,
      leadTimeHours: _lead,
      rules: _rules,
      exceptions: _exceptions,
    );
    if (!mounted) return;
    setState(() {
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

  void _notify(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : OtherTheme.of(context).onSuccessContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: const CustomOtherAppBar(title: 'Rendez-vous'),
      body: Column(
        children: [
          Expanded(
            child: _loaded == null && _error == null
                ? const _AvailabilitySkeleton()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.appPaddingValue,
                      AppDimens.medium,
                      AppDimens.appPaddingValue,
                      AppDimens.large,
                    ),
                    children: [
                      Text(
                        widget.offer.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppDimens.spacerMini,
                      Text(
                        'Ce que vous déclarez ici est la seule chose que le '
                        'client pourra choisir.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      AppDimens.spacerLarge,

                      const _Label('Durée d\'un rendez-vous'),
                      Wrap(
                        spacing: AppDimens.small,
                        runSpacing: AppDimens.small,
                        children: [
                          for (final minutes in _durations)
                            _Chip(
                              label: _durationLabel(minutes),
                              selected: _duration == minutes,
                              onTap: () {
                                setState(() => _duration = minutes);
                                _touch();
                              },
                            ),
                        ],
                      ),
                      AppDimens.spacerLarge,

                      const _Label('Combien de clients en même temps'),
                      _Counter(
                        value: _capacity,
                        min: 1,
                        max: 200,
                        suffix: _capacity > 1 ? 'places' : 'place',
                        onChanged: (value) {
                          setState(() => _capacity = value);
                          _touch();
                        },
                      ),
                      AppDimens.spacerLarge,

                      const _Label('Délai de prévenance'),
                      _Counter(
                        value: _lead,
                        min: 0,
                        max: 72,
                        suffix: _lead > 1 ? 'heures' : 'heure',
                        onChanged: (value) {
                          setState(() => _lead = value);
                          _touch();
                        },
                      ),
                      AppDimens.spacerMini,
                      Text(
                        'En dessous de ce délai, le créneau n\'est plus '
                        'proposé.',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      AppDimens.spacerLarge,

                      const _Label('Votre semaine'),
                      for (var weekday = 1; weekday <= 7; weekday++)
                        _DayBlock(
                          weekday: weekday,
                          rules: _rulesOf(weekday),
                          onToggle: (open) => _toggleDay(weekday, open),
                          onEdit: _editRange,
                          onAdd: () {
                            setState(
                              () => _rules.add(
                                AvailabilityRule(
                                  weekday: weekday,
                                  startsAt: const TimeOfDay(
                                    hour: 14,
                                    minute: 0,
                                  ),
                                  endsAt: const TimeOfDay(hour: 18, minute: 0),
                                ),
                              ),
                            );
                            _touch();
                          },
                          onRemove: (rule) {
                            setState(() => _rules.remove(rule));
                            _touch();
                          },
                        ),
                      AppDimens.spacerLarge,

                      const _Label('Fermetures exceptionnelles'),
                      for (final exception in _exceptions)
                        _ClosureRow(
                          exception: exception,
                          onRemove: () {
                            setState(() => _exceptions.remove(exception));
                            _touch();
                          },
                        ),
                      TextButton.icon(
                        onPressed: _addClosure,
                        icon: const Icon(Icons.event_busy_outlined),
                        label: const Text('Fermer une journée'),
                      ),

                      if (_loaded != null && !_dirty) ...[
                        AppDimens.spacerLarge,
                        _NextSlots(availability: _loaded!),
                      ],
                      if (_error != null) ...[
                        AppDimens.spacerMedium,
                        Text(
                          _error!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
          if (_dirty)
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                border: Border(
                  top: BorderSide(color: scheme.outlineVariant, width: 0.7),
                ),
              ),
              padding: const EdgeInsets.all(AppDimens.appPaddingValue),
              child: SafeArea(
                top: false,
                child: CustomButton(
                  text: 'Enregistrer les créneaux',
                  icon: Icons.check_rounded,
                  isLoading: _saving,
                  onPressed: _save,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _durationLabel(int minutes) {
    if (minutes >= 1440) return 'La journée';
    if (minutes % 60 == 0) return '${minutes ~/ 60} h';
    if (minutes > 60) return '${minutes ~/ 60} h ${minutes % 60}';
    return '$minutes min';
  }
}

/// Un jour de la semaine, ouvert ou fermé, avec ses plages.
class _DayBlock extends StatelessWidget {
  const _DayBlock({
    required this.weekday,
    required this.rules,
    required this.onToggle,
    required this.onEdit,
    required this.onAdd,
    required this.onRemove,
  });

  final int weekday;
  final List<AvailabilityRule> rules;
  final ValueChanged<bool> onToggle;
  final void Function(AvailabilityRule rule, {required bool isStart}) onEdit;
  final VoidCallback onAdd;
  final ValueChanged<AvailabilityRule> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isOpen = rules.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.small),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.medium,
        vertical: AppDimens.small,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  weekdayName(weekday),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isOpen ? scheme.onSurface : scheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (isOpen)
                IconButton(
                  onPressed: onAdd,
                  tooltip: 'Ajouter une plage',
                  icon: const Icon(Icons.add_rounded),
                  visualDensity: VisualDensity.compact,
                ),
              Switch(value: isOpen, onChanged: onToggle),
            ],
          ),
          for (final rule in rules)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.small),
              child: Row(
                children: [
                  _Time(
                    time: rule.startsAt,
                    onTap: () => onEdit(rule, isStart: true),
                  ),
                  Text(
                    ' – ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  _Time(
                    time: rule.endsAt,
                    onTap: () => onEdit(rule, isStart: false),
                  ),
                  const Spacer(),
                  if (rules.length > 1)
                    IconButton(
                      onPressed: () => onRemove(rule),
                      tooltip: 'Retirer cette plage',
                      icon: const Icon(Icons.close_rounded, size: 18),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ClosureRow extends StatelessWidget {
  const _ClosureRow({required this.exception, required this.onRemove});

  final AvailabilityException exception;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          Icons.event_busy_outlined,
          size: AppDimens.medium,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        AppDimens.spacerSmallWidth,
        Expanded(
          child: Text(
            DateFormat('EEEE d MMMM', 'fr_FR').format(exception.day),
            style: theme.textTheme.bodyMedium,
          ),
        ),
        IconButton(
          onPressed: onRemove,
          tooltip: 'Retirer cette fermeture',
          icon: const Icon(Icons.close_rounded, size: 18),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

/// Ce que le client verra : les prochains créneaux réellement libres.
///
/// C'est la seule vérification qui compte — une grille juste à l'écran peut
/// ne produire aucun créneau si la plage est plus courte que la durée.
class _NextSlots extends StatelessWidget {
  const _NextSlots({required this.availability});

  final OfferAvailability availability;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final slots = availability.slots.take(8).toList();

    return Container(
      padding: const EdgeInsets.all(AppDimens.medium),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CE QUE LE CLIENT VOIT',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.primary,
              letterSpacing: 1.1,
            ),
          ),
          AppDimens.spacerSmall,
          if (slots.isEmpty)
            Text(
              availability.declaresSlots
                  ? 'Aucun créneau libre pour l\'instant : vos plages sont '
                        'peut-être plus courtes que la durée d\'un '
                        'rendez-vous.'
                  : 'Vous ne déclarez pas de créneaux : le client propose la '
                        'date qu\'il veut, et vous arbitrez.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.primary,
                height: 1.5,
              ),
            )
          else
            Wrap(
              spacing: AppDimens.small,
              runSpacing: AppDimens.small,
              children: [
                for (final slot in slots)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.small + 2,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(
                        AppDimens.borderRadiusFull,
                      ),
                    ),
                    child: Text(
                      DateFormat('E d · HH:mm', 'fr_FR').format(slot.at),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.small),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: selected
          ? scheme.primaryContainer.withValues(alpha: 0.55)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.small + 4,
            vertical: AppDimens.small,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _Time extends StatelessWidget {
  const _Time({required this.time, required this.onTap});

  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppDimens.radius8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            formatTime(time),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Un nombre qu'on règle par pas de un.
class _Counter extends StatelessWidget {
  const _Counter({
    required this.value,
    required this.onChanged,
    required this.suffix,
    this.min = 0,
    this.max = 99,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final String suffix;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.borderRadiusFull),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: value > min ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_rounded, size: AppDimens.medium),
                color: scheme.primary,
                disabledColor: scheme.outlineVariant,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: AppDimens.touchTarget - 8,
                  minHeight: AppDimens.touchTarget - 8,
                ),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: value < max ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add_rounded, size: AppDimens.medium),
                color: scheme.primary,
                disabledColor: scheme.outlineVariant,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: AppDimens.touchTarget - 8,
                  minHeight: AppDimens.touchTarget - 8,
                ),
              ),
            ],
          ),
        ),
        AppDimens.spacerMediumWidth,
        Text(
          suffix,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _AvailabilitySkeleton extends StatelessWidget {
  const _AvailabilitySkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Skeletonizer(
      enabled: true,
      child: ListView(
        padding: const EdgeInsets.all(AppDimens.appPaddingValue),
        children: [
          Bone.text(width: 200, style: theme.textTheme.titleMedium!),
          AppDimens.spacerLarge,
          Bone.text(width: 140, style: theme.textTheme.labelSmall!),
          AppDimens.spacerSmall,
          const Row(
            children: [
              Bone(width: 72, height: 36, uniRadius: 18),
              AppDimens.spacerSmallWidth,
              Bone(width: 72, height: 36, uniRadius: 18),
              AppDimens.spacerSmallWidth,
              Bone(width: 72, height: 36, uniRadius: 18),
            ],
          ),
          AppDimens.spacerLarge,
          for (var i = 0; i < 5; i++)
            const Padding(
              padding: EdgeInsets.only(bottom: AppDimens.small),
              child: Bone(width: double.infinity, height: 64, uniRadius: 12),
            ),
        ],
      ),
    );
  }
}
