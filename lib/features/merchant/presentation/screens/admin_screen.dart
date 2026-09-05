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

/// Ce qu'il y a à faire, en trois nombres.
class _Counters extends StatelessWidget {
  const _Counters({required this.board});

  final AdBoard board;

  @override
  Widget build(BuildContext context) {
    final running = board.queue
        .where((c) => c.status == CampaignStatus.running)
        .length;
    final awaiting = board.queue
        .where((c) => c.status == CampaignStatus.approved)
        .length;

    // `IntrinsicHeight` + `stretch` : « En attente de règlement » tient sur
    // deux lignes là où « À examiner » n'en occupe qu'une, et les trois
    // cartes se retrouvaient de trois hauteurs différentes, désalignées en
    // haut comme en bas.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: MerchantStatCard(
              value: '${board.toReview.length}',
              label: 'À examiner',
              icon: Icons.gavel_rounded,
            ),
          ),
          AppDimens.spacerSmallWidth,
          Expanded(
            child: MerchantStatCard(
              value: '$awaiting',
              label: 'En attente de règlement',
              icon: Icons.hourglass_empty_rounded,
            ),
          ),
          AppDimens.spacerSmallWidth,
          Expanded(
            child: MerchantStatCard(
              value: '$running',
              label: 'En diffusion',
              icon: Icons.campaign_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

/// Une ligne de la file : ce qu'on lit avant de décider.
class _QueueRow extends StatelessWidget {
  const _QueueRow({required this.campaign, required this.onReview});

  final AdCampaign campaign;
  final VoidCallback? onReview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final format = DateFormat('d MMM', 'fr_FR');

    return MerchantCard(
      onTap: onReview,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.businessName ?? 'Commerce',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppDimens.spacerMini,
                Text(
                  '${campaign.target} · ${campaign.placement.label} · '
                  '${format.format(campaign.startsOn)} – '
                  '${format.format(campaign.endsOn)}',
                  maxLines: 2,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          AppDimens.spacerSmallWidth,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                money(campaign.dueAmount),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
              AppDimens.spacerMini,
              StatusChip(
                label: campaign.status.label,
                color: scheme.onSurfaceVariant,
                surface: scheme.surfaceContainerHighest,
              ),
            ],
          ),
          if (onReview != null)
            Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _ApplicationRow extends StatelessWidget {
  const _ApplicationRow({required this.application});

  final MerchantApplication application;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final date = application.createdAt;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.small),
      child: Row(
        children: [
          Expanded(
            child: Text(
              application.businessName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (date != null)
            Text(
              DateFormat('d MMM', 'fr_FR').format(date),
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
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

class _Quiet extends StatelessWidget {
  const _Quiet({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.medium),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
    );
  }
}

class _AdminSkeleton extends StatelessWidget {
  const _AdminSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(child: Bone(height: 84, uniRadius: 12)),
              AppDimens.spacerSmallWidth,
              Expanded(child: Bone(height: 84, uniRadius: 12)),
              AppDimens.spacerSmallWidth,
              Expanded(child: Bone(height: 84, uniRadius: 12)),
            ],
          ),
          AppDimens.spacerLarge,
          Bone.text(width: 110, style: theme.textTheme.labelSmall!),
          AppDimens.spacerSmall,
          for (var i = 0; i < 3; i++)
            const Padding(
              padding: EdgeInsets.only(bottom: AppDimens.small),
              child: Bone(width: double.infinity, height: 76, uniRadius: 12),
            ),
        ],
      ),
    );
  }
}
