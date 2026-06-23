import 'package:baobabe_0_2/features/order/presentation/widgets/order_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:baobabe_0_2/features/main/presentation/widgets/main_background.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:baobabe_0_2/features/auth/presentation/bloc/auth_state.dart';


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
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedState) {
      _userId = authState.user.id;
      await _loadOrders();
    } else {
      context.go('/login');
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
    return MainBackground(
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
                        _buildFilterChip('Toutes', null, _selectedStatusFilter == null),
                        ..._availableStatuses.map((status) => _buildFilterChip(
                          status.displayName,
                          status,
                          _selectedStatusFilter == status,
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

  Widget _buildFilterChip(
      String label,
      OrderStatus? status,
      bool isSelected, {
        Color? selectedColor,
        Color? unselectedColor,
        Color? labelColor,
        Color? selectedLabelColor,
        double? fontSize,
        FontWeight? fontWeight,
        EdgeInsetsGeometry? padding,
        double? borderRadius,
        bool showIcon = true,
        IconData? icon,
        VoidCallback? onTap,
      }) {
    final effectiveSelectedColor = selectedColor ?? AppColors.secondaryLight;
    final effectiveUnselectedColor = unselectedColor ?? AppColors.grey.withOpacity(0.3);
    final effectiveLabelColor =   AppColors.secondary;
    final effectiveSelectedLabelColor = selectedLabelColor ?? AppColors.scaffoldBackground;
    final effectiveFontSize = fontSize ?? 14;
    final effectiveFontWeight = fontWeight ?? FontWeight.w500;
    final effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    final effectiveBorderRadius = borderRadius ?? 20.0;

    return Padding(
      padding: EdgeInsetsGeometry.only(left: 10),
      child: GestureDetector(
        onTap: onTap ?? () => _filterOrders(status),
        child: Container(
          padding: effectivePadding,
          decoration: BoxDecoration(
            color: isSelected ? effectiveSelectedColor : effectiveUnselectedColor,
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: effectiveSelectedColor.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? effectiveSelectedLabelColor : effectiveLabelColor,
                  fontSize: effectiveFontSize,
                  fontWeight: effectiveFontWeight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allOrders.isEmpty) {
      return _buildEmptyState();
    }

    if (_displayedOrders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_alt_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune commande',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryLight,
                        fontFamily: AppFonts.primaryFontFamily,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aucune commande avec ce statut',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: AppFonts.primaryFontFamily,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _filterOrders(null),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.secondaryLight,
                          side: const BorderSide(color: AppColors.secondaryLight, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Voir toutes les commandes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
        itemCount: _displayedOrders.length,
        itemBuilder: (context, index) {
          final order = _displayedOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Boîte principale avec gradient et ombre
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icône avec fond coloré
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Titre
                  Text(
                    'Aucune commande',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.scaffoldBackground,
                      fontFamily: AppFonts.primaryFontFamily,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Sous-titre
                  Text(
                    'Vous n\'avez pas encore passé de commande',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: AppFonts.primaryFontFamily,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explorez nos restaurants et magasins pour commencer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontFamily: AppFonts.primaryFontFamily,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Bouton d'action
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/home'),
                      icon: const Icon(Icons.storefront_outlined, size: 20),
                      label: const Text(
                        'Découvrir les commerces',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.scaffoldBackground,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== Méthodes d'affichage ==========
  Widget _buildOrderCard(Order order) {
    try {
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

      return Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => context.pushNamed('orderDetail', extra: order),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: order.typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(order.typeIcon, color: order.typeColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.establishmentName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: order.typeColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  order.typeName,
                                  style: TextStyle(
                                    color: order.typeColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: order.status.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.status.displayName,
                        style: TextStyle(
                          color: order.status.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  dateFormat.format(order.orderDate),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontFamily: "Poppins",
                  ),
                ),
                const SizedBox(height: 12),
                ...order.items.take(2).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.quantity}x ${item.name}',
                        style: const TextStyle(fontFamily: "Poppins"),
                      ),
                      Text(
                        '${(item.price * item.quantity).toStringAsFixed(2)} \$',
                        style: const TextStyle(fontFamily: "Poppins"),
                      ),
                    ],
                  ),
                )),
                if (order.items.length > 2)
                  Text(
                    '+${order.items.length - 2} autres articles',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontFamily: "Poppins",
                    ),
                  ),
                const SizedBox(height: AppDimens.PADDING_20),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.PADDING_10,
                    vertical: AppDimens.PADDING_10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppDimens.BORDER_RADIUS_15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: "Poppins",
                        ),
                      ),
                      Text(
                        '${order.totalAmount.toStringAsFixed(2)} \$',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.primary,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e, stack) {
      print('Erreur lors du rendu de la commande : $e');
      print(stack);
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Erreur d’affichage : $e'),
        ),
      );
    }
  }
}