part of 'campaign_sheets.dart';

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet({required this.campaign});

  final AdCampaign campaign;

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  late final TextEditingController _amount = TextEditingController(
    text: widget.campaign.dueAmount.toStringAsFixed(2),
  );
  late final TextEditingController _note = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _act(CampaignAction action) async {
    setState(() {
      _sending = true;
      _error = null;
    });

    final amount = double.tryParse(_amount.text.trim().replaceAll(',', '.'));
    final error = await context.read<MerchantCubit>().actOnCampaign(
      widget.campaign.id,
      action,
      amount: action == CampaignAction.approve ? amount : null,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
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
    final campaign = widget.campaign;
    final format = DateFormat('d MMM', 'fr_FR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          campaign.businessName ?? 'Commerce',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        AppDimens.spacerMini,
        Text(
          '${campaign.target} · ${campaign.placement.label} · '
          '${format.format(campaign.startsOn)} – '
          '${format.format(campaign.endsOn)} (${campaign.days} j)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        AppDimens.spacerMedium,
        Text(
          'Devis calculé : '
          '${campaign.quotedAmount.toStringAsFixed(2).replaceAll('.', ',')} \$',
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        AppDimens.spacerLarge,

        _Label('Montant retenu'),
        TextField(
          controller: _amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: '15.00'),
        ),
        AppDimens.spacerMedium,
        _Label('Motif'),
        TextField(
          controller: _note,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Obligatoire pour un refus.',
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
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _sending ? null : () => _act(CampaignAction.reject),
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.error,
                  side: BorderSide(color: scheme.error),
                  minimumSize: const Size(0, AppDimens.touchTarget),
                ),
                child: const Text('Refuser'),
              ),
            ),
            AppDimens.spacerSmallWidth,
            Expanded(
              flex: 2,
              child: CustomButton(
                text: 'Valider',
                icon: Icons.check_rounded,
                isLoading: _sending,
                onPressed: () => _act(CampaignAction.approve),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------- pièces
