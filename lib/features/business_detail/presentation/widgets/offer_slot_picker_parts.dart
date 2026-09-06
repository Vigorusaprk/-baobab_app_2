part of 'offer_slot_picker.dart';

/// Une heure proposée. Le nombre de places restantes n'apparaît que lorsqu'il
/// est **entamé et bas** : « 12 places » sous chaque créneau ne dit rien, et
/// « dernière place » sous chacun d'eux, sur une offre qui n'en propose
/// qu'une, ne dit rien non plus. « 2 places » décide.
class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.reference,
    required this.selected,
    required this.onTap,
  });

  final OfferSlot slot;

  /// Ce que le créneau offre quand personne n'a rien pris.
  final int reference;

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final scarce =
        slot.remaining > 0 && slot.remaining < reference && slot.remaining <= 3;

    return Material(
      color: selected
          ? scheme.primaryContainer.withValues(alpha: 0.55)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radius12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.medium,
            vertical: AppDimens.small + 2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radius12),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('HH:mm').format(slot.at),
                style: theme.textTheme.titleSmall?.copyWith(
                  height: 1.1,
                  fontWeight: FontWeight.w600,
                  color: selected ? scheme.primary : scheme.onSurface,
                ),
              ),
              if (scarce)
                Text(
                  slot.remaining == 1
                      ? 'dernière place'
                      : '${slot.remaining} places',
                  style: theme.textTheme.labelSmall?.copyWith(
                    height: 1.3,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
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
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
    );
  }
}

/// Le commerçant a déclaré des créneaux, mais aucun n'est libre d'ici son
/// horizon. On le dit — c'est plus honnête qu'une grille vide.
class _NoSlots extends StatelessWidget {
  const _NoSlots();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.medium),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Row(
        children: [
          Icon(Icons.event_busy_outlined, color: scheme.onSurfaceVariant),
          AppDimens.spacerMediumWidth,
          Expanded(
            child: Text(
              'Aucun créneau libre pour le moment. Le commerce en ouvrira '
              'de nouveaux — ou appelez-le pour convenir d\'une heure.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Retry extends StatelessWidget {
  const _Retry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Réessayer')),
      ],
    );
  }
}

/// La forme du sélecteur pendant sa lecture : trois jours et une rangée
/// d'heures. Le contenu change, la page ne bouge pas.
class _SlotSkeleton extends StatelessWidget {
  const _SlotSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bone.text(width: 46, style: theme.textTheme.labelSmall!),
          AppDimens.spacerSmall,
          Row(
            children: [
              for (var i = 0; i < 4; i++)
                const Padding(
                  padding: EdgeInsets.only(right: AppDimens.small),
                  child: Bone(
                    width: 64,
                    height: OfferDateChoice.chipHeight,
                    uniRadius: AppDimens.radius12,
                  ),
                ),
            ],
          ),
          AppDimens.spacerLarge,
          Bone.text(width: 52, style: theme.textTheme.labelSmall!),
          AppDimens.spacerSmall,
          Wrap(
            spacing: AppDimens.small,
            runSpacing: AppDimens.small,
            children: [
              for (var i = 0; i < 6; i++)
                const Bone(
                  width: 78,
                  height: 44,
                  uniRadius: AppDimens.radius12,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
