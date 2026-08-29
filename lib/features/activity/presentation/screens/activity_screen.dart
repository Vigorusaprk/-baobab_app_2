import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/features/activity/presentation/widgets/activity_skeleton.dart';
import 'package:baobabe_0_2/features/activity/presentation/widgets/rate_offer_sheet.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_service.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/reservation.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/order_service.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/order_card.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/order_empty_states.dart';
import 'package:baobabe_0_2/features/booking_page/presentation/widgets/reservation_card.dart';
import 'package:baobabe_0_2/features/booking_page/presentation/widgets/reservation_empty_state.dart';
import 'package:flutter/material.dart';

/// Body-only content for the Orders/Activity tab. The Scaffold is owned by
/// MainShell, which is the single Scaffold for the app's main navigation.
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});
  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _orderApi = OrderApiService();
  final _resApi = ReservationApiService();
  List<Order> _orders = [];
  List<Reservation> _reservations = [];
  bool _loading = true;
  String _userId = "";

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadUserId();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final user = SessionService.instance.currentUser;
    if (user != null) {
      _userId = user.id;
      await _loadAll();
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _orderApi.getOrders(_userId),
        _resApi.getReservations(userId: _userId),
      ]);
      setState(() {
        _orders = results[0] as List<Order>;
        _orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
        _reservations = results[1] as List<Reservation>;
      });
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 55, 20, 10),
            child: Row(
              children: [
                Icon(Icons.assignment, color: AppColors.primary, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Mes activités',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_orders.length + _reservations.length}',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabCtrl,
              indicatorPadding: EdgeInsetsGeometry.symmetric(horizontal: -55),
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.primary,
              dividerHeight: 0,
              tabs: const [
                Tab(text: 'Commandes'),
                Tab(text: 'Réservations'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [_buildOrdersList(), _buildReservationsList()],
            ),
          ),
        ],
      ),
    );
  }

  /// Demande confirmation avant une action irréversible, en nommant ce
  /// qui va être annulé plutôt qu'un « Oui / Non » sans contexte.
  Future<bool> _confirm(String title, String message, String action) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Revenir'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(action, style: const TextStyle(color: AppColors.errorContent)),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  void _notify(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _cancelOrder(Order order) async {
    if (!await _confirm(
      'Annuler la commande ?',
      'La commande chez ${order.establishmentName} sera annulée.',
      'Annuler la commande',
    )) {
      return;
    }
    try {
      await _orderApi.cancelOrder(order.id);
      _notify('Commande annulée.', AppColors.successContent);
      await _loadAll();
    } catch (e) {
      _notify("$e", AppColors.errorContent);
    }
  }

  Future<void> _deleteReservation(Reservation reservation) async {
    if (!await _confirm(
      'Supprimer la réservation ?',
      'Votre réservation chez ${reservation.establishmentName} sera supprimée.',
      'Supprimer',
    )) {
      return;
    }
    try {
      await _resApi.deleteReservation(reservation.id.toString());
      _notify('Réservation supprimée.', AppColors.successContent);
      await _loadAll();
    } catch (e) {
      _notify("$e", AppColors.errorContent);
    }
  }

  /// Propose de noter ce qui a été livré.
  ///
  /// Une commande peut contenir plusieurs offres : on demande d'abord
  /// laquelle, plutôt que d'attribuer arbitrairement la note à la première.
  /// Seules les lignes rattachées à une offre sont notables — les commandes
  /// passées avant le moule `offers` n'en portent pas.
  Future<void> _rateOrder(Order order) async {
    final rateable = order.items.where((i) => i.offerId != null).toList();
    if (rateable.isEmpty) {
      _notify('Cette commande ne peut pas être notée.', AppColors.errorContent);
      return;
    }

    var item = rateable.first;
    if (rateable.length > 1) {
      final chosen = await showModalBottomSheet<OrderItem>(
        context: context,
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Que souhaitez-vous noter ?'),
              ),
              for (final line in rateable)
                ListTile(
                  title: Text(line.name),
                  onTap: () => Navigator.of(context).pop(line),
                ),
            ],
          ),
        ),
      );
      if (chosen == null || !mounted) return;
      item = chosen;
    }

    final rated = await showRateOfferSheet(
      context,
      businessId: order.establishmentId,
      offerId: item.offerId!,
      offerName: item.name,
    );
    if (rated && mounted) await _loadAll();
  }

  Widget _buildOrdersList() {
    if (_loading) {
      return const ActivityListSkeleton(itemSkeleton: OrderCardSkeleton());
    }
    if (_orders.isEmpty) return const OrderEmptyState();
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (_, i) => OrderCard(
          order: _orders[i],
          onCancel: _orders[i].status.canBeCancelledByCustomer
              ? () => _cancelOrder(_orders[i])
              : null,
          onRate: _orders[i].status == OrderStatus.delivered
              ? () => _rateOrder(_orders[i])
              : null,
        ),
      ),
    );
  }

  Widget _buildReservationsList() {
    if (_loading) {
      return const ActivityListSkeleton(
        itemSkeleton: ReservationCardSkeleton(),
      );
    }
    if (_reservations.isEmpty) return const ReservationEmptyState();
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reservations.length,
        itemBuilder: (_, i) => ReservationCard(
          reservation: _reservations[i],
          onDelete: () => _deleteReservation(_reservations[i]),
        ),
      ),
    );
  }
}
