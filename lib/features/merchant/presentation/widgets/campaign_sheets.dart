import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_bottom_sheet.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_extras.dart';
import 'package:baobabe_0_2/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Demander une mise en avant.
///
/// Le devis s'affiche **pendant** la saisie : un commerçant ne doit pas
/// découvrir le prix après avoir envoyé sa demande. Le chiffre montré ici est
/// celui de la grille publique ; le serveur le recalcule à la réception, et
/// c'est le sien qui compte.
Future<bool?> showCampaignFormSheet(
  BuildContext context, {
  required AdBoard board,
  required List<Offer> offers,
}) {
  final cubit = context.read<MerchantCubit>();

  return showCustomBottomSheet<bool>(
    context: context,
    title: 'Demander une mise en avant',
    child: BlocProvider.value(
      value: cubit,
      child: _CampaignForm(board: board, offers: offers),
    ),
  );
}

class _CampaignForm extends StatefulWidget {
  const _CampaignForm({required this.board, required this.offers});

  final AdBoard board;
  final List<Offer> offers;

  @override
  State<_CampaignForm> createState() => _CampaignFormState();
}

class _CampaignFormState extends State<_CampaignForm> {
  AdPlacement _placement = AdPlacement.home;
  String? _offerId;
  late DateTime _start;
  int _days = 7;
  bool _sending = false;
  String? _error;

  /// Les durées qu'on choisit vraiment : une semaine, deux, un mois.
  static const List<int> _durations = [3, 7, 14, 30];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Demain plutôt qu'aujourd'hui : la demande passe par un examen, et une
    // campagne qui devait commencer ce matin serait déjà en retard.
    _start = DateTime(now.year, now.month, now.day).add(
      const Duration(days: 1),
    );
    _offerId = widget.offers.isEmpty ? null : widget.offers.first.id;
  }

  DateTime get _end => _start.add(Duration(days: _days - 1));

  double get _quote => widget.board.perDay(_placement) * _days;

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 180)),
    );
    if (picked != null) setState(() => _start = picked);
  }

  Future<void> _submit() async {
    setState(() {
      _sending = true;
      _error = null;
    });

    final error = await context.read<MerchantCubit>().createCampaign(
      placement: _placement,
      startsOn: _start,
      endsOn: _end,
      offerId: _offerId,
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
    final format = DateFormat('EEE d MMM', 'fr_FR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Label('Emplacement'),
        Wrap(
          spacing: AppDimens.small,
          runSpacing: AppDimens.small,
          children: [
            for (final price in widget.board.prices)
              _Choice(
                label: '${price.label} · ${price.usdPerDay.toStringAsFixed(0)} \$/j',
                selected: _placement == price.placement,
                onTap: () => setState(() => _placement = price.placement),
              ),
          ],
        ),
        AppDimens.spacerLarge,

        _Label('Ce que vous poussez'),
        if (widget.offers.isEmpty)
          Text(
            'Publiez une offre pour pouvoir la mettre en avant. En attendant, '
            'la campagne portera sur votre commerce.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          )
        else
          Wrap(
            spacing: AppDimens.small,
            runSpacing: AppDimens.small,
            children: [
              _Choice(
                label: 'Tout le commerce',
                selected: _offerId == null,
                onTap: () => setState(() => _offerId = null),
              ),
              for (final offer in widget.offers.take(12))
                _Choice(
                  label: offer.name,
                  selected: _offerId == offer.id,
                  onTap: () => setState(() => _offerId = offer.id),
                ),
            ],
          ),
        AppDimens.spacerLarge,

        _Label('Période'),
        Row(
          children: [
            Expanded(
              child: _Field(
                label: 'Début',
                value: format.format(_start),
                onTap: _pickStart,
              ),
            ),
            AppDimens.spacerSmallWidth,
            Expanded(
              child: _Field(
                label: 'Fin',
                value: format.format(_end),
                // La fin se déduit de la durée : deux dates à choisir, c'est
                // deux occasions de se tromper d'un jour.
                onTap: null,
              ),
            ),
          ],
        ),
        AppDimens.spacerSmall,
        Wrap(
          spacing: AppDimens.small,
          children: [
            for (final days in _durations)
              _Choice(
                label: '$days jours',
                selected: _days == days,
                onTap: () => setState(() => _days = days),
              ),
          ],
        ),
        AppDimens.spacerLarge,

        Container(
          padding: const EdgeInsets.all(AppDimens.medium),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(AppDimens.radius12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DEVIS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      '${_quote.toStringAsFixed(2).replaceAll('.', ',')} \$',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  'Rien n\'est réclamé maintenant : Baobabe valide, puis vous '
                  'réglez.',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    height: 1.4,
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
          text: 'Envoyer la demande',
          icon: Icons.send_rounded,
          isLoading: _sending,
          onPressed: _submit,
        ),
      ],
    );
  }
}

/// Régler une campagne validée.
///
/// **Le paiement en ligne n'existe pas encore.** Ce geste vaut accord de
/// règlement et lance la diffusion : la feuille le dit, plutôt que de laisser
/// croire à un encaissement.
Future<bool?> showCampaignPaymentSheet(
  BuildContext context, {
  required AdCampaign campaign,
}) {
  final cubit = context.read<MerchantCubit>();

  return showCustomBottomSheet<bool>(
    context: context,
    title: 'Régler la campagne',
    child: BlocProvider.value(
      value: cubit,
      child: _PaymentSheet(campaign: campaign),
    ),
  );
}

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

/// Une pastille de choix. Même forme que le filtre du catalogue client :
/// c'est le même geste, il doit avoir la même apparence.
class _Choice extends StatelessWidget {
  const _Choice({
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
            vertical: AppDimens.small + 1,
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

/// Une valeur qu'on touche pour la changer.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onTap != null;

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppDimens.radius12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.medium,
            vertical: AppDimens.small + 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: enabled ? scheme.onSurface : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
