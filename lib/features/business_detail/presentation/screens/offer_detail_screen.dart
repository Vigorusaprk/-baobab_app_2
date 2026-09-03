import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:baobabe_0_2/core/widgets/auth_required_card.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_action_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_refresh.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/offer_detail_cubit.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_detail_skeleton.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_detail_views.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_purchase_bar.dart';
import 'package:baobabe_0_2/features/notification/domain/notification_reason.dart';
import 'package:baobabe_0_2/features/notification/presentation/notification_prompt.dart';
import 'package:baobabe_0_2/features/order/presentation/cubit/checkout_cubit.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/checkout_success_sheet.dart';
import 'package:baobabe_0_2/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:baobabe_0_2/features/settings/presentation/widgets/profile_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// La fiche d'une offre.
///
/// C'est la destination d'un clic sur une offre, où qu'elle apparaisse :
/// l'accueil, la recherche, ou le catalogue d'un commerçant. On y décide, et
/// on y commande ou réserve — la fiche du commerçant, elle, ne porte pas de
/// bouton d'achat.
///
/// **Trois mises en page, une par mode.** Une offre qu'on commande, une
/// qu'on réserve et une qu'on prend en boutique ne posent pas les mêmes
/// questions ; elles partageaient pourtant une seule page, avec des `if`
/// pour éteindre ce qui ne servait pas. Voir `offer_detail_views.dart`.
class OfferDetailScreen extends StatelessWidget {
  final String offerId;

  /// Ce que l'appelant sait déjà du mode de l'offre — il vient d'en toucher
  /// la carte, qui le porte. Sert **uniquement** au squelette : le serveur
  /// reste seul juge de ce que l'offre est vraiment.
  final Fulfilment? expected;

  const OfferDetailScreen({super.key, required this.offerId, this.expected});

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
      child: _OfferDetailView(expected: expected),
    );
  }
}

class _OfferDetailView extends StatelessWidget {
  const _OfferDetailView({this.expected});

  final Fulfilment? expected;

  /// Le jour touché dans les pastilles. L'heure est demandée aussitôt : une
  /// table sans heure n'est pas une réservation.
  Future<void> _pickDay(BuildContext context, DateTime day) async {
    final cubit = context.read<OfferDetailCubit>();
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (time == null || !context.mounted) return;
    cubit.setDate(
      DateTime(day.year, day.month, day.day, time.hour, time.minute),
    );
  }

  /// Le calendrier complet, pour une date au-delà des trois jours proposés.
  Future<void> _openCalendar(BuildContext context) async {
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
      // Pas d'`AppBar` : chaque mise en page porte sa propre barre, et celle
      // d'une réservation se pose **sur** la photo.
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: BlocBuilder<OfferDetailCubit, OfferDetailState>(
        builder: (context, state) {
          if (state is OfferDetailError) {
            return _Failure(message: state.message);
          }
          if (state is! OfferDetailLoaded) {
            return Skeletonizer(
              enabled: true,
              child: OfferDetailSkeleton(expected: expected),
            );
          }
          // Le rafraîchissement relit la fiche **sans** repasser par le
          // squelette : la jauge de places se met à jour, la page ne saute
          // pas.
          return CustomRefresh(
            onRefresh: context.read<OfferDetailCubit>().refresh,
            child: _layout(context, state),
          );
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
              onSubmit: () => _submit(context),
            ),
          );
        },
      ),
    );
  }

  Widget _layout(BuildContext context, OfferDetailLoaded state) {
    final setQuantity = context.read<OfferDetailCubit>().setQuantity;
    final offer = state.detail.offer;

    if (offer.isInStoreOnly) return OfferInStoreView(state: state);
    if (offer.isOrderable) {
      return OfferOrderView(state: state, onQuantityChanged: setQuantity);
    }
    return OfferBookingView(
      state: state,
      onQuantityChanged: setQuantity,
      onPickDay: (day) => _pickDay(context, day),
      onOpenCalendar: () => _openCalendar(context),
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
        padding: const EdgeInsets.all(AppDimens.large),
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
