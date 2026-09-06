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

part 'merchant_ads_screen_parts.dart';
part 'merchant_ads_screen_card.dart';

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
              for (final price in board.prices) _PlacementRow(price: price),
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
