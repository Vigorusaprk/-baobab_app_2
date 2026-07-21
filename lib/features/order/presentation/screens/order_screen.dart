import 'package:baobabe_0_2/features/main/presentation/widgets/app_background.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/order_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:baobabe_0_2/core/services/session_service.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/order_card.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/order_empty_states.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/order_filter_chip.dart';


class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with WidgetsBindingObserver {
  List<Order> _allOrders = [];
  List<Order> _displayedOrders = [];
  bool _isLoading = true;
  OrderStatus? _selectedStatusFilter;
  final List<OrderStatus> _availableStatuses = OrderStatus.values;
  String _userId = "";
  late final OrderApiService _apiService;
  final String _visibilityId = 'order_screen'; // ✅ Défini ici

  @override
  void initState() {
    super.initState();
    _apiService = OrderApiService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserId();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadOrders();
    }
  }

  Future<void> _loadUserId() async {
    final user = SessionService.instance.currentUser;
    if (user != null) {
      _userId = user.id;
      await _loadOrders();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadOrders() async {
    if (_userId.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final orders = await _apiService.getOrders(_userId);
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      setState(() {
        _allOrders = orders;
        _displayedOrders = orders;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterOrders(OrderStatus? status) {
    setState(() {
      _selectedStatusFilter = status;
      if (status == null) {
        _displayedOrders = _allOrders;
      } else {
        _displayedOrders = _allOrders.where((o) => o.status == status).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return authBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // En‑tête "Mes Commandes"
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 55, 20, 20),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/order.svg',
                    height: 35,
                    colorFilter: const ColorFilter.mode(
                      AppColors.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: AppDimens.PADDING_12),
                  Expanded(
                    child: Text(
                      'Mes Commandes',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFontFamily,
                        fontSize: 24,
                        fontWeight: AppFonts.bold,
                        color: AppColors.secondaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_allOrders.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.PADDING_12,
                        vertical: AppDimens.PADDING_6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryLight,
                        borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_16),
                      ),
                      child: Text(
                        '${_allOrders.length}',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: AppFonts.semiBold,
                          fontSize: 14,
                        ),
                      ),
                    ),

                ],
              ),
            ),

            // Filtres
            if (_allOrders.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        OrderFilterChip(
                          label: 'Toutes',
                          status: null,
                          isSelected: _selectedStatusFilter == null,
                          onTap: () => _filterOrders(null),
                        ),
                        ..._availableStatuses.map((status) => OrderFilterChip(
                          label: status.displayName,
                          status: status,
                          isSelected: _selectedStatusFilter == status,
                          onTap: () => _filterOrders(status),
                        )),
                      ],
                    ),
                  ),
                ),
              ),

            // Contenu principal avec détecteur de visibilité
            Expanded(
              child: VisibilityDetector(
                key: Key(_visibilityId),
                onVisibilityChanged: (info) {
                  if (info.visibleFraction > 0.1) {
                    _loadOrders();
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05,),
                  child: _buildContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allOrders.isEmpty) {
      return const OrderEmptyState();
    }

    if (_displayedOrders.isEmpty) {
      return OrderFilteredEmptyState(onShowAll: () => _filterOrders(null));
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
        itemCount: _displayedOrders.length,
        itemBuilder: (context, index) {
          final order = _displayedOrders[index];
          return OrderCard(order: order);
        },
      ),
    );
  }
}
