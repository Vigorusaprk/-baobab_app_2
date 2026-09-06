part of 'merchant_shop_screen.dart';

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.small),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// La catégorie, montrée mais pas modifiable : elle décide du classement de
/// toute la plateforme.
class _CategoryLine extends StatelessWidget {
  const _CategoryLine({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: AppDimens.medium,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        AppDimens.spacerSmallWidth,
        Expanded(
          child: Text(
            'Catégorie : $label. Écrivez-nous pour en changer.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// La fermeture temporaire.
class _PauseTile extends StatelessWidget {
  const _PauseTile({required this.paused, required this.onChanged});

  final bool paused;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final other = OtherTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimens.medium),
      decoration: BoxDecoration(
        color: paused
            ? other.warningContainer
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fermé temporairement',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: paused ? other.onWarningContainer : null,
                  ),
                ),
                AppDimens.spacerMini,
                Text(
                  paused
                      ? 'Votre commerce et vos offres sont retirés de la '
                            'découverte. Rien n\'est supprimé.'
                      : 'Congés, travaux : retirez tout de la découverte '
                            'sans rien supprimer.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: paused
                        ? other.onWarningContainer
                        : theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          AppDimens.spacerMediumWidth,
          Switch(value: paused, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.saving, required this.onSave});

  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
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
          text: 'Enregistrer',
          icon: Icons.check_rounded,
          isLoading: saving,
          onPressed: onSave,
        ),
      ),
    );
  }
}

/// L'entrée vers la publicité : un commerçant ne devine pas qu'elle existe.
class _AdsEntry extends StatelessWidget {
  const _AdsEntry({required this.space});

  final MerchantSpace space;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final running = space.stats.runningCampaigns;
    final open = space.openCampaigns.length;

    return MerchantCard(
      onTap: () => context.push('/merchant/ads'),
      child: Row(
        children: [
          Icon(Icons.campaign_outlined, color: scheme.primary),
          AppDimens.spacerMediumWidth,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mise en avant',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppDimens.spacerMini,
                Text(
                  running > 0
                      ? '$running campagne${running > 1 ? 's' : ''} en '
                            'diffusion'
                      : open > 0
                      ? '$open demande${open > 1 ? 's' : ''} en cours'
                      : 'Apparaissez en tête de l\'accueil.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
