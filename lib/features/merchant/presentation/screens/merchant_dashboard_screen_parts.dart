part of 'merchant_dashboard_screen.dart';

/// Ce que les fiches ont fait, sur trente jours.
///
/// Les deux nombres vont ensemble : des vues sans clic disent que la carte
/// n'accroche pas, des clics sans commande que la fiche déçoit.
class _Audience extends StatelessWidget {
  const _Audience({required this.stats});

  final MerchantStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return MerchantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AUDIENCE · 30 JOURS',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 1.1,
            ),
          ),
          AppDimens.spacerSmall,
          Row(
            children: [
              _Figure(value: '${stats.views}', label: 'fiches ouvertes'),
              AppDimens.spacerLargeWidth,
              _Figure(value: '${stats.clicks}', label: 'clics depuis une pub'),
            ],
          ),
          if (stats.views == 0) ...[
            AppDimens.spacerSmall,
            Text(
              'Le compteur démarre aujourd\'hui : il ne remonte pas dans le '
              'passé.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Une campagne qui attend quelque chose : validation, ou règlement.
class _CampaignBanner extends StatelessWidget {
  const _CampaignBanner({required this.space});

  final MerchantSpace space;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final open = space.openCampaigns;
    final toPay = open
        .where((c) => c.status == CampaignStatus.approved)
        .toList();
    final live = open.where((c) => c.status.isLive).toList();

    // Trois situations, trois phrases. Une seule les disait toutes — « N
    // campagnes en cours » — et une demande encore en examen se lisait comme
    // une diffusion en train de tourner, alors que rien n'était ni validé ni
    // réglé.
    final String message;
    if (toPay.isNotEmpty) {
      final many = toPay.length > 1;
      message =
          '${toPay.length} campagne${many ? 's' : ''} '
          'validée${many ? 's' : ''}, à régler';
    } else if (live.isNotEmpty) {
      message =
          '${live.length} campagne${live.length > 1 ? 's' : ''} '
          'en diffusion';
    } else {
      final many = open.length > 1;
      message =
          '${open.length} demande${many ? 's' : ''} de mise en avant '
          "en cours d'examen";
    }

    return MerchantCard(
      onTap: () => context.push('/merchant/ads'),
      child: Row(
        children: [
          Icon(
            Icons.campaign_outlined,
            color: toPay.isEmpty
                ? theme.colorScheme.primary
                : OtherTheme.of(context).onWarningContainer,
          ),
          AppDimens.spacerMediumWidth,
          Expanded(child: Text(message, style: theme.textTheme.bodyLarge)),
          Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _ToHandleBanner extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _ToHandleBanner({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MerchantCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            Icons.notifications_active_outlined,
            color: OtherTheme.of(context).onWarningContainer,
          ),
          AppDimens.spacerMediumWidth,
          Expanded(
            child: Text(
              count == 1
                  ? '1 demande attend votre réponse'
                  : '$count demandes attendent votre réponse',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _AllClearBanner extends StatelessWidget {
  final String business;

  const _AllClearBanner({required this.business});

  @override
  Widget build(BuildContext context) {
    return MerchantCard(
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: OtherTheme.of(context).onSuccessContainer,
          ),
          AppDimens.spacerMediumWidth,
          Expanded(
            child: Text(
              'Tout est à jour chez $business.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MerchantCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          AppDimens.spacerMediumWidth,
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
