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

part 'campaign_sheets_payment.dart';
part 'campaign_sheets_review.dart';
part 'campaign_sheets_parts.dart';

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
    _start = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
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
                label:
                    '${price.label} · ${price.usdPerDay.toStringAsFixed(0)} \$/j',
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
