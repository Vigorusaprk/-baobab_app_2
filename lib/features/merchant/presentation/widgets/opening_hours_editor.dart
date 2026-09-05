import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer_availability.dart';
import 'package:flutter/material.dart';

/// Les horaires d'ouverture, jour par jour.
///
/// Ils étaient saisis à l'inscription puis **jamais modifiables** : un
/// commerce qui changeait d'heure de fermeture n'avait aucun moyen de le
/// dire, et la fiche client affichait indéfiniment l'ancienne.
///
/// Sept lignes, une par jour : un jour fermé est un interrupteur, pas une
/// case à vider. Ce qui est envoyé est la même chaîne que celle que la fiche
/// client sait lire — « 09:00 - 18:00 » — pour qu'aucune conversion ne se
/// perde en route.
class OpeningHoursEditor extends StatelessWidget {
  const OpeningHoursEditor({
    super.key,
    required this.value,
    required this.onChanged,
  });

  /// Jour en toutes lettres vers plage horaire. Un jour absent est fermé.
  final Map<String, String> value;

  final ValueChanged<Map<String, String>> onChanged;

  /// L'ordre de la semaine, et l'orthographe qu'attend la fiche client.
  static const List<String> days = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  /// « 09:00 - 18:00 » vers ses deux bornes. `null` quand la ligne ne se lit
  /// pas : le commerçant a écrit du texte libre, et on ne le réécrit pas à
  /// sa place.
  static (TimeOfDay, TimeOfDay)? parseRange(String? raw) {
    final matches = RegExp(
      r'(\d{1,2})\s*[:hH]\s*(\d{2})?',
    ).allMatches(raw ?? '').toList();
    if (matches.length < 2) return null;

    TimeOfDay at(RegExpMatch match) => TimeOfDay(
      hour: int.parse(match.group(1)!) % 24,
      minute: int.parse(match.group(2) ?? '0') % 60,
    );
    return (at(matches.first), at(matches[1]));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final day in days)
          _DayRow(
            day: day,
            raw: value[day],
            onChanged: (line) {
              final next = Map<String, String>.from(value);
              if (line == null) {
                next.remove(day);
              } else {
                next[day] = line;
              }
              onChanged(next);
            },
          ),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.raw,
    required this.onChanged,
  });

  final String day;
  final String? raw;
  final ValueChanged<String?> onChanged;

  static const TimeOfDay _defaultOpen = TimeOfDay(hour: 9, minute: 0);
  static const TimeOfDay _defaultClose = TimeOfDay(hour: 18, minute: 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final range = OpeningHoursEditor.parseRange(raw);
    final isOpen = raw != null && raw!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.small),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              day,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isOpen ? scheme.onSurface : scheme.onSurfaceVariant,
              ),
            ),
          ),
          Switch(
            value: isOpen,
            onChanged: (open) => onChanged(
              open
                  ? '${formatTime(_defaultOpen)} - ${formatTime(_defaultClose)}'
                  : null,
            ),
          ),
          AppDimens.spacerSmallWidth,
          Expanded(
            child: isOpen
                ? _Range(
                    start: range?.$1 ?? _defaultOpen,
                    end: range?.$2 ?? _defaultClose,
                    // Une ligne écrite à la main — « sur rendez-vous » — est
                    // gardée telle quelle tant qu'on n'y touche pas.
                    freeText: range == null ? raw : null,
                    onChanged: (start, end) =>
                        onChanged('${formatTime(start)} - ${formatTime(end)}'),
                  )
                : Text(
                    'Fermé',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Range extends StatelessWidget {
  const _Range({
    required this.start,
    required this.end,
    required this.onChanged,
    this.freeText,
  });

  final TimeOfDay start;
  final TimeOfDay end;
  final String? freeText;
  final void Function(TimeOfDay start, TimeOfDay end) onChanged;

  Future<void> _pick(BuildContext context, {required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? start : end,
    );
    if (picked == null) return;
    onChanged(isStart ? picked : start, isStart ? end : picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (freeText != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              freeText!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => onChanged(start, end),
            child: const Text('Mettre des heures'),
          ),
        ],
      );
    }

    return Row(
      children: [
        _TimeButton(
          time: start,
          onPressed: () => _pick(context, isStart: true),
        ),
        Text(
          ' – ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        _TimeButton(time: end, onPressed: () => _pick(context, isStart: false)),
      ],
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({required this.time, required this.onPressed});

  final TimeOfDay time;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppDimens.radius8),
      child: InkWell(
        onTap: onPressed,
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
