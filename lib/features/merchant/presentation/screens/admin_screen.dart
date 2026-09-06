import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/custom_app_bar.dart';
import 'package:baobabe_0_2/core/widgets/custom_refresh.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_extras.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_space.dart';
import 'package:baobabe_0_2/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:baobabe_0_2/features/merchant/presentation/screens/merchant_ads_screen.dart'
    show money;
import 'package:baobabe_0_2/features/merchant/presentation/widgets/campaign_sheets.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/merchant_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'admin_screen_parts.dart';

/// Le panneau d'administration de la plateforme.
///
/// Il n'en existait aucun : les demandes de compte commerçant étaient donc
/// acceptées à l'aveugle, et une campagne publicitaire ne pouvait pas être
/// validée avant d'être réclamée. « Valider avant de faire payer » demandait
/// un endroit où valider.
///
/// **Invisible pour tout autre compte.** L'accès tient à une ligne dans
/// `platform_admins`, que rien dans l'application ne peut créer : on n'ajoute
/// un administrateur qu'en SQL.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  AdBoard? _board;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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
  }

  Future<void> _review(AdCampaign campaign) async {
    final done = await showCampaignReviewSheet(context, campaign: campaign);
    if (done == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final board = _board;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomOtherAppBar(title: 'Administration'),
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
            if (board == null && _error == null)
              const _AdminSkeleton()
            else if (_error != null)
              MerchantEmptyState(
                icon: Icons.wifi_off_rounded,
                title: 'File injoignable',
                message: _error!,
              )
            else ...[
              _Counters(board: board!),
              AppDimens.spacerLarge,

              const _SectionTitle('À examiner'),
              if (board.toReview.isEmpty)
                const _Quiet(message: 'Rien n\'attend de décision.')
              else
                for (final campaign in board.toReview)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.small),
                    child: _QueueRow(
                      campaign: campaign,
                      onReview: () => _review(campaign),
                    ),
                  ),

              AppDimens.spacerLarge,
              const _SectionTitle('Validées et en diffusion'),
              for (final campaign in board.queue.where(
                (c) => c.status != CampaignStatus.inReview,
              ))
                Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.small),
                  child: _QueueRow(campaign: campaign, onReview: null),
                ),
              if (board.queue.every((c) => c.status == CampaignStatus.inReview))
                const _Quiet(
                  message: 'Aucune campagne réglée pour l\'instant.',
                ),

              AppDimens.spacerLarge,
              const _SectionTitle('Derniers commerces inscrits'),
              _Note(
                text:
                    'Les demandes de compte sont acceptées automatiquement, '
                    'en attendant une modération. Elles sont ici pour être '
                    'vues, pas arbitrées.',
              ),
              AppDimens.spacerSmall,
              for (final application in board.applications)
                _ApplicationRow(application: application),
              if (board.applications.isEmpty)
                const _Quiet(message: 'Aucune demande.'),
            ],
          ],
        ),
      ),
    );
  }
}
