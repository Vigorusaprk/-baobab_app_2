part of 'offer_availability_page.dart';

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
