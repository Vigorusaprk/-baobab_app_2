import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/auth_required_card.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/offer_detail_cubit.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_detail_sections.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_detail_skeleton.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_purchase_bar.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/review_list_item.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/offers_carousel_section.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:baobabe_0_2/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/profile_sheets.dart';
import 'package:baobabe_0_2/core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_action_button.dart';
import 'package:baobabe_0_2/features/notification/domain/notification_reason.dart';
import 'package:baobabe_0_2/features/notification/presentation/notification_prompt.dart';
import 'package:baobabe_0_2/features/order/presentation/cubit/checkout_cubit.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/checkout_success_sheet.dart';
import 'package:baobabe_0_2/core/widgets/custom_refresh.dart';

/// La fiche d'une offre.
///
/// C'est désormais la destination d'un clic sur une offre, où qu'elle
/// apparaisse : sur l'accueil, dans la recherche, ou dans le catalogue d'un
/// commerçant. On y décide, et on y commande ou réserve — la fiche du
/// commerçant, elle, ne porte plus de bouton d'action.
class OfferDetailScreen extends StatelessWidget {
  final String offerId;

  const OfferDetailScreen({super.key, required this.offerId});

  @override
  Widget build(BuildContext context) {
    // Deux cubits, deux responsabilités : l'un lit la fiche, l'autre valide
    // l'achat. Ils étaient confondus, et une validation réussie faisait
    // repasser la page entière par son squelette.
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => OfferDetailCubit(offerId: offerId)..load()),
        BlocProvider(create: (_) => CheckoutCubit()),
      ],
      child: const _OfferDetailView(),
    );
  }
}

class _OfferDetailView extends StatelessWidget {
  const _OfferDetailView();

