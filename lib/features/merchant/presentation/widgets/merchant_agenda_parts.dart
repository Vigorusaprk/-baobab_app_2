part of 'merchant_agenda.dart';

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.count,
    required this.selected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime day;
  final int count;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = selected ? scheme.onPrimary : scheme.onSurfaceVariant;

    return Material(
      color: selected ? scheme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radius12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        child: Container(
          width: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radius12),
            border: Border.all(
              color: selected
                  ? scheme.primary
                  : isToday
                  ? scheme.primary
                  : scheme.outlineVariant,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('E', 'fr_FR').format(day),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  height: 1.1,
                ),
              ),
              Text(
                '${day.day}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  color: selected ? scheme.onPrimary : scheme.onSurface,
                ),
              ),
              // Le compte ne s'affiche que s'il y a quelque chose : un « 0 »
              // sous chaque jour vide fait un mur de zéros.
              if (count > 0)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? scheme.onPrimary.withValues(alpha: 0.22)
                        : scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(
                      AppDimens.borderRadiusFull,
                    ),
                  ),
                  child: Text(
                    '$count',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: selected ? scheme.onPrimary : scheme.primary,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                )
              else
                const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarButton extends StatelessWidget {
  const _CalendarButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radius12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        child: Container(
          width: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radius12),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Icon(Icons.calendar_month_outlined, color: scheme.primary),
        ),
      ),
    );
  }
}
