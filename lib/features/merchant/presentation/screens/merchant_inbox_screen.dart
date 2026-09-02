import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_space.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/merchant_widgets.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/received_order_card.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/received_reservation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baobabe_0_2/core/widgets/custom_refresh.dart';

/// Ce que le commerce a reçu : commandes d'un côté, réservations de
/// l'autre. Les deux se traitent, mais pas avec les mêmes gestes — une
/// commande se prépare, une réservation se confirme.
class MerchantInboxScreen extends StatelessWidget {
  final MerchantSpace space;

  const MerchantInboxScreen({super.key, required this.space});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Commandes (${space.orders.length})'),
              Tab(text: 'Réservations (${space.reservations.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _OrdersTab(orders: space.orders),
                _ReservationsTab(reservations: space.reservations),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  final List<ReceivedOrder> orders;

  const _OrdersTab({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const MerchantEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Aucune commande',
        message: 'Les commandes passées chez vous apparaîtront ici.',
      );
    }

    return CustomRefresh(
      onRefresh: () => context.read<MerchantCubit>().refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.appPaddingValue,
          AppDimens.appPaddingValue,
          AppDimens.appPaddingValue,
          100,
        ),
        itemCount: orders.length,
        separatorBuilder: (_, _) => AppDimens.spacerSmall,
        itemBuilder: (context, index) =>
            ReceivedOrderCard(order: orders[index]),
      ),
    );
  }
}

class _ReservationsTab extends StatelessWidget {
  final List<ReceivedReservation> reservations;

  const _ReservationsTab({required this.reservations});

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) {
      return const MerchantEmptyState(
        icon: Icons.event_available_outlined,
        title: 'Aucune réservation',
        message: 'Les réservations faites chez vous apparaîtront ici.',
      );
    }

    return CustomRefresh(
      onRefresh: () => context.read<MerchantCubit>().refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.appPaddingValue,
          AppDimens.appPaddingValue,
          AppDimens.appPaddingValue,
          100,
        ),
        itemCount: reservations.length,
        separatorBuilder: (_, _) => AppDimens.spacerSmall,
        itemBuilder: (context, index) =>
            ReceivedReservationCard(reservation: reservations[index]),
      ),
    );
  }
}
