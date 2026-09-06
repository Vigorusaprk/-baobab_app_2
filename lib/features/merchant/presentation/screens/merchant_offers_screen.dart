import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_space.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/merchant_widgets.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:baobabe_0_2/core/widgets/custom_pop_up.dart';
import 'package:baobabe_0_2/core/widgets/custom_refresh.dart';
import 'package:baobabe_0_2/core/widgets/remote_image.dart';

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
        onPressed: () => context.pushNamed('offerForm'),
        icon: const Icon(Icons.add),
        label: const Text('Publier'),
      ),
      body: offers.isEmpty
          ? const MerchantEmptyState(
              icon: Icons.sell_outlined,
              title: 'Aucune offre publiée',
              message:
                  'Publiez ce que vos clients peuvent commander ou '
                  'réserver chez vous.',
            )
          : CustomRefresh(
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
                itemBuilder: (context, index) => _OfferTile(
                  offer: offers[index],
                  slotCount: space.availability[offers[index].id] ?? 0,
                ),
              ),
            ),
    );
  }
}

class _OfferTile extends StatelessWidget {
  final Offer offer;

  /// Combien de plages de rendez-vous cette offre déclare. Zéro sur une offre
  /// réservable veut dire que le client propose encore la date qu'il veut.
  final int slotCount;

  const _OfferTile({required this.offer, this.slotCount = 0});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MerchantCubit>();

    return MerchantCard(
      onTap: () => context.pushNamed('offerForm', extra: offer),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // La photo : c'est elle que le client voit, et un catalogue qui ne
          // la montre pas laisse le commerçant découvrir ses cadres vides sur
          // l'accueil.
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.small),
            child: SizedBox(
              width: 52,
              height: 52,
              child: offer.displayImage == null
                  ? ColoredBox(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.image_outlined,
                        size: AppDimens.medium,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    )
                  : RemoteImage(url: offer.displayImage),
            ),
          ),
          AppDimens.spacerMediumWidth,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Le nom occupe sa ligne entière. La pastille de mode
                // partageait cette ligne, et « Chambre Executive » se
                // réduisait à « Chambre Ex… » sur un écran de 1080 px :
                // le commerçant ne reconnaissait plus ses propres offres.
                // Elle est descendue d'une ligne, où elle borde un texte
                // court.
                Text(
                  offer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                AppDimens.spacerMini,
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _subtitle(offer),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    AppDimens.spacerSmallWidth,
                    StatusChip(
                      label: offer.fulfilment.badge,
                      color: offer.isOrderable
                          ? Theme.of(context).colorScheme.secondary
                          : offer.isBookable
                          ? Theme.of(context).colorScheme.primary
                          : OtherTheme.of(context).onWarningContainer,
                      surface: offer.isInStoreOnly
                          ? OtherTheme.of(context).warningContainer
                          : Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ],
                ),
                if (!offer.isActive) ...[
                  AppDimens.spacerSmall,
                  StatusChip(
                    label: 'Retirée',
                    color: Theme.of(context).colorScheme.error,
                    surface: Theme.of(context).colorScheme.errorContainer,
                  ),
                ],
                // Les rendez-vous ne concernent que ce qui se réserve : les
                // proposer ailleurs serait un réglage sans effet.
                if (offer.isBookable && offer.isActive) ...[
                  AppDimens.spacerSmall,
                  _SlotsLink(offer: offer, slotCount: slotCount),
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
      tooltip: 'Actions sur cette offre',
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onSelected: (value) async {
        if (value == 'edit') {
          context.pushNamed('offerForm', extra: offer);
          return;
        }
        if (value == 'slots') {
          context.push('/merchant/slots', extra: offer);
          return;
        }
        final messenger = ScaffoldMessenger.of(context);
        // Retirer est irréversible du point de vue du client : son offre
        // disparaît du catalogue à l'instant. On le nomme avant de le faire.
        if (value == 'retire') {
          final confirmed = await showCustomPopUp(
            context: context,
            title: 'Retirer « ${offer.name} » ?',
            message:
                'Elle disparaît du catalogue tout de suite. Les commandes '
                'déjà passées la gardent, et vous pouvez la remettre en '
                'ligne quand vous voulez.',
          );
          if (!confirmed) return;
        }
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
        if (offer.isBookable)
          const PopupMenuItem(value: 'slots', child: Text('Rendez-vous')),
        if (offer.isActive)
          const PopupMenuItem(value: 'retire', child: Text('Retirer'))
        else
          const PopupMenuItem(
            value: 'publish',
            child: Text('Remettre en ligne'),
          ),
      ],
    );
  }
}

/// Ce que l'offre déclare comme rendez-vous, et le geste pour le changer.
class _SlotsLink extends StatelessWidget {
  const _SlotsLink({required this.offer, required this.slotCount});

  final Offer offer;
  final int slotCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final declared = slotCount > 0;

    return InkWell(
      onTap: () => context.push('/merchant/slots', extra: offer),
      borderRadius: BorderRadius.circular(AppDimens.radius8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              declared ? Icons.schedule_rounded : Icons.schedule_outlined,
              size: 14,
              color: declared ? scheme.primary : scheme.onSurfaceVariant,
            ),
            AppDimens.spacerMiniWidth,
            Text(
              declared
                  ? '$slotCount plage${slotCount > 1 ? 's' : ''} de rendez-vous'
                  : 'Aucun créneau déclaré',
              style: theme.textTheme.labelSmall?.copyWith(
                color: declared ? scheme.primary : scheme.onSurfaceVariant,
                fontWeight: declared ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
