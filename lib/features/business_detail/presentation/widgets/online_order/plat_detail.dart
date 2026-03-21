import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/menu_restau.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/order_service.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';

class PlatDetail extends StatefulWidget {
  final MenuItem menuItem;
  final String? restaurantId;
  final String? restaurantName;
  final BusinessType? restaurantType;
  final bool isOrderMode; // mode consultation ou commande

  const PlatDetail({
    super.key,
    required this.menuItem,
    this.restaurantId,
    this.restaurantName,
    this.restaurantType,
    this.isOrderMode = true,
  });

  @override
  State<PlatDetail> createState() => _PlatDetailState();
}

class _PlatDetailState extends State<PlatDetail> {
  int _quantity = 1;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final menu = widget.menuItem;
    final totalPrice = menu.price * _quantity;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(menu.itemName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                menu.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.fastfood),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Nom
            Text(
              menu.itemName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Catégorie
            Text(
              menu.itemCategory,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            // Description
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(menu.description, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 16),
            // Ingrédients
            if (menu.ingredients.isNotEmpty) ...[
              const Text(
                'Ingrédients',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: menu.ingredients.map((ing) => Chip(label: Text(ing))).toList(),
              ),
            ],
            const SizedBox(height: 24),
            // Quantité
            if (widget.isOrderMode) ...[
              const Text(
                'Quantité',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                  ),
                  Text('$_quantity', style: const TextStyle(fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => _quantity++),
                  ),
                  const Spacer(),
                  Text(
                    'Total : ${totalPrice.toStringAsFixed(2)} €',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
      bottomNavigationBar: widget.isOrderMode
          ? Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppDimens.BORDER_RADIUS_30),
            topRight: Radius.circular(AppDimens.BORDER_RADIUS_30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text('Passer commande', style: TextStyle(color: AppColors.scaffoldBackground),),
          ),
        ),
      )
          : null,
    );
  }

  Future<void> _placeOrder() async {
    setState(() => _isLoading = true);
    final orderItem = OrderItem(
      menuItemId: widget.menuItem.itemName,
      name: widget.menuItem.itemName,
      price: widget.menuItem.price,
      quantity: _quantity,
    );
    final subtotal = widget.menuItem.price * _quantity;
    const tax = 0.0;
    final total = subtotal + tax;

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      establishmentId: widget.restaurantId ?? 'unknown',
      establishmentName: widget.restaurantName ?? 'Restaurant', // ← nom correct
      establishmentType: widget.restaurantType,                 // ← type correct
      orderDate: DateTime.now(),
      items: [orderItem],
      subtotal: subtotal,
      tax: tax,
      totalAmount: total,
      status: OrderStatus.pending,
      notes: null,
    );

    try {
      await OrderService.saveOrder(order);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commande passée !'), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Retour à la page précédente
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}