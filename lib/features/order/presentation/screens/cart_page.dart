import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baobabe_0_2/features/order/presentation/bloc/cart_bloc.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/order_service.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';

class CartPage extends StatelessWidget {
  final String? restaurantId;
  final String? restaurantName;
  final BusinessType? restaurantType;

  const CartPage({
    super.key,
    this.restaurantId,
    this.restaurantName,
    this.restaurantType,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();
    final state = cubit.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon panier'),
        backgroundColor: Colors.white,
      ),
      body: state.items.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Votre panier est vide'),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.fastfood),
                    title: Text(item.menuItem.itemName),
                    subtitle: Text('${item.menuItem.price} €'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => cubit.updateQuantity(item.menuItem, item.quantity - 1),
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => cubit.updateQuantity(item.menuItem, item.quantity + 1),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      '${cubit.totalPrice.toStringAsFixed(2)} €',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _validateOrder(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Valider la commande'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _validateOrder(BuildContext context) async {
    final cubit = context.read<CartCubit>();
    final state = cubit.state;
    if (state.items.isEmpty) return;

    final orderItems = state.items.map((item) => OrderItem(
      menuItemId: item.menuItem.itemName,
      name: item.menuItem.itemName,
      price: item.menuItem.price,
      quantity: item.quantity,
    )).toList();

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      establishmentId: restaurantId ?? 'unknown',
      establishmentName: restaurantName ?? 'Restaurant', // ← nom correct
      establishmentType: restaurantType,                 // ← type correct
      orderDate: DateTime.now(),
      items: orderItems,
      subtotal: cubit.totalPrice,
      tax: 0.0,
      totalAmount: cubit.totalPrice,
      status: OrderStatus.pending,
      notes: null,
    );

    try {
      await OrderService.saveOrder(order);
      cubit.clearCart();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commande validée !'), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Retour au menu
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    }
  }
}