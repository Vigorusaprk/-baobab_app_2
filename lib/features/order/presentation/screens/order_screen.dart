import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/order_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';

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

  // Méthodes pour obtenir l'icône, la couleur et le nom d'affichage
  IconData _getTypeIcon(BusinessType? type) {
    if (type == null) return Icons.business;
    switch (type) {
      case BusinessType.restaurant:
        return Icons.restaurant;
      case BusinessType.fastFood:
        return Icons.fastfood;
      case BusinessType.shopping:
        return Icons.shopping_bag;
      case BusinessType.mall:
        return Icons.store_mall_directory;
      case BusinessType.hotel:
        return Icons.hotel;
      case BusinessType.carRental:
        return Icons.directions_car;
      case BusinessType.detente:
        return Icons.spa;
      case BusinessType.travelAgency:
        return Icons.card_travel;
      case BusinessType.spa:
        return Icons.spa;
      default:
        return Icons.business;
    }
  }

  Color _getTypeColor(BusinessType? type) {
    if (type == null) return Colors.grey;
    switch (type) {
      case BusinessType.restaurant:
        return Colors.orange;
      case BusinessType.fastFood:
        return Colors.red;
      case BusinessType.shopping:
        return Colors.blue;
      case BusinessType.mall:
        return Colors.purple;
      case BusinessType.hotel:
        return Colors.teal;
      case BusinessType.carRental:
        return Colors.indigo;
      case BusinessType.detente:
        return Colors.green;
      case BusinessType.travelAgency:
        return Colors.indigoAccent;
      case BusinessType.spa:
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String _getTypeDisplayName(BusinessType? type) {
    if (type == null) return 'Autre';
    switch (type) {
      case BusinessType.restaurant:
        return 'Restaurant';
      case BusinessType.fastFood:
        return 'Fast Food';
      case BusinessType.shopping:
        return 'Shopping';
      case BusinessType.mall:
        return 'Centre Commercial';
      case BusinessType.hotel:
        return 'Hôtel';
      case BusinessType.carRental:
        return 'Location Voiture';
      case BusinessType.detente:
        return 'Détente';
      case BusinessType.travelAgency:
        return 'Agence de voyages';
      case BusinessType.spa:
        return 'Spa';
      default:
        return 'Autre';
    }
  }

  Widget _buildOrderCard(Order order) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final type = order.establishmentType;
    final typeIcon = _getTypeIcon(type);
    final typeColor = _getTypeColor(type);
    final typeName = _getTypeDisplayName(type);

    return Card(
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
              // En-tête avec icône, nom et statut
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(typeIcon, color: typeColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.establishmentName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                typeName,
                                style: TextStyle(color: typeColor, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
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
                      style: TextStyle(color: order.status.color, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                dateFormat.format(order.orderDate),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 12),
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
        color: Colors.white,
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
                    _buildDetailRow('Type', _getTypeDisplayName(order.establishmentType)),
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
                          Expanded(child: Text('${item.quantity}x ${item.name}')),
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
                  child: const Text('Fermer'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à implémenter')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Recommander'),
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