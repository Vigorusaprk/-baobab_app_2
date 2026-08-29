import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_space.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/merchant_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Le catalogue du commerçant : ce qu'il propose, en ligne ou retiré.
///
/// Les offres retirées restent visibles ici — et seulement ici : elles sont
/// référencées par des commandes passées, les faire disparaître viderait
/// l'historique de ses clients.
class MerchantOffersScreen extends StatelessWidget {
  final MerchantSpace space;

  const MerchantOffersScreen({super.key, required this.space});

  @override
  Widget build(BuildContext context) {
    final offers = space.offers;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        onPressed: () => context.pushNamed('offerForm'),
        icon: const Icon(Icons.add),
        label: const Text('Publier'),
      ),
      body: offers.isEmpty
          ? const MerchantEmptyState(
              icon: Icons.sell_outlined,
              title: 'Aucune offre publiée',
              message: 'Publiez ce que vos clients peuvent commander ou '
                  'réserver chez vous.',
            )
          : RefreshIndicator(
              onRefresh: () => context.read<MerchantCubit>().refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.appPaddingValue,
                  0,
                  AppDimens.appPaddingValue,
                  100,
                ),
                itemCount: offers.length,
                separatorBuilder: (_, _) => AppDimens.spacerSmall,
                itemBuilder: (context, index) =>
                    _OfferTile(offer: offers[index]),
              ),
            ),
    );
  }
}

class _OfferTile extends StatelessWidget {
  final Offer offer;

  const _OfferTile({required this.offer});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MerchantCubit>();

    return MerchantCard(
      onTap: () => context.pushNamed('offerForm', extra: offer),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        offer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    AppDimens.spacerSmallWidth,
                    StatusChip(
                      label: offer.fulfilment.badge,
                      color: offer.isOrderable
                          ? AppColors.secondary
                          : offer.isBookable
                          ? AppColors.primary
                          : AppColors.warningContent,
                      surface: offer.isInStoreOnly
                          ? AppColors.warningSurface
                          : AppColors.primarySurface,
                    ),
                  ],
                ),
                AppDimens.spacerMini,
                Text(
                  _subtitle(offer),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                if (!offer.isActive) ...[
                  AppDimens.spacerSmall,
                  const StatusChip(
                    label: 'Retirée',
                    color: AppColors.errorContent,
                    surface: AppColors.errorSurface,
                  ),
                ],
              ],
            ),
          ),
          AppDimens.spacerSmallWidth,
          _OfferMenu(offer: offer, cubit: cubit),
        ],
      ),
    );
  }

  String _subtitle(Offer offer) {
    final parts = <String>[
      offer.isFree ? 'Sur demande' : '${offer.price.toStringAsFixed(2)} \$',
      if (offer.capacity != null) '${offer.capacity} places',
      if (offer.startsAt != null)
        DateFormat('dd/MM à HH:mm').format(offer.startsAt!.toLocal()),
      if (offer.reviewCount > 0)
        '${offer.rating.toStringAsFixed(1)}★ (${offer.reviewCount})',
    ];
    return parts.join(' · ');
  }
}

class _OfferMenu extends StatelessWidget {
  final Offer offer;
  final MerchantCubit cubit;

  const _OfferMenu({required this.offer, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
      onSelected: (value) async {
        if (value == 'edit') {
          context.pushNamed('offerForm', extra: offer);
          return;
        }
        final messenger = ScaffoldMessenger.of(context);
        final error = await cubit.setOfferActive(offer.id, value == 'publish');
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              error ??
                  (value == 'publish'
                      ? 'Offre remise en ligne'
                      : 'Offre retirée du catalogue'),
            ),
          ),
        );
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Modifier')),
        if (offer.isActive)
          const PopupMenuItem(value: 'retire', child: Text('Retirer'))
        else
          const PopupMenuItem(value: 'publish', child: Text('Remettre en ligne')),
      ],
    );
  }
}
