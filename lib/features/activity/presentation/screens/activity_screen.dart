import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/features/activity/presentation/widgets/activity_skeleton.dart';
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
                  'Mes Activites',
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
                Tab(text: 'Reservations'),
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
        itemBuilder: (_, i) => OrderCard(order: _orders[i]),
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
        itemBuilder: (_, i) =>
            ReservationCard(reservation: _reservations[i], onDelete: () {}),
      ),
    );
  }
}
