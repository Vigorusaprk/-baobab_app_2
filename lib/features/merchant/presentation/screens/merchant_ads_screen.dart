import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_action_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_app_bar.dart';
import 'package:baobabe_0_2/core/widgets/custom_pop_up.dart';
import 'package:baobabe_0_2/core/widgets/custom_refresh.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_extras.dart';
import 'package:baobabe_0_2/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/campaign_sheets.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/merchant_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// La publicité, vue du commerçant.
///
/// Trois choses à comprendre avant de dépenser quoi que ce soit : où
/// l'annonce apparaît, combien elle coûte, et ce qui se passe après la
/// demande. L'écran les dit dans cet ordre, puis liste ce qui est en cours.
///
/// Le montant affiché est **celui du serveur** : le devis est calculé à la
/// demande depuis la grille, et la plateforme peut le corriger en validant.
/// Le client n'envoie jamais de prix.
class MerchantAdsScreen extends StatefulWidget {
  const MerchantAdsScreen({super.key});

  @override
  State<MerchantAdsScreen> createState() => _MerchantAdsScreenState();
}

class _MerchantAdsScreenState extends State<MerchantAdsScreen> {
  AdBoard? _board;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final board = await context.read<MerchantCubit>().loadAdBoard();
      if (!mounted) return;
      setState(() {
        _board = board;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _ask() async {
    final board = _board;
    final state = context.read<MerchantCubit>().state;
    if (board == null || state is! MerchantReady) return;

    final created = await showCampaignFormSheet(
      context,
      board: board,
      offers: state.space.activeOffers,
    );
    if (created == true) await _load();
  }

  Future<void> _pay(AdCampaign campaign) async {
    final paid = await showCampaignPaymentSheet(context, campaign: campaign);
    if (paid == true) await _load();
  }

  Future<void> _cancel(AdCampaign campaign) async {
    final confirmed = await showCustomPopUp(
      context: context,
      title: 'Annuler cette campagne ?',
      message: campaign.status.isLive
          ? 'La diffusion s\'arrête tout de suite. Le montant déjà réglé '
                'n\'est pas rendu automatiquement : écrivez-nous.'
          : 'La demande sera retirée. Vous pourrez en déposer une autre '
                'quand vous voulez.',
    );
    if (!confirmed || !mounted) return;

    final error = await context.read<MerchantCubit>().actOnCampaign(
      campaign.id,
      CampaignAction.cancel,
    );
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final board = _board;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomOtherAppBar(title: 'Mise en avant'),
      body: CustomRefresh(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.appPaddingValue,
            AppDimens.medium,
            AppDimens.appPaddingValue,
            AppDimens.large,
          ),
          children: [
            const _HowItWorks(),
            AppDimens.spacerLarge,

            if (board != null) ...[
              const _SectionTitle('Emplacements'),
              for (final price in board.prices)
                _PlacementRow(price: price),
              AppDimens.spacerMedium,
              CustomActionButton(
                label: 'Demander une mise en avant',
                icon: Icons.campaign_outlined,
                expand: true,
                onPressed: _ask,
              ),
              AppDimens.spacerLarge,
              const _SectionTitle('Vos campagnes'),
              if (board.campaigns.isEmpty)
                const MerchantEmptyState(
                  icon: Icons.campaign_outlined,
                  title: 'Aucune campagne',
                  message:
                      'Une mise en avant place une de vos offres en tête de '
                      'l\'accueil, le temps que vous choisissez.',
                )
              else
                for (final campaign in board.campaigns)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.small),
                    child: CampaignCard(
                      campaign: campaign,
                      onPay: campaign.status == CampaignStatus.approved
                          ? () => _pay(campaign)
                          : null,
                      onCancel: campaign.status.isOver
                          ? null
                          : () => _cancel(campaign),
                    ),
                  ),
            ] else if (_loading)
              const _Loading()
            else if (_error != null)
              MerchantEmptyState(
                icon: Icons.wifi_off_rounded,
                title: 'Campagnes injoignables',
                message: _error!,
              ),
          ],
        ),
      ),
    );
  }
}

/// Ce qui se passe entre la demande et la diffusion.
///
/// Sans cette explication, un commerçant qui demande une mise en avant
/// attend sans savoir quoi, et croit avoir payé alors que personne ne lui a
/// encore rien réclamé.
class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    const steps = [
      ('Vous demandez', 'Un emplacement, une offre, des dates.'),
      ('Baobabe valide', 'Nous vérifions et fixons le montant.'),
      ('Vous réglez', 'La diffusion démarre aussitôt.'),
    ];

    return Container(
      padding: const EdgeInsets.all(AppDimens.medium),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primaryContainer.withValues(alpha: 0.55),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AppDimens.spacerMediumWidth,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[i].$1,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        steps[i].$2,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (i != steps.length - 1) AppDimens.spacerSmall,
          ],
        ],
      ),
    );
  }
}

class _PlacementRow extends StatelessWidget {
  const _PlacementRow({required this.price});

  final AdPrice price;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.small),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  price.placement.explanation,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          AppDimens.spacerMediumWidth,
          Text(
            '${money(price.usdPerDay)} / jour',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

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
      CampaignStatus.running => (other.onSuccessContainer, other.successContainer),
      CampaignStatus.approved => (other.onWarningContainer, other.warningContainer),
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
