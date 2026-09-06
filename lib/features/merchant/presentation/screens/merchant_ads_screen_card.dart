part of 'merchant_ads_screen.dart';

/// Une campagne, et le geste qu'elle attend.
class CampaignCard extends StatelessWidget {
  const CampaignCard({
    super.key,
    required this.campaign,
    this.onPay,
    this.onCancel,
    this.showBusiness = false,
  });

  final AdCampaign campaign;
  final VoidCallback? onPay;
  final VoidCallback? onCancel;

  /// Vrai dans le panneau d'administration : là-bas, savoir de quel commerce
  /// vient la demande est le premier renseignement.
  final bool showBusiness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final other = OtherTheme.of(context);
    final format = DateFormat('d MMM', 'fr_FR');

    final (color, surface) = switch (campaign.status) {
      CampaignStatus.running => (
        other.onSuccessContainer,
        other.successContainer,
      ),
      CampaignStatus.approved => (
        other.onWarningContainer,
        other.warningContainer,
      ),
      CampaignStatus.rejected => (scheme.error, scheme.errorContainer),
      _ => (scheme.onSurfaceVariant, scheme.surfaceContainerHighest),
    };

    return MerchantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  showBusiness
                      ? campaign.businessName ?? 'Commerce'
                      : campaign.target,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AppDimens.spacerSmallWidth,
              StatusChip(
                label: campaign.status.label,
                color: color,
                surface: surface,
              ),
            ],
          ),
          AppDimens.spacerMini,
          Text(
            '${campaign.placement.label} · '
            '${format.format(campaign.startsOn)} – '
            '${format.format(campaign.endsOn)} · '
            '${campaign.days} jour${campaign.days > 1 ? 's' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (showBusiness && campaign.offerName != null) ...[
            AppDimens.spacerMini,
            Text(
              'Pousse : ${campaign.offerName}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          AppDimens.spacerSmall,
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.amount == null ? 'DEVIS' : 'MONTANT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    money(campaign.dueAmount),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (onPay != null)
                CustomActionButton(
                  label: 'Payer',
                  icon: Icons.check_rounded,
                  onPressed: onPay,
                )
              else if (onCancel != null)
                CustomActionButton(
                  label: 'Annuler',
                  tone: ActionButtonTone.dangerOutline,
                  onPressed: onCancel,
                ),
            ],
          ),
          if (campaign.status.note != null || campaign.reviewNote != null) ...[
            AppDimens.spacerSmall,
            Text(
              campaign.reviewNote ?? campaign.status.note!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: campaign.status == CampaignStatus.rejected
                    ? scheme.error
                    : scheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

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

/// La forme de l'écran pendant le chargement.
///
/// Un squelette, jamais un indicateur circulaire : c'est la règle du projet,
/// et ici elle évite en plus que la page saute quand la grille arrive.
class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bone.text(width: 120, style: theme.textTheme.labelSmall!),
          AppDimens.spacerSmall,
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.small),
              child: Row(
                children: [
                  Expanded(
                    child: Bone.text(
                      width: 160,
                      style: theme.textTheme.bodyMedium!,
                    ),
                  ),
                  Bone.text(width: 70, style: theme.textTheme.bodyMedium!),
                ],
              ),
            ),
          AppDimens.spacerMedium,
          const Bone.button(
            width: double.infinity,
            height: AppDimens.touchTarget,
            uniRadius: AppDimens.borderRadiusSmallButton,
          ),
          AppDimens.spacerLarge,
          const Bone(
            width: double.infinity,
            height: 128,
            uniRadius: AppDimens.smallCardBorderRadius,
          ),
        ],
      ),
    );
  }
}

/// Un montant en dollars, écrit comme partout ailleurs dans l'application.
String money(double amount) =>
    '${amount.toStringAsFixed(2).replaceAll('.', ',')} \$';
