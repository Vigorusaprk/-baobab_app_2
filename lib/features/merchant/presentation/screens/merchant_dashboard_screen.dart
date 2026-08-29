import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_space.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/merchant_widgets.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Ce que le commerçant voit en ouvrant l'application : ce qui l'attend,
/// puis ce que son commerce a produit.
class MerchantDashboardScreen extends StatelessWidget {
  final MerchantSpace space;
  final VoidCallback onSeeOffers;
  final VoidCallback onSeeInbox;

  const MerchantDashboardScreen({
    super.key,
    required this.space,
    required this.onSeeOffers,
    required this.onSeeInbox,
  });

  @override
  Widget build(BuildContext context) {
    final stats = space.stats;
    final business = space.business;
    final toHandle = stats.pendingOrders + stats.pendingReservations;

    return RefreshIndicator(
      onRefresh: () => context.read<MerchantCubit>().refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.appPaddingValue,
          0,
          AppDimens.appPaddingValue,
          100,
        ),
        children: [
          if (toHandle > 0)
            _ToHandleBanner(count: toHandle, onTap: onSeeInbox)
          else
            _AllClearBanner(business: business?.name ?? 'Votre commerce'),
          AppDimens.spacerMedium,
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              MerchantStatCard(
                value: '${stats.revenue.toStringAsFixed(0)} \$',
                label: 'Encaissé',
                icon: Icons.payments_outlined,
                color: OtherTheme.of(context).onSuccessContainer,
              ),
              MerchantStatCard(
                value: '${stats.offerCount}',
                label: 'Offres en ligne',
                icon: Icons.sell_outlined,
              ),
              MerchantStatCard(
                value: '${stats.pendingOrders}',
                label: 'Commandes à traiter',
                icon: Icons.receipt_long_outlined,
                color: OtherTheme.of(context).onWarningContainer,
              ),
              MerchantStatCard(
                value: '${stats.upcomingReservations}',
                label: 'Réservations à venir',
                icon: Icons.event_available_outlined,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
          AppDimens.spacerLarge,
          Text('Mon commerce', style: Theme.of(context).textTheme.titleMedium),
          AppDimens.spacerSmall,
          MerchantCard(
            onTap: business == null
                ? null
                : () => context.pushNamed(
                    'businessDetail',
                    pathParameters: {'id': business.id},
                  ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business?.name ?? '',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      AppDimens.spacerMini,
                      Text(
                        business?.address ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      AppDimens.spacerSmall,
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: OtherTheme.of(context).rating,
                          ),
                          AppDimens.spacerMiniWidth,
                          Text(
                            business == null || business.reviewCount == 0
                                ? 'Pas encore noté'
                                : '${business.rating.toStringAsFixed(1)} '
                                      '(${business.reviewCount} avis)',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          AppDimens.spacerSmall,
          Text(
            // La note du commerce n'est pas saisie : elle découle des avis
            // laissés sur ses offres. Le dire évite de la chercher.
            'Votre note est la moyenne des avis laissés sur vos offres.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          AppDimens.spacerLarge,
          _ActionRow(
            icon: Icons.add_circle_outline,
            label: 'Publier une offre',
            onTap: () => context.pushNamed('offerForm'),
          ),
          AppDimens.spacerSmall,
          _ActionRow(
            icon: Icons.sell_outlined,
            label: 'Gérer mes offres',
            onTap: onSeeOffers,
          ),
          AppDimens.spacerSmall,
          _ActionRow(
            icon: Icons.storefront_outlined,
            label: 'Parcourir Baobabe en client',
            onTap: () => context.go('/home'),
          ),
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
