part of 'campaign_sheets.dart';

class _PaymentSheet extends StatefulWidget {
  const _PaymentSheet({required this.campaign});

  final AdCampaign campaign;

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  bool _sending = false;
  String? _error;

  Future<void> _pay() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    final error = await context.read<MerchantCubit>().actOnCampaign(
      widget.campaign.id,
      CampaignAction.pay,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _sending = false;
        _error = error;
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final other = OtherTheme.of(context);
    final format = DateFormat('d MMMM', 'fr_FR');
    final campaign = widget.campaign;
    final amount = campaign.dueAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          campaign.target,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        AppDimens.spacerMini,
        Text(
          '${campaign.placement.label} · du '
          '${format.format(campaign.startsOn)} au '
          '${format.format(campaign.endsOn)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        AppDimens.spacerLarge,

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'À RÉGLER',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            Text(
              '${amount.toStringAsFixed(2).replaceAll('.', ',')} \$',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ],
        ),
        AppDimens.spacerMedium,

        Container(
          padding: const EdgeInsets.all(AppDimens.small + 4),
          decoration: BoxDecoration(
            color: other.warningContainer,
            borderRadius: BorderRadius.circular(AppDimens.radius12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: AppDimens.medium,
                color: other.onWarningContainer,
              ),
              AppDimens.spacerSmallWidth,
              Expanded(
                child: Text(
                  'Le paiement en ligne arrive bientôt. En confirmant, vous '
                  'vous engagez à régler ce montant avec Baobabe, et la '
                  'diffusion démarre tout de suite.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: other.onWarningContainer,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (_error != null) ...[
          AppDimens.spacerMedium,
          Text(
            _error!,
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
          ),
        ],
        AppDimens.spacerLarge,
        CustomButton(
          text: 'Payer ${amount.toStringAsFixed(2).replaceAll('.', ',')} \$',
          icon: Icons.check_rounded,
          isLoading: _sending,
          onPressed: _pay,
        ),
      ],
    );
  }
}

/// Examiner une campagne, du côté de la plateforme.
///
/// Le montant est **modifiable** : le devis calculé depuis la grille est un
/// point de départ, pas un tarif intangible.
Future<bool?> showCampaignReviewSheet(
  BuildContext context, {
  required AdCampaign campaign,
}) {
  final cubit = context.read<MerchantCubit>();

  return showCustomBottomSheet<bool>(
    context: context,
    title: 'Examiner la demande',
    child: BlocProvider.value(
      value: cubit,
      child: _ReviewSheet(campaign: campaign),
    ),
  );
}