  Future<void> _pickDate(BuildContext context) async {
    final cubit = context.read<OfferDetailCubit>();
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (!context.mounted) return;

    cubit.setDate(
      DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 12,
        time?.minute ?? 0,
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final state = context.read<OfferDetailCubit>().state;
    if (state is! OfferDetailLoaded) return;

    if (state.isDateMissing) {
      _notify(context, 'Choisissez d\'abord une date.');
      return;
    }

    // Ce qui manquait : le commerçant recevait une commande sans savoir où la
    // livrer. On demande donc l'adresse avant d'envoyer — et pour une
    // réservation, qui ne se livre pas, un moyen de joindre le client.
    String? deliveryAddress;
    String? contactPhone;

    if (state.detail.offer.isOrderable) {
      final choice = await showDeliverySheet(context);
      if (choice == null || !context.mounted) return;
      deliveryAddress = choice.address.oneLine;
      if (choice.remember) {
        await context.read<ProfileCubit>().save(address: choice.address);
        if (!context.mounted) return;
      }
    } else {
      final choice = await showContactSheet(context);
      if (choice == null || !context.mounted) return;
      contactPhone = choice.phone;
      if (choice.remember && choice.phone != null) {
        await context.read<ProfileCubit>().save(phone: choice.phone);
        if (!context.mounted) return;
      }
    }

    // L'issue est traitée par le `BlocListener` du `CheckoutCubit`, plus bas :
    // c'est lui qui montre l'animation ou l'erreur. Cet appel ne fait que
    // lancer la validation.
    await context.read<CheckoutCubit>().submit(
      detail: state.detail,
      quantity: state.quantity,
      chosenDate: state.chosenDate,
      deliveryAddress: deliveryAddress,
      contactPhone: contactPhone,
    );
  }

  /// Ce qui se passe quand la validation aboutit ou échoue.
  Future<void> _onCheckout(BuildContext context, CheckoutState state) async {
    final checkout = context.read<CheckoutCubit>();

    if (state is CheckoutFailed) {
      checkout.acknowledge();
      if (state.message == 'Connectez-vous pour continuer.') {
        showAuthRequiredCard(
          context,
          message: 'Connectez-vous pour finaliser votre demande.',
        );
        return;
      }
      _notify(context, state.message, isError: true);
      return;
    }

    if (state is! CheckoutSucceeded) return;
    checkout.acknowledge();

    // La coche se trace, le message se lit, la feuille part d'elle-même.
    // Même forme que la fin de la connexion par code : c'est le seul signal
    // qui dit « c'est fait » sans ambiguïté.
    await showCheckoutSuccessSheet(context, kind: state.kind);
    if (!context.mounted) return;

    // La jauge de places a bougé. On relit **sans** repasser par le
    // squelette : la page reste celle qu'on regardait.
    context.read<OfferDetailCubit>().refresh();

    await NotificationPrompt.maybeAsk(
      context,
      state.kind.isOrder
          ? NotificationReason.orderPlaced
          : NotificationReason.reservationPlaced,
    );
  }

  void _notify(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : OtherTheme.of(context).onSuccessContainer,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const CustomOtherAppBar(title: "Détail de l'offre"),
      body: BlocBuilder<OfferDetailCubit, OfferDetailState>(
        builder: (context, state) {
          if (state is OfferDetailError) {
            return _Failure(message: state.message);
          }
          if (state is! OfferDetailLoaded) {
            return const Skeletonizer(
              enabled: true,
              child: OfferDetailSkeleton(),
            );
          }
          return _Content(state: state);
        },
      ),
      bottomNavigationBar: BlocBuilder<OfferDetailCubit, OfferDetailState>(
        builder: (context, state) {
          if (state is! OfferDetailLoaded) return const SizedBox.shrink();
          return BlocConsumer<CheckoutCubit, CheckoutState>(
            listener: _onCheckout,
            builder: (context, checkout) => OfferPurchaseBar(
              state: state,
              isSubmitting: checkout is CheckoutSubmitting,
              onQuantityChanged: context.read<OfferDetailCubit>().setQuantity,
              onPickDate: () => _pickDate(context),
              onSubmit: () => _submit(context),
            ),
          );
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final OfferDetailLoaded state;

  const _Content({required this.state});

  @override
  Widget build(BuildContext context) {
    final detail = state.detail;
    final offer = detail.offer;
    final merchant = detail.merchant;

    // Le rafraichissement relit la fiche **sans** repasser par le squelette :
    // la jauge de places se met a jour, la page ne saute pas.
    return CustomRefresh(
      onRefresh: context.read<OfferDetailCubit>().refresh,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          OfferDetailHeader(offer: offer),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.appPaddingValue,
              AppDimens.appPaddingValue,
              AppDimens.appPaddingValue,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                AppDimens.spacerSmall,
                Row(
                  children: [
                    Text(
                      offer.isFree
                          ? 'Sur demande'
                          : '${offer.price.toStringAsFixed(2)} \$',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    if (offer.reviewCount > 0) ...[
                      Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: OtherTheme.of(context).rating,
                      ),
                      Text(
                        '${offer.rating.toStringAsFixed(1)} '
                        '(${offer.reviewCount})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
                if (offer.description.isNotEmpty) ...[
                  AppDimens.spacerMedium,
                  Text(
                    offer.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ],
                AppDimens.spacerMedium,
                OfferFacts(detail: detail),
                if (merchant != null) ...[
                  AppDimens.spacerSmall,
                  Text(
                    'Proposé par',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  AppDimens.spacerSmall,
                  OfferMerchantCard(merchant: merchant),
                ],
                if (detail.reviews.isNotEmpty) ...[
                  AppDimens.spacerLarge,
                  Text('Avis', style: Theme.of(context).textTheme.titleMedium),
                  AppDimens.spacerSmall,
                  for (final review in detail.reviews)
                    ReviewListItem(review: review),
                ],
              ],
            ),
          ),
          if (detail.otherOffers.isNotEmpty) ...[
            AppDimens.spacerLarge,
            OffersCarouselSection(
              title: 'Chez le même commerçant',
              offers: detail.otherOffers,
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Failure extends StatelessWidget {
  final String message;

  const _Failure({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            AppDimens.spacerMedium,
            CustomActionButton(
              label: 'Réessayer',
              icon: Icons.refresh_rounded,
              onPressed: () => context.read<OfferDetailCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }
}
