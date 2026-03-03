import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/order_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';


class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<Order> _allOrders = [];
  List<Order> _displayedOrders = [];
  bool _isLoading = true;
  OrderStatus? _selectedStatusFilter;

  final List<OrderStatus> _availableStatuses = OrderStatus.values;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await OrderService.getOrders();
    // Trier par date décroissante
    orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    setState(() {
      _allOrders = orders;
      _displayedOrders = orders;
      _isLoading = false;
    });
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

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOrderDetailSheet(order),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Mes Commandes'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres par statut
          if (_allOrders.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, OrderStatus? status, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _filterOrders(status),
        backgroundColor: Colors.grey[200],
        selectedColor: status?.color ?? AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_alt_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucune commande avec ce statut',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _filterOrders(null),
              child: const Text('Voir toutes les commandes'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Aucune commande',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Vos commandes apparaîtront ici',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.establishmentName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dateFormat.format(order.orderDate),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 12),
              // Résumé des articles
              ...order.items.take(2).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.quantity}x ${item.name}'),
                    Text('${(item.price * item.quantity).toStringAsFixed(2)} \$'),
                  ],
                ),
              )),
              if (order.items.length > 2)
                Text(
                  '+${order.items.length - 2} autres articles',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '${order.totalAmount.toStringAsFixed(2)} \$',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetailSheet(Order order) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Détails de la commande',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: order.status.color,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDetailSection('Restaurant', [
                    _buildDetailRow('Nom', order.establishmentName),
                  ]),
                  _buildDetailSection('Date et heure', [
                    _buildDetailRow('Passée le', dateFormat.format(order.orderDate)),
                  ]),
                  _buildDetailSection('Articles', [
                    ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text('${item.quantity}x ${item.name}'),
                          ),
                          Text('${(item.price * item.quantity).toStringAsFixed(2)} \$'),
                        ],
                      ),
                    )),
                  ]),
                  _buildDetailSection('Paiement', [
                    _buildDetailRow('Sous-total', '${order.subtotal.toStringAsFixed(2)} \$'),
                    _buildDetailRow('Taxes', '${order.tax.toStringAsFixed(2)} \$'),
                    const Divider(),
                    _buildDetailRow('Total', '${order.totalAmount.toStringAsFixed(2)} \$', isBold: true),
                  ]),
                  if (order.notes != null && order.notes!.isNotEmpty)
                    _buildDetailSection('Notes', [
                      Text(order.notes!),
                    ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer', style: TextStyle(color: AppColors.primary),),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Ici vous pouvez ajouter la logique pour recommander
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à implémenter')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Recommander', style: TextStyle(color: AppColors.scaffoldBackground)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}